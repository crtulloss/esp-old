onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Sync_Signals
add wave -noupdate -label clk -radix hexadecimal /scverify_top/rtl/clk
add wave -noupdate -label Master_rst -radix hexadecimal /scverify_top/rst
add wave -noupdate -label cpp_testbench_active -radix hexadecimal /scverify_top/user_tb/cpp_testbench_active
add wave -noupdate -label rst -radix hexadecimal /scverify_top/rtl/rst
add wave -noupdate -divider DUT
add wave -noupdate -divider config
add wave -noupdate -label conf_info_rsc_dat -radix hexadecimal /scverify_top/rtl/conf_info_rsc_dat
add wave -noupdate -label conf_info_rsc_vld -radix hexadecimal /scverify_top/rtl/conf_info_rsc_vld
add wave -noupdate -label conf_info_rsc_rdy -radix hexadecimal /scverify_top/rtl/conf_info_rsc_rdy
add wave -noupdate -divider dma_read_ctrl
add wave -noupdate -label dma_read_ctrl_rsc_dat -radix hexadecimal /scverify_top/rtl/dma_read_ctrl_rsc_dat
add wave -noupdate -label dma_read_ctrl_rsc_vld -radix hexadecimal /scverify_top/rtl/dma_read_ctrl_rsc_vld
add wave -noupdate -label dma_read_ctrl_rsc_rdy -radix hexadecimal /scverify_top/rtl/dma_read_ctrl_rsc_rdy
add wave -noupdate -divider dma_read_chnl
add wave -noupdate -label dma_read_chnl_rsc_dat -radix hexadecimal /scverify_top/rtl/dma_read_chnl_rsc_dat
add wave -noupdate -label dma_read_chnl_rsc_vld -radix hexadecimal /scverify_top/rtl/dma_read_chnl_rsc_vld
add wave -noupdate -label dma_read_chnl_rsc_rdy -radix hexadecimal /scverify_top/rtl/dma_read_chnl_rsc_rdy
add wave -noupdate -divider dma_write_ctrl
add wave -noupdate -label dma_write_ctrl_rsc_dat -radix hexadecimal /scverify_top/rtl/dma_write_ctrl_rsc_dat
add wave -noupdate -label dma_write_ctrl_rsc_vld -radix hexadecimal /scverify_top/rtl/dma_write_ctrl_rsc_vld
add wave -noupdate -label dma_write_ctrl_rsc_rdy -radix hexadecimal /scverify_top/rtl/dma_write_ctrl_rsc_rdy
add wave -noupdate -divider dma_write_chnl
add wave -noupdate -label dma_write_chnl_rsc_dat -radix hexadecimal /scverify_top/rtl/dma_write_chnl_rsc_dat
add wave -noupdate -label dma_write_chnl_rsc_vld -radix hexadecimal /scverify_top/rtl/dma_write_chnl_rsc_vld
add wave -noupdate -label dma_write_chnl_rsc_rdy -radix hexadecimal /scverify_top/rtl/dma_write_chnl_rsc_rdy
add wave -noupdate -divider acc_done
add wave -noupdate -label acc_done_sync_vld -radix hexadecimal /scverify_top/rtl/acc_done_sync_vld
add wave -noupdate -divider debug
add wave -noupdate -label debug_rsc_dat -radix hexadecimal /scverify_top/rtl/debug_rsc_dat
add wave -noupdate -divider misc
add wave -noupdate -label debug_rsc_triosy_lz -radix hexadecimal /scverify_top/rtl/debug_rsc_triosy_lz
add wave -noupdate -divider OutputCompare
add wave -noupdate -color blue -label dma_read_ctrl_index-TRANS# -radix hexadecimal /scverify_top/user_tb/dma_read_ctrl_index_comp/_compare_cnt_sig
add wave -noupdate -label dma_read_ctrl_index-GOLDEN -radix hexadecimal /scverify_top/user_tb/dma_read_ctrl_index_comp/_golden_sig
add wave -noupdate -label dma_read_ctrl_index-DUT -radix hexadecimal /scverify_top/user_tb/dma_read_ctrl_index_comp/_dut_sig
add wave -noupdate -color red -label dma_read_ctrl_index-ERR# -radix hexadecimal /scverify_top/user_tb/dma_read_ctrl_index_comp/_error_cnt_sig
add wave -noupdate -color blue -label dma_read_ctrl_length-TRANS# -radix hexadecimal /scverify_top/user_tb/dma_read_ctrl_length_comp/_compare_cnt_sig
add wave -noupdate -label dma_read_ctrl_length-GOLDEN -radix hexadecimal /scverify_top/user_tb/dma_read_ctrl_length_comp/_golden_sig
add wave -noupdate -label dma_read_ctrl_length-DUT -radix hexadecimal /scverify_top/user_tb/dma_read_ctrl_length_comp/_dut_sig
add wave -noupdate -color red -label dma_read_ctrl_length-ERR# -radix hexadecimal /scverify_top/user_tb/dma_read_ctrl_length_comp/_error_cnt_sig
add wave -noupdate -color blue -label dma_read_ctrl_size-TRANS# -radix hexadecimal /scverify_top/user_tb/dma_read_ctrl_size_comp/_compare_cnt_sig
add wave -noupdate -label dma_read_ctrl_size-GOLDEN -radix hexadecimal /scverify_top/user_tb/dma_read_ctrl_size_comp/_golden_sig
add wave -noupdate -label dma_read_ctrl_size-DUT -radix hexadecimal /scverify_top/user_tb/dma_read_ctrl_size_comp/_dut_sig
add wave -noupdate -color red -label dma_read_ctrl_size-ERR# -radix hexadecimal /scverify_top/user_tb/dma_read_ctrl_size_comp/_error_cnt_sig
add wave -noupdate -color blue -label dma_write_ctrl_index-TRANS# -radix hexadecimal /scverify_top/user_tb/dma_write_ctrl_index_comp/_compare_cnt_sig
add wave -noupdate -label dma_write_ctrl_index-GOLDEN -radix hexadecimal /scverify_top/user_tb/dma_write_ctrl_index_comp/_golden_sig
add wave -noupdate -label dma_write_ctrl_index-DUT -radix hexadecimal /scverify_top/user_tb/dma_write_ctrl_index_comp/_dut_sig
add wave -noupdate -color red -label dma_write_ctrl_index-ERR# -radix hexadecimal /scverify_top/user_tb/dma_write_ctrl_index_comp/_error_cnt_sig
add wave -noupdate -color blue -label dma_write_ctrl_length-TRANS# -radix hexadecimal /scverify_top/user_tb/dma_write_ctrl_length_comp/_compare_cnt_sig
add wave -noupdate -label dma_write_ctrl_length-GOLDEN -radix hexadecimal /scverify_top/user_tb/dma_write_ctrl_length_comp/_golden_sig
add wave -noupdate -label dma_write_ctrl_length-DUT -radix hexadecimal /scverify_top/user_tb/dma_write_ctrl_length_comp/_dut_sig
add wave -noupdate -color red -label dma_write_ctrl_length-ERR# -radix hexadecimal /scverify_top/user_tb/dma_write_ctrl_length_comp/_error_cnt_sig
add wave -noupdate -color blue -label dma_write_ctrl_size-TRANS# -radix hexadecimal /scverify_top/user_tb/dma_write_ctrl_size_comp/_compare_cnt_sig
add wave -noupdate -label dma_write_ctrl_size-GOLDEN -radix hexadecimal /scverify_top/user_tb/dma_write_ctrl_size_comp/_golden_sig
add wave -noupdate -label dma_write_ctrl_size-DUT -radix hexadecimal /scverify_top/user_tb/dma_write_ctrl_size_comp/_dut_sig
add wave -noupdate -color red -label dma_write_ctrl_size-ERR# -radix hexadecimal /scverify_top/user_tb/dma_write_ctrl_size_comp/_error_cnt_sig
add wave -noupdate -color blue -label dma_write_chnl-TRANS# -radix hexadecimal /scverify_top/user_tb/dma_write_chnl_comp/_compare_cnt_sig
add wave -noupdate -label dma_write_chnl-GOLDEN -radix hexadecimal /scverify_top/user_tb/dma_write_chnl_comp/_golden_sig
add wave -noupdate -label dma_write_chnl-DUT -radix hexadecimal /scverify_top/user_tb/dma_write_chnl_comp/_dut_sig
add wave -noupdate -color red -label dma_write_chnl-ERR# -radix hexadecimal /scverify_top/user_tb/dma_write_chnl_comp/_error_cnt_sig
add wave -noupdate -color blue -label debug-TRANS# -radix hexadecimal /scverify_top/user_tb/debug_comp/_compare_cnt_sig
add wave -noupdate -label debug-GOLDEN -radix hexadecimal /scverify_top/user_tb/debug_comp/_golden_sig
add wave -noupdate -label debug-DUT -radix hexadecimal /scverify_top/user_tb/debug_comp/_dut_sig
add wave -noupdate -color red -label debug-ERR# -radix hexadecimal /scverify_top/user_tb/debug_comp/_error_cnt_sig
add wave -noupdate -divider Active_Processes
add wave -noupdate -label softmax_cxx_struct_inst/softmax_cxx_core_inst -radix hexadecimal /scverify_top/rtl/softmax_cxx_struct_inst/softmax_cxx_core_inst/softmax_cxx_core_staller_inst/core_wen
add wave -noupdate -label deadlock -radix hexadecimal /scverify_top/deadlocked
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {396539 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 263
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ps} {2812950 ps}
