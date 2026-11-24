// Stage 1 Pre-Layout LEC: cmsdk_mcu_system (RTL <-> 1st-stage synthesized netlist)
// Run from: <ROOT>/SoC_make_G45/TOP/EC
//   lec
//   SETUP> dofile ./mcu_uart_script/mcu_uart_stage1_system.tcl

set log file ./mcu_uart_log/mcu_uart_stage1_system.log -replace

// Library path: absolute path under root /GPDK045 (same as UART_GDSII/TOP/EC/uart_script.tcl)
read library -verilog -both \
	/GPDK045/digital/gsclib045_all_v4.4/gsclib045/verilog/slow_vdd1v0_basicCells.v \
	/GPDK045/digital/gsclib045_all_v4.4/gsclib045/verilog/fast_vdd1v0_basicCells.v \
	/GPDK045/digital/giolib045_v3.5/vlog/pads_SS_s1vg.v

// Search paths for `include directives in CMSDK RTL
add search path ../../../cortexm0_designstart/implementation/cortex_m0_mcu_system_cadence_8ns -design -golden
add search path ../../../cortexm0_designstart/systems/cortex_m0_mcu/verilog -design -golden
add search path ../../../cortexm0_designstart/logical/cmsdk_apb_dualtimers/verilog -design -golden
add search path ../../../cortexm0_designstart/logical/cmsdk_apb_watchdog/verilog -design -golden
add search path ../../../cortexm0_designstart/logical/uart_apb/verilog -design -golden

// Golden: Stage-1 RTL (33 files, matching RTL_LIST.tcl with UART2 replaced by uart_apb_wrapper)
read design -verilog -golden -root cmsdk_mcu_system \
	../../../cortexm0_designstart/logical/cmsdk_apb_dualtimers/verilog/cmsdk_apb_dualtimers.v \
	../../../cortexm0_designstart/logical/cmsdk_apb_dualtimers/verilog/cmsdk_apb_dualtimers_frc.v \
	../../../cortexm0_designstart/logical/cmsdk_apb_watchdog/verilog/cmsdk_apb_watchdog.v \
	../../../cortexm0_designstart/logical/cmsdk_apb_watchdog/verilog/cmsdk_apb_watchdog_frc.v \
	../../../cortexm0_designstart/logical/cmsdk_iop_gpio/verilog/cmsdk_iop_gpio.v \
	../../../cortexm0_designstart/logical/cmsdk_ahb_gpio/verilog/cmsdk_ahb_to_iop.v \
	../../../cortexm0_designstart/logical/cmsdk_ahb_gpio/verilog/cmsdk_ahb_gpio.v \
	../../../cortexm0_designstart/logical/cmsdk_ahb_to_apb/verilog/cmsdk_ahb_to_apb.v \
	../../../cortexm0_designstart/logical/cmsdk_ahb_slave_mux/verilog/cmsdk_ahb_slave_mux.v \
	../../../cortexm0_designstart/logical/cmsdk_apb_slave_mux/verilog/cmsdk_apb_slave_mux.v \
	../../../cortexm0_designstart/logical/cmsdk_apb_subsystem/verilog/cmsdk_apb_subsystem.v \
	../../../cortexm0_designstart/logical/cmsdk_apb_subsystem/verilog/cmsdk_apb_test_slave.v \
	../../../cortexm0_designstart/logical/cmsdk_apb_subsystem/verilog/cmsdk_irq_sync.v \
	../../../cortexm0_designstart/logical/cmsdk_apb_timer/verilog/cmsdk_apb_timer.v \
	../../../cortexm0_designstart/logical/cmsdk_apb_uart/verilog/cmsdk_apb_uart.v \
	../../../cortexm0_designstart/logical/uart_apb/verilog/uart_apb_wrapper.v \
	../../../cortexm0_designstart/logical/uart_apb/verilog/uart_top.v \
	../../../cortexm0_designstart/logical/uart_apb/verilog/uart_tx.v \
	../../../cortexm0_designstart/logical/uart_apb/verilog/uart_rx.v \
	../../../cortexm0_designstart/logical/uart_apb/verilog/baud_rate_gen.v \
	../../../cortexm0_designstart/logical/uart_apb/verilog/fifo.v \
	../../../cortexm0_designstart/logical/cmsdk_ahb_default_slave/verilog/cmsdk_ahb_default_slave.v \
	../../../cortexm0_designstart/systems/cortex_m0_mcu/verilog/cmsdk_ahb_cs_rom_table.v \
	../../../cortexm0_designstart/systems/cortex_m0_mcu/verilog/cmsdk_mcu_sysctrl.v \
	../../../cortexm0_designstart/systems/cortex_m0_mcu/verilog/cmsdk_mcu_addr_decode.v \
	../../../cortexm0_designstart/systems/cortex_m0_mcu/verilog/cmsdk_mcu_system.v \
	../../../cortexm0_designstart/systems/cortex_m0_mcu/verilog/cmsdk_mcu_stclkctrl.v \
	../../../cortexm0_designstart/cores/cortexm0_designstart_r1p0/logical/cortexm0ds/verilog/CORTEXM0DS.v \
	../../../cortexm0_designstart/cores/cortexm0_designstart_r1p0/logical/cortexm0ds/verilog/cortexm0ds_logic.v \
	../../../cortexm0_designstart/cores/cortexm0_designstart_r1p0/logical/cortexm0_dap/verilog/CORTEXM0DAP.v \
	../../../cortexm0_designstart/cores/cortexm0_designstart_r1p0/logical/cortexm0_integration/verilog/CORTEXM0INTEGRATION.v \
	../../../cortexm0_designstart/cores/cortexm0_designstart_r1p0/logical/cortexm0_integration/verilog/cortexm0_wic.v \
	../../../cortexm0_designstart/cores/cortexm0_designstart_r1p0/logical/models/cells/cm0_dbg_reset_sync.v

// Revised: Stage-1 synthesized netlist
read design ../../../cortexm0_designstart/implementation/cortex_m0_mcu_system_cadence_8ns/mcu_uart_mapped/mcu_uart_system_syn_final.v -verilog -revised -root cmsdk_mcu_system

set system mode lec

add compare points -all

compare

report verification
report statistics
