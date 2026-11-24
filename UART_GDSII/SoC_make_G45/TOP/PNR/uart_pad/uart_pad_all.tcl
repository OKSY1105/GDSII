# UART PAD PNR in one Innovus session. Run from TOP/PNR.

# ===== uart_pad_0_InitDesign.tcl =====
# UART PAD PNR. Run from TOP/PNR in a fresh Innovus legacy session.
# The synthesized netlist contains RX/TX signal pads; init.io adds physical PG pads.
set init_gnd_net VSS
set init_pwr_net VDD
set init_lef_file [list \
    /GPDK045/digital/gsclib045_all_v4.4/gsclib045_tech/lef/gsclib045_tech.lef \
    /GPDK045/digital/gsclib045_all_v4.4/gsclib045/lef/gsclib045_macro.lef \
    /GPDK045/digital/gsclib045_all_v4.4/gsclib045/lef/gsclib045_multibitsDFF.lef \
    /GPDK045/digital/giolib045_v3.5/lef/giolib045_modify.lef]
set init_verilog ../SYN/uart_mapped/uart_top_syn_final.v
set init_mmmc_file uart_pad/uart_pad.mmmc.view
set init_io_file uart_pad/uart_pad.init.io
set init_top_cell uart_top
foreach required [concat $init_lef_file [list $init_verilog $init_mmmc_file $init_io_file ../SYN/uart_mapped/uart_top_ss_syn_final.sdc]] {
    if {![file isfile $required]} {error "Missing UART PAD input: $required"}
}
file mkdir uart_pad_reports/checkDesign
init_design

# Four 240um corners plus five 60um pads require at least 780um die width.
# A 1760um die with 400um margins leaves room for the IO ring and core.
floorPlan -site CoreSite -d 1760 1760 400 400 400 400

# The IO file places RX/TX pads and the physical VDD/VSS/IO supply pads.
foreach side {n s w e} {
    addIoFiller -cell padIORINGFEED60 padIORINGFEED10 padIORINGFEED5 padIORINGFEED3 padIORINGFEED1 -prefix UART_PAD_FILLER -side $side
}
checkDesign -io -netlist -physicalLibrary -powerGround -tieHilo -timingLibrary -floorplan -outdir uart_pad_reports/checkDesign
saveDesign -def uart_pad_InitDesign


# ===== uart_pad_1_PowerPlan.tcl =====
# UART PAD power network. Run from TOP/PNR in a fresh Innovus session.

# IO supply nets do not occur as logical ports in the synthesized UART netlist.
addNet VDDIOR -power
addNet VSSIOR -ground
globalNetConnect VDD -type pgpin -pin VDD -instanceBasename *
globalNetConnect VSS -type pgpin -pin VSS -instanceBasename *
globalNetConnect VDDIOR -type pgpin -pin VDDIOR -instanceBasename *
globalNetConnect VSSIOR -type pgpin -pin VSSIOR -instanceBasename *
globalNetConnect VDD -type tiehi -instanceBasename *
globalNetConnect VSS -type tielo -instanceBasename *
setTieHiLoMode -reset
setTieHiLoMode -cell {TIELO TIEHI} -honorDontTouch false -createHierPort false

# One core ring connects standard-cell rails and the VDD/VSS pad pins.
addRing -nets {VDD VSS} -type core_rings -follow core \
        -layer {top Metal11 bottom Metal11 left Metal10 right Metal10} \
        -width {top 5 bottom 5 left 5 right 5} \
        -spacing {top 5 bottom 5 left 5 right 5} \
        -offset {top 5 bottom 5 left 5 right 5}
sroute -connect {corePin} -nets {VDD VSS} \
       -layerChangeRange {Metal1(1) Metal11(11)} \
       -corePinTarget {firstAfterRowEnd} -allowJogging 1
sroute -connect {padPin} -nets {VDD VSS} \
       -layerChangeRange {Metal1(1) Metal11(11)} \
       -padPinPortConnect {allPort oneGeom} -padPinTarget {nearestTarget} \
       -allowJogging 1

# IO supply rails are formed by abutting PAD and IO filler cells.
# Check physical connectivity before accepting this power network.
verifyConnectivity -type all -geomConnect -error 1000 -warning 50
saveDesign -def uart_pad_PowerPlan


# ===== uart_pad_2_PlaceOpt.tcl =====
######################################3
## Placement & Optimization
######################################3
# BUFX2 uses CoreSiteDouble, but this block has CoreSite rows only.
setDontUse BUFX2 true 
set_db place_global_cong_effort high

file mkdir uart_pad_reports/timing/preCTS

# First placement
place_design

# Check the Placement Density 
checkPlace uart_pad_reports/uart_top.checkPlace

# Early GlobalRoute :: analisys of Congestion and Timing after Placement 
setRouteMode -earlyGlobalMinRouteLayer 1 -earlyGlobalMaxRouteLayer 11 -earlyGlobalHonorMsvRouteConstraint false -earlyGlobalRoutePartitionPinGuide true
earlyGlobalRoute
reportCongestion -hotSpot
reportCongestion -overflow

# View Density Map 
setDrawView place
setLayerPreference densityMap -isVisible 1
setLayerPreference densityMap -isVisible 0

## View Pin Density Map
setLayerPreference pinDensityMap -isVisible 1
setLayerPreference pinDensityMap -isVisible 0

# Placement Optimization 
place_opt_design

# Early GlobalRoute :: analisys of Congestion and Timing after Placement 
earlyGlobalRoute
reportCongestion -hotSpot
reportCongestion -overflow

#Timing summary
timeDesign -preCTS -outDir uart_pad_reports/timing/preCTS

#checkDesign :: Density 
checkDesign -place

# If there is no error, Save Design
saveDesign -def uart_pad_PlaceOpt


# ===== uart_pad_3_PostCTSopt.tcl =====
########################################
# CTS & Optimization
########################################

setDontUse BUFX2 true
file mkdir uart_pad_reports/timing/postCTS uart_pad_reports/clock
# Target about skew
set_ccopt_property target_skew 0.01  

create_ccopt_clock_tree_spec
# CTS and report all timing WNS, TNS results
ccopt_design

# Propagated Clock
set_interactive_constraint_modes [all_constraint_modes -active] ;# set_propagated_clock command needs the existing mode is active  :: Mode is named FUNC and you can check with the command 'all_constraint_modes command'
set_propagated_clock [all_clocks]

# Check right-after CTS
timeDesign -postCTS -outDir uart_pad_reports/timing/postCTS
report_ccopt_clock_trees -file uart_pad_reports/clock/clock_trees.rpt
report_ccopt_skew_groups -file uart_pad_reports/clock/skew_groups.rpt
report_clock_timing -type skew -nworst 5 > uart_pad_reports/clock/skew.rpt

# Optimization of my design after CTS
optDesign -postCTS 	; # Setup/DRV concurrently
optDesign -postCTS -hold ;# Only for hold violation
timeDesign -postCTS -outDir uart_pad_reports/timing/postCTS
timeDesign -postCTS -hold -outDir uart_pad_reports/timing/postCTS

# If there is no error, Save Design
saveDesign -def uart_pad_PostCTSopt


# ===== uart_pad_4_RouteDesign_PowerAnalysis.tcl =====
##############
# Route
##############

setDontUse BUFX2 true
file mkdir uart_pad_reports/power uart_pad_reports/timing/postRoute

# Route Auto : To Detail
setNanoRouteMode -quiet -drouteFixAntenna 1
setNanoRouteMode -quiet -routeInsertAntennaDiode 0
setNanoRouteMode -quiet -routeWithTimingDriven 1
setNanoRouteMode -quiet -routeWithEco 0
setNanoRouteMode -quiet -routeWithLithoDriven 0
setNanoRouteMode -quiet -droutePostRouteLithoRepair 0
setNanoRouteMode -quiet -routeWithSiDriven 1
setNanoRouteMode -quiet -routeTdrEffort 8
setNanoRouteMode -quiet -drouteAutoStop 0
setNanoRouteMode -quiet -routeSelectedNetOnly 0
setNanoRouteMode -quiet -routeTopRoutingLayer 11
setNanoRouteMode -quiet -routeBottomRoutingLayer 1
setNanoRouteMode -quiet -drouteEndIteration 5
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
routeDesign -globalDetail

# DRC
get_verify_drc_mode -disable_rules -quiet
get_verify_drc_mode -quiet -area
get_verify_drc_mode -quiet -layer_range
get_verify_drc_mode -check_ndr_spacing -quiet
get_verify_drc_mode -check_only -quiet
get_verify_drc_mode -check_same_via_cell -quiet
get_verify_drc_mode -exclude_pg_net -quiet
get_verify_drc_mode -ignore_trial_route -quiet
get_verify_drc_mode -max_wrong_way_halo -quiet
get_verify_drc_mode -use_min_spacing_on_block_obs -quiet
get_verify_drc_mode -limit -quiet
set_verify_drc_mode -disable_rules {} -check_ndr_spacing auto -check_only default -check_same_via_cell true -exclude_pg_net false -ignore_trial_route false -ignore_cell_blockage false -use_min_spacing_on_block_obs auto -report uart_pad_reports/uart_top.drc.rpt -limit 1000

verify_drc
set_verify_drc_mode -area {0 0 0 0}

# Auto DRC Fix
setAnalysisMode -analysisType onChipVariation
optDesign -postRoute -drv ; # auto DRC Fix

# LVS : Connectivity 
verifyConnectivity -type all -geomConnect -error 1000 -warning 50

# Violation Browser
# GUI violation browser omitted in batch mode.

# Net Parasitic RC Extraction
extractRC

# Timing optimization
# smkcow
# Upper side, I suggest the below command to do auto fix DRC
# setAnalysisMode -analysisType onChipVariation 
#
# After that, I used the below <optDesign> command to make the design free about timing violations
# optDesign -postRoute -setup; # Optimization and resolve the Setup Violation 
# 
# However, optDesign command didn't do well so I decided to change analysisType to single 
# It was more helpful to make the design better

setDelayCalMode -SIAware false ; # Delete SI effect -> base delay is only used
setAnalysisMode -analysisType single -checkType setup ; # After change to single mode
optDesign -postRoute -setup; # 0 : Optimization and resolve the Setup Violation 

setAnalysisMode -analysisType single -checkType hold
optDesign -postRoute -hold; # 1 : Optimization and resolve the Hold Violation 

timeDesign -postRoute -outDir uart_pad_reports/timing/postRoute ; # Setup
timeDesign -postRoute -hold -outDir uart_pad_reports/timing/postRoute ; # Hold

# Recheck geometry and connectivity after timing optimization.
verify_drc
verifyConnectivity -type all -geomConnect -error 1000 -warning 50

# If there is no error, save Design
# option1 : innovus and tempus : It is useful to read design easily in Tempus
saveDesign -rc -def uart_pad_RouteDesign

# option2 : tempus -stylus
#saveDesign -rc -mmmc2 RouteDesign_mmmc2

#The current design in memory uses the MMMC1 format, and Stylus write_db can only save an MMMC2 format DB.  You should either use saveDesign -mmmc2 to save and convert it to MMMC2, or use Stylus read_db to auto-convert the MMMC1 DB to an MMMC2 DB when reading it into Stylus.

# without -stylus option : MMMC1 format
# with -stylus option : MMMC2 format
# Below command is for stylus 
#write_db -rc_extract postRoute


##################
# Power Analysis
##################

set_power_analysis_mode -reset

# You can switch some options :: analysis_view, corner
set_power_analysis_mode -method static -analysis_view FUNC_SS_WORST -corner max -create_binary_db true -write_static_currents true -honor_negative_energy true -ignore_control_signals true

## Once again : Global Net Connection
globalNetConnect VDD -type pgpin -pin VDD -instanceBasename *
globalNetConnect VSS -type pgpin -pin VSS -instanceBasename *
globalNetConnect VDD -type tiehi -instanceBasename *
globalNetConnect VSS -type tielo -instanceBasename *

set_power_output_dir -reset
set_power_output_dir ./uart_pad_reports/power ; 		#You can define the folder name
set_dynamic_power_simulation -reset ; 	# If you want to do the static power simulation
set_default_switching_activity -reset
set_default_switching_activity -input_activity 0.2 -period 10.0 ;# 8ns operation
read_activity_file -reset ; 		#If you don't have fsdb or vcd file, reset at here
set_power -reset
set_powerup_analysis -reset
report_power -rail_analysis_format VS -outfile ./uart_pad_reports/power/uart_top.rpt

########################
# Rail IR-DROP Analysis
########################
# There are Some Errors during Rail IR-drop report
# Skip This step 
# Alternatively, Use Voltus to Anlyze 
########################


# ===== uart_pad_5_ChipFinish.tcl =====
#######################
#### Chip Finish ######
#######################
file mkdir uart_pad_outputs uart_pad_reports/timing/final

# Add Filler
getFillerMode -quiet
addFiller -cell FILL1 FILL8 FILL64 FILL4 FILL32 FILL2 FILL16 -prefix FILLER
extractRC
verify_drc
verifyConnectivity -type all -geomConnect -error 1000 -warning 50
timeDesign -postRoute -outDir uart_pad_reports/timing/final
timeDesign -postRoute -hold -outDir uart_pad_reports/timing/final
# Inspect timing and DRC reports before accepting this GDS.
# If there is no error, save Design
saveDesign -rc -def uart_pad_ChipFinish

#####################
#### Write Out ######
#####################
# Write Out Files
# GDS file : without layermap file for GPDK045
streamOut uart_pad_outputs/uart_top_pad.gds -libName DesignLib -units 2000 -mode ALL

# Write Out Constraint
writeTimingCon uart_pad_outputs/uart_top_pad.sdc

# Netlist  file : -flat options is useful to next tool stages
saveNetlist -flat -excludeCellInst "PADVDD PADVSS PADVDDIOR PADVSSIOR" uart_pad_outputs/uart_top_pad.v

# SDF OUT, but I recommend to use sdf file which is from Tempus tool
# SDF version 3.0 :: RECREM included in the SDF file
write_sdf uart_pad_outputs/uart_top_pad.sdf

# SDF version 2.1
write_sdf -version 2.1 uart_pad_outputs/uart_top_pad.sdf_2.1

exit
