onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/clk
add wave -noupdate /top/test_clk
add wave -noupdate /top/dut/clk
add wave -noupdate /top/dut/load_en
add wave -noupdate /top/dut/reset_n
add wave -noupdate /top/dut/operand_a
add wave -noupdate /top/dut/operand_b
add wave -noupdate /top/dut/opcode
add wave -noupdate /top/dut/write_pointer
add wave -noupdate /top/dut/read_pointer
add wave -noupdate /top/dut/instruction_word
add wave -noupdate /top/test/seed
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {107104 ps}
