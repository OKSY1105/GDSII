#######################
#### Chip Finish ######
#######################
#restoreDesign uart_RouteDesign.dat
file mkdir uart_block_outputs uart_block_reports/timing/final

# Add Filler
getFillerMode -quiet
addFiller -cell FILL1 FILL8 FILL64 FILL4 FILL32 FILL2 FILL16 -prefix FILLER
extractRC
verify_drc
verifyConnectivity -type all -geomConnect -error 1000 -warning 50
timeDesign -postRoute -outDir uart_block_reports/timing/final
timeDesign -postRoute -hold -outDir uart_block_reports/timing/final
# Inspect timing and DRC reports before accepting this GDS.
# If there is no error, save Design
saveDesign -rc -def uart_block_ChipFinish

#####################
#### Write Out ######
#####################
# Write Out Files
# GDS file : without layermap file for GPDK045
streamOut uart_block_outputs/uart_top_block.gds -libName DesignLib -units 2000 -mode ALL

# Write Out Constraint
writeTimingCon uart_block_outputs/uart_top_block.sdc

# Netlist  file : -flat options is useful to next tool stages
saveNetlist -flat uart_block_outputs/uart_top_block.v

# SDF OUT, but I recommend to use sdf file which is from Tempus tool
# SDF version 3.0 :: RECREM included in the SDF file
write_sdf uart_block_outputs/uart_top_block.sdf

# SDF version 2.1
write_sdf -version 2.1 uart_block_outputs/uart_top_block.sdf_2.1
