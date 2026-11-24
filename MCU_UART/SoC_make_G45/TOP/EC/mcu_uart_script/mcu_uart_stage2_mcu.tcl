// Stage 2 Pre-Layout LEC: cmsdk_mcu (Top RTL + Stage-1 netlist <-> 2nd-stage synthesized netlist)
// Run from: <ROOT>/SoC_make_G45/TOP/EC
//   lec
//   SETUP> dofile ./mcu_uart_script/mcu_uart_stage2_mcu.tcl
// Note: SYN/mcu_uart_mapped/mcu_uart_syn_final.v must be the pure synthesized netlist (before add_pad).

set log file ./mcu_uart_log/mcu_uart_stage2_mcu.log -replace

// Library path: absolute path under root /GPDK045 (same as UART_GDSII/TOP/EC/uart_script.tcl)
read library -verilog -both \
	/GPDK045/digital/gsclib045_all_v4.4/gsclib045/verilog/slow_vdd1v0_basicCells.v \
	/GPDK045/digital/gsclib045_all_v4.4/gsclib045/verilog/fast_vdd1v0_basicCells.v \
	/GPDK045/digital/giolib045_v3.5/vlog/pads_SS_s1vg.v

read design \
	../RTL/cmsdk_mcu.v \
	../RTL/verilog_smkcow/cmsdk_mcu_clkctrl.v \
	../RTL/verilog_smkcow/cmsdk_mcu_pin_mux.v \
	../../../cortexm0_designstart/implementation/cortex_m0_mcu_system_cadence_8ns/mcu_uart_mapped/mcu_uart_system_syn_final.v \
	-verilog -golden

read design ../SYN/mcu_uart_mapped/mcu_uart_syn_final.v -verilog -revised

set system mode lec

add compare points -all

compare

report verification
report statistics
