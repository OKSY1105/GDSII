# =====================================================================
# uart_top_block_mmmc.sdc - UART PAD-free block synthesis (GPDK045)
# Design : uart_top / System clock: 100 MHz (10 ns)
# The RTL must be compiled WITHOUT USE_IO_PAD (no PADDI/PADDO cells).
# This block is placed inside the MCU later; all ports are block pins.
# Copy of ../cons/uart_top_mmmc.sdc; only comments and the o_uart_txd load differ.
# =====================================================================

set_units -capacitance 1000.0fF
set_units -time 1000.0ps

#############################
# Timing constraints reset
#############################
# Corner selection belongs to uart_top.mmmc.view.

#############################
# CLOCK
#############################
# The external i_clk port feeds uart_top directly (NO clock PAD yet).
# 100 MHz = 10 ns; unlike Cortex-M0, do not use XTAL1 / MAIN_CLOCK.
create_clock -period 10 -name UART_CLK [get_ports i_clk]

# Preliminary values reused from the original Cortex-M0 SDC.
set_clock_latency -source -max 0.2 [get_clocks UART_CLK]
set_clock_latency -max 0.2 [get_clocks UART_CLK]
set_clock_uncertainty -setup 0.1 [get_clocks UART_CLK]
set_clock_transition 0.1 [get_clocks UART_CLK]

#############################
# INPUT / OUTPUT DELAY
#############################
# THR/RHR control ports are assumed synchronous to i_clk for this test.
# i_uart_rxd is asynchronous serial input; do not assign it a fake
# synchronous input_delay. i_clk and i_rst_n are excluded as well.
set SYNC_INPUTS [remove_from_collection [all_inputs] [get_ports {i_clk i_rst_n i_uart_rxd}]]
set_input_delay -max 0.1  -clock UART_CLK $SYNC_INPUTS
set_input_delay -min 0.01 -clock UART_CLK $SYNC_INPUTS

# CPU/status output ports only. The UART serial TX output is excluded,
# since no external receiver clock/timing requirement is specified yet.
set SYNC_OUTPUTS [remove_from_collection [all_outputs] [get_ports o_uart_txd]]
set_output_delay -max 0.1   -clock UART_CLK $SYNC_OUTPUTS
set_output_delay -min -0.01 -clock UART_CLK $SYNC_OUTPUTS

#############################
# INPUT DRIVE / OUTPUT LOAD
#############################
# This block has no PAD cells (USE_IO_PAD is not defined).
# RX/TX PAD cells belong to the MCU top level, so every block port
# drives or receives an MCU-internal net only.

# Example external signal rise/fall time at RX PAD and non-PAD inputs.
set_input_transition 0.1 [get_ports i_uart_rxd]
set_input_transition 0.1 $SYNC_INPUTS

# o_uart_txd is a block pin inside the MCU, not a board pin. Use the same
# small load as the other outputs (the 1.0 pF board load is pad-version only).
set_load 0.01 [get_ports o_uart_txd]

# Example small loads on other outputs, which still have no physical pads.
set_load 0.01 $SYNC_OUTPUTS

#############################
# RESET / EXCEPTIONS
#############################
# Asynchronous reset is not ordinary clock-synchronous data.
set_ideal_network [get_ports i_rst_n]

# No set_dont_touch for u_cmsdk_mcu_system or pad1..pad75.
# Check unconstrained asynchronous RX / serial TX paths separately.
# If the final chip is implemented, clock/reset/control ports also need
# their real I/O implementation and signoff constraints.
