################################################################################
#
# Init setup file
# Created by Genus(TM) Synthesis Solution on 11/12/2026 07:20:30
#
################################################################################
if { ![is_common_ui_mode] } { error "ERROR: This script requires common_ui to be active."}
::legacy::set_attribute -quiet init_mmmc_version 2 /

read_mmmc ./uart_mmmc_mapped/uart_top_mapped.mmmc.tcl

read_physical -lef {/GPDK045/digital/gsclib045_all_v4.4/gsclib045/lef/gsclib045_tech.lef /GPDK045/digital/gsclib045_all_v4.4/gsclib045/lef/gsclib045_macro.lef /GPDK045/digital/giolib045_v3.5/lef/giolib045.lef}

read_netlist ./uart_mmmc_mapped/uart_top_mapped.v

init_design
