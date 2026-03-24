onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /shift_reg_test/clk
add wave -noupdate -radix unsigned /shift_reg_test/data_in
add wave -noupdate -radix unsigned /shift_reg_test/data_out_last_row_left
add wave -noupdate -radix unsigned /shift_reg_test/data_out_last_row_mid
add wave -noupdate -radix unsigned /shift_reg_test/data_out_last_row_right
add wave -noupdate -radix unsigned /shift_reg_test/shift_reg_inst/data_out_current_row_left
add wave -noupdate /shift_reg_test/data_valid
add wave -noupdate /shift_reg_test/rst_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {230 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 256
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
configure wave -timelineunits ns
update
WaveRestoreZoom {133 ns} {290 ns}
