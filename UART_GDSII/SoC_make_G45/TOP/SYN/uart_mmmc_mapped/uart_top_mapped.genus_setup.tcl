################################################################################
#
# Genus(TM) Synthesis Solution setup file
# Created by Genus(TM) Synthesis Solution 22.17-s071_1
#   on 11/12/2026 07:20:30
#
# This file can only be run in Genus Common UI mode.
#
################################################################################


# This script is intended for use with Genus(TM) Synthesis Solution version 22.17-s071_1


# Remove Existing Design
################################################################################
if {[::legacy::find -design design:uart_top] ne ""} {
  puts "** A design with the same name is already loaded. It will be removed. **"
  delete_obj design:uart_top
}


# To allow user-readonly attributes
################################################################################
::legacy::set_attribute -quiet force_tui_is_remote 1 /

phys::read_script ./uart_mmmc_mapped/uart_top_mapped.root.g


# Source INIT Setup file
################################################################################
source ./uart_mmmc_mapped/uart_top_mapped.genus_init.tcl
read_metric -id current ./uart_mmmc_mapped/uart_top_mapped.metrics.json

phys::read_script ./uart_mmmc_mapped/uart_top_mapped.g

phys::read_lec_taf ./uart_mmmc_mapped/uart_top_mapped.lec.taf.gz
phys::read_taf ./uart_mmmc_mapped/uart_top_mapped.safety.taf.gz
puts "\n** Restoration Completed **\n"


# Data Integrity Check
################################################################################
# program version
if {"[string_representation [::legacy::get_attribute program_version /]]" != "22.17-s071_1"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-91] "golden program_version: 22.17-s071_1  current program_version: [string_representation [::legacy::get_attribute program_version /]]"
}
# license
if {"[string_representation [::legacy::get_attribute startup_license /]]" != "Genus_Synthesis"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-91] "golden license: Genus_Synthesis  current license: [string_representation [::legacy::get_attribute startup_license /]]"
}
# slack
set _slk_ [::legacy::get_attribute slack design:uart_top]
if {[regexp {^-?[0-9.]+$} $_slk_]} {
  set _slk_ [format %.1f $_slk_]
}
if {$_slk_ != "7079.6"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-92] "golden slack: 7079.6,  current slack: $_slk_"
}
unset _slk_
# multi-mode slack
if {"[string_representation [::legacy::get_attribute slack_by_mode design:uart_top]]" != "{{mode:uart_top/UART_SS_WORST 7079.6} {mode:uart_top/UART_FF_BEST 9295.5}}"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-92] "golden slack_by_mode: {{mode:uart_top/UART_SS_WORST 7079.6} {mode:uart_top/UART_FF_BEST 9295.5}}  current slack_by_mode: [string_representation [::legacy::get_attribute slack_by_mode design:uart_top]]"
}
# tns
set _tns_ [::legacy::get_attribute tns design:uart_top]
if {[regexp {^-?[0-9.]+$} $_tns_]} {
  set _tns_ [format %.0f $_tns_]
}
if {$_tns_ != "0"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-92] "golden tns: 0,  current tns: $_tns_"
}
unset _tns_
# cell area
set _cell_area_ [::legacy::get_attribute cell_area design:uart_top]
if {[regexp {^-?[0-9.]+$} $_cell_area_]} {
  set _cell_area_ [format %.0f $_cell_area_]
}
if {$_cell_area_ != "32652"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-92] "golden cell area: 32652,  current cell area: $_cell_area_"
}
unset _cell_area_
# net area
set _net_area_ [::legacy::get_attribute net_area design:uart_top]
if {[regexp {^-?[0-9.]+$} $_net_area_]} {
  set _net_area_ [format %.0f $_net_area_]
}
if {$_net_area_ != "1071"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-92] "golden net area: 1071,  current net area: $_net_area_"
}
unset _net_area_
# library domain count
if {[llength [::legacy::find /libraries -library_domain *]] != "2"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-92] "golden # library domains: 2  current # library domains: [llength [::legacy::find /libraries -library_domain *]]"
}
