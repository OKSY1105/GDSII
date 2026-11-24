# Unit test of uart_apb_wrapper (APB register access + TXD->RXD loopback)
# run in this folder: ./run_unit.tcl  (source ~/digital.cshrc first)
xrun -64bit \
     -access +rwc \
     tb_uart_apb_wrapper.v \
     ../../../../cortexm0_designstart/logical/uart_apb/verilog/uart_apb_wrapper.v \
     ../../../../cortexm0_designstart/logical/uart_apb/verilog/uart_top.v \
     ../../../../cortexm0_designstart/logical/uart_apb/verilog/uart_tx.v \
     ../../../../cortexm0_designstart/logical/uart_apb/verilog/uart_rx.v \
     ../../../../cortexm0_designstart/logical/uart_apb/verilog/baud_rate_gen.v \
     ../../../../cortexm0_designstart/logical/uart_apb/verilog/fifo.v \
     -top tb_uart_apb_wrapper \
     -l unit_sim.log
