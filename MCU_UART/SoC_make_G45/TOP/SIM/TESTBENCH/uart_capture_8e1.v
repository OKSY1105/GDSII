//-----------------------------------------------------------------------------
// uart_capture_8e1 (testbench only)
//   Replacement for cmsdk_uart_capture when the stdout UART is the user UART.
//   Frame: start + 8 data (LSB first) + even parity + 1 stop.
//   CLKS_PER_BIT must equal the UART bit period in CLK cycles:
//     uart_top baud_rate_gen: OS_DIV = (CLK_FREQ_HZ + BAUD*8) / (BAUD*16)
//     bit period = OS_DIV * 16  (125 MHz, 115200 -> 68 * 16 = 1088)
//   Port list is the same as cmsdk_uart_capture.
//   Text handling follows cmsdk_uart_capture: CR/LF prints the line,
//   0x04 ends the simulation ($stop).
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module uart_capture_8e1 #(
  parameter integer CLKS_PER_BIT = 1088
)(
  input  wire       RESETn,
  input  wire       CLK,
  input  wire       RXD,
  output wire       SIMULATIONEND,
  output wire       DEBUG_TESTER_ENABLE,
  output wire [7:0] AUXCTRL);

  localparam S_IDLE = 0, S_START = 1, S_DATA = 2, S_PAR = 3, S_STOP = 4;

  reg [2:0]  state;
  integer    cnt;
  reg [2:0]  bit_idx;
  reg [7:0]  data;
  reg        par_bit;
  reg        rxd_s1, rxd_s2;
  reg        end_sim;

  reg [7:0]  line_buf [0:127];
  integer    line_len;
  integer    i;
  integer    n_chars, n_par_err, n_frm_err;

  assign SIMULATIONEND       = end_sim;
  assign DEBUG_TESTER_ENABLE = 1'b0;
  assign AUXCTRL             = 8'h00;

  task print_line;
    begin
      $write("%t UART: ", $time);
      for (i = 0; i < line_len; i = i + 1) $write("%s", line_buf[i]);
      $write("\n");
      line_len = 0;
    end
  endtask

  task handle_char(input [7:0] ch, input perr, input ferr);
    begin
      n_chars = n_chars + 1;
      if (perr) begin n_par_err = n_par_err + 1; $display("%t UART: parity error on 0x%02h", $time, ch); end
      if (ferr) begin n_frm_err = n_frm_err + 1; $display("%t UART: frame error on 0x%02h", $time, ch); end
      if (ch == 8'h04) begin
        if (line_len > 0) print_line;
        $display("%t UART: Test Ended (chars=%0d, parity errors=%0d, frame errors=%0d)",
                 $time, n_chars, n_par_err, n_frm_err);
        end_sim = 1'b1;
        #1 $stop;
      end
      else if (ch == 8'h0D || ch == 8'h0A) begin
        if (line_len > 0) print_line;
      end
      else begin
        line_buf[line_len] = ch;
        line_len = line_len + 1;
        if (line_len > 79) print_line;
      end
    end
  endtask

  initial begin
    line_len = 0; n_chars = 0; n_par_err = 0; n_frm_err = 0; end_sim = 1'b0;
  end

  always @(posedge CLK or negedge RESETn) begin
    if (!RESETn) begin
      state <= S_IDLE; cnt <= 0; bit_idx <= 3'd0; data <= 8'h00; par_bit <= 1'b0;
      rxd_s1 <= 1'b1; rxd_s2 <= 1'b1;
    end
    else begin
      rxd_s1 <= (RXD === 1'b0) ? 1'b0 : 1'b1;   // Z/X treated as idle
      rxd_s2 <= rxd_s1;
      case (state)
        S_IDLE:  if (rxd_s2 == 1'b0) begin cnt <= 1; state <= S_START; end
        S_START: if (cnt == CLKS_PER_BIT/2) begin
                   cnt <= 0;
                   if (rxd_s2 == 1'b0) begin bit_idx <= 3'd0; state <= S_DATA; end
                   else state <= S_IDLE;                     // glitch
                 end else cnt <= cnt + 1;
        S_DATA:  if (cnt == CLKS_PER_BIT-1) begin
                   cnt <= 0;
                   data[bit_idx] <= rxd_s2;
                   if (bit_idx == 3'd7) state <= S_PAR; else bit_idx <= bit_idx + 3'd1;
                 end else cnt <= cnt + 1;
        S_PAR:   if (cnt == CLKS_PER_BIT-1) begin
                   cnt <= 0; par_bit <= rxd_s2; state <= S_STOP;
                 end else cnt <= cnt + 1;
        S_STOP:  if (cnt == CLKS_PER_BIT-1) begin
                   cnt <= 0; state <= S_IDLE;
                   handle_char(data, (par_bit != ^data), (rxd_s2 != 1'b1));
                 end else cnt <= cnt + 1;
        default: state <= S_IDLE;
      endcase
    end
  end

endmodule
