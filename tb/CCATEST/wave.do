onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_c/clk
add wave -noupdate /test_c/scaMain_inst/data_in
add wave -noupdate /test_c/scaMain_inst/data_valid
add wave -noupdate /test_c/scaMain_inst/data_table_wr_en
add wave -noupdate -radix unsigned /test_c/scaMain_inst/data_table_out_alt
add wave -noupdate -radix unsigned /test_c/scaMain_inst/image_x
add wave -noupdate -radix unsigned /test_c/scaMain_inst/image_y
add wave -noupdate /test_c/scaMain_inst/merger_stack_pop
add wave -noupdate /test_c/scaMain_inst/merger_stack_push
add wave -noupdate -radix unsigned /test_c/scaMain_inst/merger_stack_src_data_in
add wave -noupdate -radix unsigned /test_c/scaMain_inst/merger_stack_dst_data_in
add wave -noupdate -radix unsigned /test_c/scaMain_inst/merger_stack_src_data_out
add wave -noupdate -radix unsigned /test_c/scaMain_inst/merger_stack_dst_data_out
add wave -noupdate /test_c/scaMain_inst/ram_delay_counter
add wave -noupdate /test_c/scaMain_inst/rst_n
add wave -noupdate -radix unsigned /test_c/scaMain_inst/shift_reg_out_last_row_left
add wave -noupdate -radix unsigned /test_c/scaMain_inst/shift_reg_out_last_row_mid
add wave -noupdate -radix unsigned /test_c/scaMain_inst/shift_reg_out_last_row_right
add wave -noupdate -radix unsigned /test_c/scaMain_inst/shift_reg_out_current_row_last
add wave -noupdate -radix unsigned /test_c/scaMain_inst/shift_register_in
add wave -noupdate /test_c/scaMain_inst/shift_register_valid
add wave -noupdate -radix unsigned /test_c/scaMain_inst/label_merger_table_rd_addr_1
add wave -noupdate -radix unsigned /test_c/scaMain_inst/label_merger_table_rd_addr_2
add wave -noupdate -radix unsigned /test_c/scaMain_inst/label_merger_table_rd_data_1
add wave -noupdate -radix unsigned /test_c/scaMain_inst/label_merger_table_rd_data_2
add wave -noupdate -radix unsigned /test_c/scaMain_inst/PIC_A
add wave -noupdate -radix unsigned /test_c/scaMain_inst/PIC_B
add wave -noupdate -radix unsigned /test_c/scaMain_inst/PIC_C
add wave -noupdate -radix unsigned /test_c/scaMain_inst/PIC_D
add wave -noupdate /test_c/scaMain_inst/stack_empty
add wave -noupdate /test_c/scaMain_inst/stack_full
add wave -noupdate -radix unsigned /test_c/scaMain_inst/state
add wave -noupdate -radix unsigned /test_c/scaMain_inst/area_wr
add wave -noupdate -radix unsigned /test_c/scaMain_inst/x_max_wr
add wave -noupdate -radix unsigned /test_c/scaMain_inst/x_min_wr
add wave -noupdate -radix unsigned /test_c/scaMain_inst/y_max_wr
add wave -noupdate -radix unsigned /test_c/scaMain_inst/y_min_wr
add wave -noupdate -radix unsigned /test_c/scaMain_inst/area
add wave -noupdate -radix unsigned /test_c/scaMain_inst/x_max
add wave -noupdate -radix unsigned /test_c/scaMain_inst/x_min
add wave -noupdate -radix unsigned /test_c/scaMain_inst/y_max
add wave -noupdate -radix unsigned /test_c/scaMain_inst/y_min
add wave -noupdate -radix unsigned /test_c/scaMain_inst/area_alt
add wave -noupdate -radix unsigned /test_c/scaMain_inst/x_max_alt
add wave -noupdate -radix unsigned /test_c/scaMain_inst/x_min_alt
add wave -noupdate -radix unsigned /test_c/scaMain_inst/y_max_alt
add wave -noupdate -radix unsigned /test_c/scaMain_inst/y_min_alt
add wave -noupdate -radix unsigned /test_c/scaMain_inst/label_used_counter
add wave -noupdate -radix unsigned /test_c/scaMain_inst/data_table_inout_label
add wave -noupdate -radix unsigned /test_c/scaMain_inst/area_out
add wave -noupdate -radix unsigned /test_c/scaMain_inst/x_min_out
add wave -noupdate -radix unsigned /test_c/scaMain_inst/y_min_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14495970449 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 323
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
WaveRestoreZoom {14492669442 ps} {14514181934 ps}
