# UART standard-cell block VDD/VSS grid; no padPin or outer IO ring.
#restoreDesign uart_block_InitDesign.dat

globalNetConnect VDD -type pgpin -pin VDD -instanceBasename *
globalNetConnect VSS -type pgpin -pin VSS -instanceBasename *
globalNetConnect VDD -type tiehi -instanceBasename *
globalNetConnect VSS -type tielo -instanceBasename *
setTieHiLoMode -reset
setTieHiLoMode -cell {TIELO TIEHI} -honorDontTouch false -createHierPort false

# Core ring only. The 20um floorplan margin leaves room for this ring.
addRing -nets {VDD VSS} -type core_rings -follow core \
        -layer {top Metal11 bottom Metal11 left Metal10 right Metal10} \
        -width {top 2 bottom 2 left 2 right 2} \
        -spacing {top 2 bottom 2 left 2 right 2} \
        -offset {top 2 bottom 2 left 2 right 2}
sroute -connect {corePin} -nets {VDD VSS} \
       -layerChangeRange {Metal1(1) Metal11(11)} \
       -corePinTarget {firstAfterRowEnd} -allowJogging 1

# No PADVDD/PADVSS cells: this is a block for later top-level power hookup.
verifyConnectivity -type all -noAntenna -noWeakConnect \
                   -noUnConnPin -noUnroutedNet -error 1000 -warning 50
saveDesign -def uart_block_PowerPlan
#exit
