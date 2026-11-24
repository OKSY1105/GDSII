#######################
#### Chip Finish ######
#######################
restoreDesign mcu_uart_RouteDesign.dat

# Add Filler
getFillerMode -quiet
addFiller -cell FILL1 FILL8 FILL64 FILL4 FILL32 FILL2 FILL16 -prefix FILLER

# DRC
verify_drc

# LVS : Connectivity 
clearDrc
# Exclude GPDK045 giolib045 LEF IO-ring pass-through PG pins (PADVDD:VDD, PADVSS:VSS, all signals stay checked)
set ioRingPgPins {PADVDD:VSS PADVDD:VDDIOR PADVDD:VSSIOR PADVSS:VDD PADVSS:VDDIOR PADVSS:VSSIOR}
foreach cell {PADDI PADDO PADDB PADVDDIOR PADVSSIOR padIORINGCORNER} {
    foreach pin {VDD VSS VDDIOR VSSIOR} {lappend ioRingPgPins $cell:$pin}
}
foreach cell {padIORINGFEED60 padIORINGFEED10 padIORINGFEED5 padIORINGFEED3 padIORINGFEED1} {
    foreach pin {VDD VSS} {lappend ioRingPgPins $cell:$pin}
}
verifyConnectivity -type all -geomConnect -error 1000 -warning 50 -ignorePGPin $ioRingPgPins

# Error Browser
setLayerPreference violation -isVisible 1
violationBrowser -all -no_display_false -displayByLayer

# Extraction 
extractRC

# If there is no error, save Design
saveDesign -rc -def mcu_uart_ChipFinish

#####################
#### Write Out ######
#####################
# Write Out Files

# Netlist  file : -flat options is useful to next tool stages
saveNetlist -flat -excludeCellInst "PADVDD PADVSS PADVSSIOR PADVDDIOR" mcu_uart.v

# SDF OUT, but I recommend to use sdf file which is from Tempus tool
# SDF version 3.0 :: RECREM included in the SDF file
write_sdf mcu_uart.sdf

# SDF version 2.1
write_sdf -version 2.1 mcu_uart.sdf_2.1

# Write Out Constraint
writeTimingCon mcu_uart.sdc

# GDS file : without layermap file for GPDK045
streamOut mcu_uart.gds -libName DesignLib -units 2000 -mode ALL

exit
