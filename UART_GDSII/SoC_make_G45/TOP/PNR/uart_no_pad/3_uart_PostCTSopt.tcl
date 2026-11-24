########################################
# CTS & Optimization
########################################

#restoreDesign uart_PlaceOpt.dat
setDontUse BUFX2 true
file mkdir uart_block_reports/timing/postCTS uart_block_reports/clock
# Target about skew
set_ccopt_property target_skew 0.01  

create_ccopt_clock_tree_spec
# CTS and report all timing WNS, TNS results
ccopt_design

# Propagated Clock
set_interactive_constraint_modes [all_constraint_modes -active] ;# set_propagated_clock command needs the existing mode is active  :: Mode is named FUNC and you can check with the command 'all_constraint_modes command'
set_propagated_clock [all_clocks]

# Check right-after CTS
timeDesign -postCTS -outDir uart_block_reports/timing/postCTS
report_ccopt_clock_trees -file uart_block_reports/clock/clock_trees.rpt
report_ccopt_skew_groups -file uart_block_reports/clock/skew_groups.rpt
report_clock_timing -type skew -nworst 5 > uart_block_reports/clock/skew.rpt

# Optimization of my design after CTS
optDesign -postCTS 	; # Setup/DRV concurrently
optDesign -postCTS -hold ;# Only for hold violation
timeDesign -postCTS -outDir uart_block_reports/timing/postCTS
timeDesign -postCTS -hold -outDir uart_block_reports/timing/postCTS

# If there is no error, Save Design
saveDesign -def uart_block_PostCTSopt

#exit
