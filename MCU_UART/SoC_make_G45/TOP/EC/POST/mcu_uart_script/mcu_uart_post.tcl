// Post-Layout LEC: cmsdk_mcu (Synthesized netlist <-> PnR netlist)
// Run from: <ROOT>/SoC_make_G45/TOP/EC/POST
//   lec
//   SETUP> dofile ./mcu_uart_script/mcu_uart_post.tcl

set log file ./mcu_uart_log/mcu_uart_post.log -replace

// Library path: absolute path under root /GPDK045 (same as UART_GDSII/TOP/EC/uart_script.tcl)
read library -verilog -both \
	/GPDK045/digital/gsclib045_all_v4.4/gsclib045/verilog/slow_vdd1v0_basicCells.v \
	/GPDK045/digital/gsclib045_all_v4.4/gsclib045/verilog/fast_vdd1v0_basicCells.v \
	/GPDK045/digital/giolib045_v3.5/vlog/pads_SS_s1vg.v

read design ../../SYN/mcu_uart_mapped/mcu_uart_syn_final.v -verilog -golden

read design ../../PNR/mcu_uart.v -verilog -revised

set system mode lec

add compare points -all

compare

report verification
report statistics
