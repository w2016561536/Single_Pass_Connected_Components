onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /stackTesttb/clk
add wave -noupdate -radix hexadecimal /stackTesttb/data_in_dst
add wave -noupdate -radix hexadecimal /stackTesttb/data_in_src
add wave -noupdate -radix hexadecimal /stackTesttb/data_out_dst
add wave -noupdate -radix hexadecimal /stackTesttb/data_out_src
add wave -noupdate /stackTesttb/pop
add wave -noupdate /stackTesttb/push
add wave -noupdate /stackTesttb/rst_n
add wave -noupdate /stackTesttb/merger_stack_inst/empty
add wave -noupdate /stackTesttb/merger_stack_inst/full
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 ps} {1 ns}
