#################################################################################
#
# Created by Genus(TM) Synthesis Solution 22.17-s071_1 on Thu Nov 12 07:34:36 KST 2026
#
#################################################################################

## library_sets
create_library_set -name UART_FF_LIBS \
    -timing { /GPDK045/digital/gsclib045_all_v4.4/gsclib045/timing/fast_vdd1v0_basicCells.lib \
              /GPDK045/digital/gsclib045_all_v4.4/gsclib045/timing/fast_vdd1v0_multibitsDFF.lib \
              /GPDK045/digital/giolib045_v3.5/timing/pads_FF_s1vg.lib }
create_library_set -name UART_SS_LIBS \
    -timing { /GPDK045/digital/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v0_basicCells.lib \
              /GPDK045/digital/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v0_multibitsDFF.lib \
              /GPDK045/digital/giolib045_v3.5/timing/pads_SS_s1vg.lib }

## opcond
create_opcond -name UART_FF_OPCOND \
    -process 1.0 \
    -voltage 1.1 \
    -temperature 0.0
create_opcond -name UART_SS_OPCOND \
    -process 1.0 \
    -voltage 0.9 \
    -temperature 125.0

## timing_condition
create_timing_condition -name UART_FF_TIMING \
    -opcond UART_FF_OPCOND \
    -library_sets { UART_FF_LIBS }
create_timing_condition -name UART_SS_TIMING \
    -opcond UART_SS_OPCOND \
    -library_sets { UART_SS_LIBS }

## rc_corner
create_rc_corner -name UART_RC \
    -qrc_tech /GPDK045/digital/gsclib045_all_v4.4/gsclib045_tech/qrc/qx/gpdk045.tch \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0} \
    -post_route_clock_cross_cap {1.0 1.0 1.0}

## delay_corner
create_delay_corner -name UART_FF_CORNER \
    -early_timing_condition { UART_FF_TIMING } \
    -late_timing_condition { UART_FF_TIMING } \
    -early_rc_corner UART_RC \
    -late_rc_corner UART_RC
create_delay_corner -name UART_SS_CORNER \
    -early_timing_condition { UART_SS_TIMING } \
    -late_timing_condition { UART_SS_TIMING } \
    -early_rc_corner UART_RC \
    -late_rc_corner UART_RC

## constraint_mode
create_constraint_mode -name UART_FUNC \
    -sdc_files { ./uart_mapped/uart_top_mapped.UART_FUNC.sdc }

## analysis_view
create_analysis_view -name UART_FF_BEST \
    -constraint_mode UART_FUNC \
    -delay_corner UART_FF_CORNER
create_analysis_view -name UART_SS_WORST \
    -constraint_mode UART_FUNC \
    -delay_corner UART_SS_CORNER

## set_analysis_view
set_analysis_view -setup { UART_SS_WORST UART_FF_BEST } \
                  -hold { UART_FF_BEST }
