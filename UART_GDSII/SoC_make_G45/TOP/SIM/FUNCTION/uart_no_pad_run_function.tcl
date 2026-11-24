## Run from the SIM/FUNCTION_NO_PAD directory.

set UART_NETLIST  = "../../SYN/uart_block_mapped/uart_top_syn_final.v"
set UART_TB       = "../TESTBENCH/tb_uart.v"
set PAD_MODEL     = "/GPDK045/digital/giolib045_v3.5/vlog/pads_FF_s1vg.v"
set STD_MODEL     = "/GPDK045/digital/gsclib045_all_v4.4/gsclib045_svt_v4.4/gsclib045/verilog/fast_vdd1v0_basicCells.v"
set UART_DUMP_DIR = "./uart_dump"

mkdir -p "$UART_DUMP_DIR"

foreach file ($UART_NETLIST $UART_TB $PAD_MODEL $STD_MODEL)
    if (! -f "$file") then
        echo "ERROR: file not found: $file"
        exit 1
    endif
end

xrun -64bit \
     +delay_mode_zero \
     -notimingchecks \
     +max_err_count+50 \
     +define+function_sim \
     +define+uart_message_sim \
     -access +rwc \
     -profile \
     -profthread \
     -gui \
     -top tb_uart_top \
     "$UART_TB" \
     "$UART_NETLIST" \
     -v "$PAD_MODEL" \
     -v "$STD_MODEL" \
     -l uart_no_pad_func_pre.log

exit $status
