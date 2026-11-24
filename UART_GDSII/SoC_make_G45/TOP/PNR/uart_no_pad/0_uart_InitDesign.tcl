# UART standard-cell block: no IO PAD instances or chip IO ring.
# Run from TOP/PNR in a fresh Innovus legacy session.
set init_gnd_net VSS
set init_pwr_net VDD
set init_lef_file [list \
    /GPDK045/digital/gsclib045_all_v4.4/gsclib045_tech/lef/gsclib045_tech.lef \
    /GPDK045/digital/gsclib045_all_v4.4/gsclib045/lef/gsclib045_macro.lef \
    /GPDK045/digital/gsclib045_all_v4.4/gsclib045/lef/gsclib045_multibitsDFF.lef]
set init_verilog ../SYN/uart_block_mapped/uart_top_syn_final.v
set init_mmmc_file uart_no_pad/uart_block.mmmc.view
set init_top_cell uart_top

foreach required [concat $init_lef_file [list $init_verilog $init_mmmc_file]] {
    if {![file isfile $required]} {error "Missing UART block input: $required"}
}
file mkdir uart_block_reports/checkDesign
init_design

# Utilization and margins are starting values; inspect placement and routing.
floorPlan -site CoreSite -r 1.0 0.55 20 20 20 20

# All 30 top-level signal bits become block boundary pins.
editPin -pin {i_clk i_rst_n i_uart_rxd i_thr_we i_rhr_re
              i_thr_wdata[0] i_thr_wdata[1] i_thr_wdata[2] i_thr_wdata[3]
              i_thr_wdata[4] i_thr_wdata[5] i_thr_wdata[6] i_thr_wdata[7]} \
        -side LEFT -layer Metal3 -spreadType SIDE -fixedPin
editPin -pin {o_uart_txd o_rhr_rdata[0] o_rhr_rdata[1] o_rhr_rdata[2]
              o_rhr_rdata[3] o_rhr_rdata[4] o_rhr_rdata[5] o_rhr_rdata[6]
              o_rhr_rdata[7] o_lsr_dr o_lsr_thre o_lsr_temt o_lsr_fe
              o_lsr_pe o_lsr_oe o_tx_fifo_full o_rx_fifo_full} \
        -side RIGHT -layer Metal3 -spreadType SIDE -fixedPin

checkDesign -io -netlist -physicalLibrary -powerGround -tieHilo \
            -timingLibrary -floorplan -outdir uart_block_reports/checkDesign
saveDesign -def uart_block_InitDesign
#exit
