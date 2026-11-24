//-----------------------------------------------------------------------------
// tb_uart_apb_wrapper : unit test for uart_apb_wrapper (APB BFM + TXD->RXD loopback)
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module tb_uart_apb_wrapper;
  localparam integer CLK_FREQ_HZ = 125_000_000;
  localparam integer BAUD        = 115200;
  localparam integer OS_DIV      = (CLK_FREQ_HZ + (BAUD*16)/2) / (BAUD*16);
  localparam integer BIT_CLKS    = OS_DIV * 16;      // 1088
  localparam real    TCLK        = 8.0;              // 125 MHz

  reg         PCLK = 1'b0, PRESETn = 1'b0;
  reg         PSEL = 1'b0, PENABLE = 1'b0, PWRITE = 1'b0;
  reg  [11:2] PADDR = 10'h0;
  reg  [31:0] PWDATA = 32'h0;
  wire [31:0] PRDATA;
  wire        PREADY, PSLVERR, TXD, TXEN, BAUDTICK;
  wire        TXINT, RXINT, TXOVRINT, RXOVRINT, UARTINT;
  reg         loop_en = 1'b1;
  wire        RXD = loop_en ? TXD : 1'b1;

  integer errors = 0, checks = 0;

  always #(TCLK/2) PCLK = ~PCLK;

  uart_apb_wrapper #(.CLK_FREQ_HZ(CLK_FREQ_HZ), .BAUD_RATE(BAUD)) dut (
    .PCLK(PCLK), .PCLKG(PCLK), .PRESETn(PRESETn),
    .PSEL(PSEL), .PADDR(PADDR), .PENABLE(PENABLE), .PWRITE(PWRITE), .PWDATA(PWDATA),
    .ECOREVNUM(4'h0), .PRDATA(PRDATA), .PREADY(PREADY), .PSLVERR(PSLVERR),
    .RXD(RXD), .TXD(TXD), .TXEN(TXEN), .BAUDTICK(BAUDTICK),
    .TXINT(TXINT), .RXINT(RXINT), .TXOVRINT(TXOVRINT), .RXOVRINT(RXOVRINT), .UARTINT(UARTINT));

  task apb_write(input [11:0] addr, input [31:0] data);
    begin
      @(posedge PCLK); #1; PSEL = 1; PENABLE = 0; PWRITE = 1; PADDR = addr[11:2]; PWDATA = data;
      @(posedge PCLK); #1; PENABLE = 1;
      @(posedge PCLK); #1; PSEL = 0; PENABLE = 0; PWRITE = 0;
    end
  endtask

  task apb_read(input [11:0] addr, output [31:0] data);
    begin
      @(posedge PCLK); #1; PSEL = 1; PENABLE = 0; PWRITE = 0; PADDR = addr[11:2];
      @(posedge PCLK); #1; PENABLE = 1;
      #1 data = PRDATA;                      // sampled in the access phase
      @(posedge PCLK); #1; PSEL = 0; PENABLE = 0;
    end
  endtask

  task check(input [255:0] name, input [31:0] got, input [31:0] exp);
    begin
      checks = checks + 1;
      if (got !== exp) begin errors = errors + 1; $display("FAIL %0s: got 0x%08h exp 0x%08h", name, got, exp); end
      else $display("ok   %0s = 0x%08h", name, got);
    end
  endtask

  task wait_bits(input integer n);
    begin repeat (n * BIT_CLKS) @(posedge PCLK); end
  endtask

  reg [31:0] rd;
  integer k, t0, t1;
  reg [7:0] pat [0:3];

  initial begin
    $display("BIT_CLKS = %0d", BIT_CLKS);
    repeat (5) @(posedge PCLK); PRESETn = 1;

    // 1. reset values
    apb_read(12'h004, rd); check("STATE after reset", rd, 32'h0);
    apb_read(12'h008, rd); check("CTRL after reset", rd, 32'h0);
    check("TXD idle", TXD, 1);

    // 2. registers
    apb_write(12'h008, 32'h0000_000F);  // TX/RX enable, TX/RX int enable
    apb_read (12'h008, rd); check("CTRL", rd, 32'h0F);
    apb_write(12'h010, 32'h0001_2345);
    apb_read (12'h010, rd); check("BAUDDIV", rd, 32'h0001_2345);
    check("TXEN", TXEN, 1);
    apb_write(12'h00C, 32'h0000_000F);  // clear any interrupt

    // 3. bit period: 0x00 -> start + 8 zeros + parity 0 = 10 low bits
    apb_write(12'h000, 32'h0000_0000);
    @(negedge TXD); t0 = $time;
    @(posedge TXD); t1 = $time;
    check("TXD low width for 0x00 (clocks)", (t1 - t0) / 8, 10 * BIT_CLKS);
    wait_bits(2);
    apb_read(12'h004, rd); check("STATE rx data ready", rd & 32'h2, 32'h2);
    apb_read(12'h00C, rd); check("INTSTATUS rx int", rd & 32'h2, 32'h2);
    apb_read(12'h000, rd); check("DATA 0x00", rd, 32'h00);
    apb_read(12'h004, rd); check("STATE after read", rd & 32'h3F, 32'h0);
    apb_write(12'h00C, 32'h0000_0002);
    apb_read(12'h00C, rd); check("INTSTATUS rx cleared", rd & 32'h2, 32'h0);

    // 4. back-to-back bytes, FIFO order, parity of odd/even weight bytes
    pat[0] = 8'h55; pat[1] = 8'hA3; pat[2] = 8'hFF; pat[3] = 8'h01;
    for (k = 0; k < 4; k = k + 1) apb_write(12'h000, {24'h0, pat[k]});
    wait_bits(4 * 11 + 3);
    for (k = 0; k < 4; k = k + 1) begin apb_read(12'h000, rd); check("DATA loopback", rd, {24'h0, pat[k]}); end
    apb_read(12'h004, rd); check("STATE no errors", rd & 32'h3C, 32'h0);

    // 5. TX FIFO full and TX overrun (20 writes, FIFO depth 16)
    for (k = 0; k < 20; k = k + 1) apb_write(12'h000, 32'h30 + k);
    apb_read(12'h004, rd); check("STATE tx full + tx overrun", rd & 32'h5, 32'h5);
    apb_write(12'h004, 32'h0000_0004);
    apb_read(12'h004, rd); check("STATE tx overrun cleared", rd & 32'h4, 32'h0);

    // 6. RX overrun: more than 16 bytes arrive without reading
    wait_bits(20 * 11 + 3);
    apb_read(12'h004, rd); check("STATE rx overrun", rd & 32'h8, 32'h8);
    for (k = 0; k < 16; k = k + 1) apb_read(12'h000, rd);
    apb_read(12'h004, rd); check("STATE rx empty after 16 reads", rd & 32'h2, 32'h0);
    apb_write(12'h004, 32'h0000_0008);
    apb_read(12'h004, rd); check("STATE rx overrun cleared", rd & 32'h8, 32'h0);

    // 7. RX disabled: byte is not received
    apb_write(12'h008, 32'h0000_0001);
    apb_write(12'h000, 32'h0000_005A);
    wait_bits(14);
    apb_read(12'h004, rd); check("STATE rx disabled -> no data", rd & 32'h2, 32'h0);

    $display("UNIT TEST %s (checks=%0d, errors=%0d)", (errors == 0) ? "PASSED" : "FAILED", checks, errors);
    $finish;
  end

  initial begin #20_000_000; $display("UNIT TEST FAILED (timeout)"); $finish; end
endmodule
