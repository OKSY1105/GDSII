
# HEX file is defined at ../TESTBENCH/tb_cmsdk_mcu.v 

cp ../../../PNR/mcu_uart_hier.v ./
cp ../../../PNR/mcu_uart_post_wst.sdf ./cmsdk_mcu_post_wst.sdf

xrun -64bit \
     +max_err_count+50 \
     +define+sdf_post_wst \
     -access +rwc \
     -profile \
     -profthread \
     -gui \
     +libext+.v \
     -incdir ../../../../TOP/RTL/verilog_smkcow \
     -incdir ../../TESTBENCH \
     -y ../../../../TOP/RTL/verilog_smkcow \
     -y ../../TESTBENCH \
     ../../TESTBENCH/tb_cmsdk_mcu.v \
     ../../TESTBENCH/uart_capture_8e1.v \
     mcu_uart_hier.v \
     ../../../RTL/memories_smkcow_1/cmsdk_ahb_ram.v \
     ../../../RTL/memories_smkcow_1/cmsdk_ahb_ram_beh.v \
     ../../../RTL/memories_smkcow_1/cmsdk_ahb_rom.v \
     ../../../RTL/memories_smkcow_1/cmsdk_ahb_rom_beh.v \
     /GPDK045/digital/gsclib045_all_v4.4/gsclib045_svt_v4.4/gsclib045/verilog/slow_vdd1v0_basicCells.v \
     /GPDK045/digital/giolib045_v3.5/vlog/pads_SS_s1vg.v \
     -l mcu_uart_post_sim_max.log

