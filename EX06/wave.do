onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /shifter_tb/clk
add wave -noupdate /shifter_tb/ars
add wave -noupdate /shifter_tb/amt
add wave -noupdate /shifter_tb/src
add wave -noupdate /shifter_tb/res
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {470 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {577 ps} {641 ps}
