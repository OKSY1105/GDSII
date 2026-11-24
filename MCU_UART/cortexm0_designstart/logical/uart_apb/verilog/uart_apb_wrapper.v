//-----------------------------------------------------------------------------
// uart_apb_wrapper
//   APB slave wrapper for uart_top (user UART, 8 data bits + even parity + 1 stop).
//   Port list is identical to cmsdk_apb_uart so that it can replace a CMSDK UART
//   instance without changing the surrounding RTL.
//
// Register map (CMSDK APB UART compatible offsets)
//   0x000 DATA      R  : RX FIFO head [7:0] (read pops one byte when data is present)
//                   W  : TX FIFO push [7:0] (ignored when TX FIFO is full -> TX overrun)
//   0x004 STATE     R  : [0] TX FIFO full  [1] RX data ready  [2] TX overrun  [3] RX overrun
//                        [4] RX frame error [5] RX parity error (bits 4,5 are sticky in uart_rx)
//                   W  : write 1 to bit 2 / bit 3 clears TX / RX overrun flag
//   0x008 CTRL      RW : [0] TX enable (TXEN pin)  [1] RX enable (RXD gated to idle when 0)
//                        [2] TX int en  [3] RX int en  [4] TX overrun int en  [5] RX overrun int en
//                        [6] high speed test mode (stored only, not supported)
//   0x00C INTSTATUS R  : [0] TX  [1] RX  [2] TX overrun  [3] RX overrun
//         INTCLEAR  W  : write 1 to clear
//   0x010 BAUDDIV   RW : [19:0] stored only. Baud rate is fixed by parameters
//                        (CLK_FREQ_HZ, BAUD_RATE) inside uart_top.
//   others          R  : 0
//-----------------------------------------------------------------------------
module uart_apb_wrapper #(
  parameter CLK_FREQ_HZ = 125_000_000,
  parameter BAUD_RATE   = 115200
)(
  input  wire        PCLK,      // Clock
  input  wire        PCLKG,     // Gated clock (not used, single clock design)
  input  wire        PRESETn,   // Reset

  input  wire        PSEL,      // Device select
  input  wire [11:2] PADDR,     // Address
  input  wire        PENABLE,   // Transfer control
  input  wire        PWRITE,    // Write control
  input  wire [31:0] PWDATA,    // Write data

  input  wire [3:0]  ECOREVNUM, // Not used

  output wire [31:0] PRDATA,    // Read data
  output wire        PREADY,    // Device ready
  output wire        PSLVERR,   // Device error response

  input  wire        RXD,       // Serial input
  output wire        TXD,       // Transmit data output
  output wire        TXEN,      // Transmit enabled
  output wire        BAUDTICK,  // Not supported (tied 0)

  output wire        TXINT,     // Transmit interrupt
  output wire        RXINT,     // Receive interrupt
  output wire        TXOVRINT,  // Transmit overrun interrupt
  output wire        RXOVRINT,  // Receive overrun interrupt
  output wire        UARTINT);  // Combined interrupt

  // ---------------------------------------------------------------------------
  // APB decode (write and read in the access phase, PREADY is always 1)
  // ---------------------------------------------------------------------------
  wire apb_wr    = PSEL & PENABLE &  PWRITE;
  wire apb_rd    = PSEL & PENABLE & ~PWRITE;
  wire sel_data  = (PADDR[11:2] == 10'h000);
  wire sel_state = (PADDR[11:2] == 10'h001);
  wire sel_ctrl  = (PADDR[11:2] == 10'h002);
  wire sel_int   = (PADDR[11:2] == 10'h003);
  wire sel_baud  = (PADDR[11:2] == 10'h004);

  // ---------------------------------------------------------------------------
  // User UART
  // ---------------------------------------------------------------------------
  wire       tx_fifo_full;
  wire       rx_fifo_full;
  wire       lsr_dr;
  wire       lsr_thre;
  wire       lsr_temt;
  wire       lsr_fe;
  wire       lsr_pe;
  wire       lsr_oe;
  wire [7:0] rhr_rdata;

  reg  [6:0]  reg_ctrl;
  reg  [19:0] reg_baud;
  reg         reg_tx_ovr;
  reg         reg_rx_ovr;
  reg  [3:0]  reg_int;
  reg         lsr_thre_d;
  reg         lsr_dr_d;
  reg         lsr_oe_d;

  wire thr_we    = apb_wr & sel_data & ~tx_fifo_full;
  wire tx_ovr_ev = apb_wr & sel_data &  tx_fifo_full;
  wire rhr_re    = apb_rd & sel_data &  lsr_dr;
  wire rxd_in    = reg_ctrl[1] ? RXD : 1'b1;   // RX disabled: line held idle

  uart_top #(
    .CLK_FREQ_HZ (CLK_FREQ_HZ),
    .BAUD_RATE   (BAUD_RATE),
    .DATA_BIT    (8),
    .FIFO_DEPTH  (16)
  ) u_uart_top (
    .i_clk          (PCLK),
    .i_rst_n        (PRESETn),
    .o_uart_txd     (TXD),
    .i_uart_rxd     (rxd_in),
    .i_thr_we       (thr_we),
    .i_thr_wdata    (PWDATA[7:0]),
    .i_rhr_re       (rhr_re),
    .o_rhr_rdata    (rhr_rdata),
    .o_lsr_dr       (lsr_dr),
    .o_lsr_thre     (lsr_thre),
    .o_lsr_temt     (lsr_temt),
    .o_lsr_fe       (lsr_fe),
    .o_lsr_pe       (lsr_pe),
    .o_lsr_oe       (lsr_oe),
    .o_tx_fifo_full (tx_fifo_full),
    .o_rx_fifo_full (rx_fifo_full)
  );

  // ---------------------------------------------------------------------------
  // Registers
  // ---------------------------------------------------------------------------
  wire rx_ovr_ev = lsr_oe & ~lsr_oe_d;   // uart_rx keeps OE set; use its rising edge

  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      reg_ctrl   <= 7'h00;
      reg_baud   <= 20'h00000;
      reg_tx_ovr <= 1'b0;
      reg_rx_ovr <= 1'b0;
      reg_int    <= 4'h0;
      lsr_thre_d <= 1'b1;
      lsr_dr_d   <= 1'b0;
      lsr_oe_d   <= 1'b0;
    end
    else begin
      lsr_thre_d <= lsr_thre;
      lsr_dr_d   <= lsr_dr;
      lsr_oe_d   <= lsr_oe;

      if (apb_wr & sel_ctrl) reg_ctrl <= PWDATA[6:0];
      if (apb_wr & sel_baud) reg_baud <= PWDATA[19:0];

      // overrun flags: set by event, cleared by writing 1 to STATE bit
      if (tx_ovr_ev)                               reg_tx_ovr <= 1'b1;
      else if (apb_wr & sel_state & PWDATA[2])     reg_tx_ovr <= 1'b0;
      if (rx_ovr_ev)                               reg_rx_ovr <= 1'b1;
      else if (apb_wr & sel_state & PWDATA[3])     reg_rx_ovr <= 1'b0;

      // interrupt status: set by enabled event, cleared by INTCLEAR write
      if (reg_ctrl[2] & lsr_thre & ~lsr_thre_d)    reg_int[0] <= 1'b1;  // TX FIFO became empty
      else if (apb_wr & sel_int & PWDATA[0])       reg_int[0] <= 1'b0;
      if (reg_ctrl[3] & lsr_dr & ~lsr_dr_d)        reg_int[1] <= 1'b1;  // RX data arrived
      else if (apb_wr & sel_int & PWDATA[1])       reg_int[1] <= 1'b0;
      if (reg_ctrl[4] & tx_ovr_ev)                 reg_int[2] <= 1'b1;
      else if (apb_wr & sel_int & PWDATA[2])       reg_int[2] <= 1'b0;
      if (reg_ctrl[5] & rx_ovr_ev)                 reg_int[3] <= 1'b1;
      else if (apb_wr & sel_int & PWDATA[3])       reg_int[3] <= 1'b0;
    end
  end

  // ---------------------------------------------------------------------------
  // Read data
  // ---------------------------------------------------------------------------
  reg [31:0] rdata_mux;
  always @(*) begin
    rdata_mux = 32'h0000_0000;
    if (sel_data)  rdata_mux = {24'h000000, (lsr_dr ? rhr_rdata : 8'h00)};
    if (sel_state) rdata_mux = {26'h0, lsr_pe, lsr_fe, reg_rx_ovr, reg_tx_ovr, lsr_dr, tx_fifo_full};
    if (sel_ctrl)  rdata_mux = {25'h0, reg_ctrl};
    if (sel_int)   rdata_mux = {28'h0, reg_int};
    if (sel_baud)  rdata_mux = {12'h000, reg_baud};
  end

  assign PRDATA   = (PSEL & ~PWRITE) ? rdata_mux : 32'h0000_0000;
  assign PREADY   = 1'b1;
  assign PSLVERR  = 1'b0;
  assign TXEN     = reg_ctrl[0];
  assign BAUDTICK = 1'b0;

  assign TXINT    = reg_int[0];
  assign RXINT    = reg_int[1];
  assign TXOVRINT = reg_int[2];
  assign RXOVRINT = reg_int[3];
  assign UARTINT  = |reg_int;

endmodule
