onerror {resume}
quietly virtual function -install /t_receive/DUT -env /t_receive/DUT { &{/t_receive/DUT/RBufShiftReg, /t_receive/DUT/RBufShiftReg[3], /t_receive/DUT/RBufShiftReg[2], /t_receive/DUT/RBufShiftReg[1], /t_receive/DUT/RBufShiftReg[0] }} RBufShiftReg_ls4
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Orange /t_receive/Clk
add wave -noupdate -color Orange /t_receive/DUT/Clk
add wave -noupdate -color Orange /t_receive/DUT/Reset
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -radix hexadecimal -radixshowbase 0 /t_receive/ExpectedDataOut
add wave -noupdate -radix hexadecimal -radixshowbase 0 /t_receive/DataOut
add wave -noupdate /t_receive/SerData
add wave -noupdate /t_receive/DUT/StartOp
add wave -noupdate /t_receive/DUT/SerData
add wave -noupdate /t_receive/DUT/DataValid
add wave -noupdate /t_receive/DUT/DataOut
add wave -noupdate -radix unsigned -radixshowbase 0 /t_receive/DUT/State
add wave -noupdate -radix unsigned -radixshowbase 0 /t_receive/DUT/NextState
add wave -noupdate /t_receive/DUT/RBufShiftReg_ls4
add wave -noupdate -radix hexadecimal -childformat {{{/t_receive/DUT/RBufShiftReg[7]} -radix hexadecimal} {{/t_receive/DUT/RBufShiftReg[6]} -radix hexadecimal} {{/t_receive/DUT/RBufShiftReg[5]} -radix hexadecimal} {{/t_receive/DUT/RBufShiftReg[4]} -radix hexadecimal} {{/t_receive/DUT/RBufShiftReg[3]} -radix hexadecimal} {{/t_receive/DUT/RBufShiftReg[2]} -radix hexadecimal} {{/t_receive/DUT/RBufShiftReg[1]} -radix hexadecimal} {{/t_receive/DUT/RBufShiftReg[0]} -radix hexadecimal}} -radixshowbase 0 -expand -subitemconfig {{/t_receive/DUT/RBufShiftReg[7]} {-radix hexadecimal -radixshowbase 0} {/t_receive/DUT/RBufShiftReg[6]} {-radix hexadecimal -radixshowbase 0} {/t_receive/DUT/RBufShiftReg[5]} {-radix hexadecimal -radixshowbase 0} {/t_receive/DUT/RBufShiftReg[4]} {-radix hexadecimal -radixshowbase 0} {/t_receive/DUT/RBufShiftReg[3]} {-radix hexadecimal -radixshowbase 0} {/t_receive/DUT/RBufShiftReg[2]} {-radix hexadecimal -radixshowbase 0} {/t_receive/DUT/RBufShiftReg[1]} {-radix hexadecimal -radixshowbase 0} {/t_receive/DUT/RBufShiftReg[0]} {-radix hexadecimal -radixshowbase 0}} /t_receive/DUT/RBufShiftReg
add wave -noupdate /t_receive/DUT/RBufLoad
add wave -noupdate /t_receive/DUT/RBufShift
add wave -noupdate -divider -height 30 {DUT Signals}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {StartOp {700 ns} 1} {{Cursor 2} {530 ns} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {0 ns} {2100 ns}
