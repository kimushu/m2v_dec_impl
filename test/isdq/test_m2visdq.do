onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_m2visdq/u_dut/clk
add wave -noupdate /test_m2visdq/u_dut/reset_n
add wave -noupdate /test_m2visdq/u_dut/softreset
add wave -noupdate /test_m2visdq/u_dut/ready_isdq
add wave -noupdate /test_m2visdq/u_dut/block_start
add wave -noupdate /test_m2visdq/u_dut/block_end
add wave -noupdate /test_m2visdq/u_dut/s1_enable
add wave -noupdate /test_m2visdq/u_dut/s1_coded
add wave -noupdate /test_m2visdq/u_dut/s1_mb_intra
add wave -noupdate /test_m2visdq/u_dut/s1_mb_qscode
add wave -noupdate /test_m2visdq/u_dut/sa_qstype
add wave -noupdate /test_m2visdq/u_dut/sa_dcprec
add wave -noupdate -radix unsigned /test_m2visdq/u_dut/run
add wave -noupdate /test_m2visdq/u_dut/level_sign
add wave -noupdate -radix unsigned /test_m2visdq/u_dut/level_data
add wave -noupdate /test_m2visdq/u_dut/rl_valid
add wave -noupdate /test_m2visdq/u_dut/qm_valid
add wave -noupdate /test_m2visdq/u_dut/qm_custom
add wave -noupdate /test_m2visdq/u_dut/qm_intra
add wave -noupdate /test_m2visdq/u_dut/qm_value
add wave -noupdate /test_m2visdq/u_dut/coef_sign
add wave -noupdate -radix unsigned /test_m2visdq/u_dut/coef_data
add wave -noupdate /test_m2visdq/u_dut/coef_next
add wave -noupdate /test_m2visdq/u_dut/state_r
add wave -noupdate /test_m2visdq/u_dut/cust_qm_ni_r
add wave -noupdate /test_m2visdq/u_dut/cust_qm_i_r
add wave -noupdate -radix unsigned /test_m2visdq/u_dut/qscale_r
add wave -noupdate -radix unsigned /test_m2visdq/u_dut/wpos_r
add wave -noupdate -radix unsigned /test_m2visdq/u_dut/rpos_r
add wave -noupdate /test_m2visdq/u_dut/wpage_r
add wave -noupdate /test_m2visdq/u_dut/empty_r
add wave -noupdate /test_m2visdq/u_dut/cvalid_r
add wave -noupdate /test_m2visdq/u_dut/clrcoef_r
add wave -noupdate /test_m2visdq/u_dut/mismatch_r
add wave -noupdate /test_m2visdq/u_dut/lastcoef_r
add wave -noupdate /test_m2visdq/u_dut/start_blk_1d_r
add wave -noupdate /test_m2visdq/u_dut/end_blk_r
add wave -noupdate /test_m2visdq/u_dut/rlv_d_r
add wave -noupdate /test_m2visdq/u_dut/sign_d_r
add wave -noupdate /test_m2visdq/u_dut/head_pair_r
add wave -noupdate /test_m2visdq/u_dut/mult_cache_r
add wave -noupdate /test_m2visdq/u_dut/ovf_r
add wave -noupdate /test_m2visdq/u_dut/end_blkstate_w
add wave -noupdate /test_m2visdq/u_dut/next_wpos_w
add wave -noupdate /test_m2visdq/u_dut/next_rpos_w
add wave -noupdate /test_m2visdq/u_dut/cmem_addr_w
add wave -noupdate /test_m2visdq/u_dut/cmem_dout_w
add wave -noupdate /test_m2visdq/u_dut/dmem_doutb_w
add wave -noupdate /test_m2visdq/u_dut/dc_mult_w
add wave -noupdate /test_m2visdq/u_dut/mult_a_w
add wave -noupdate /test_m2visdq/u_dut/mult_b_w
add wave -noupdate /test_m2visdq/u_dut/mult_result_w
add wave -noupdate /test_m2visdq/u_dut/clipped_w
add wave -noupdate -radix ascii /test_m2visdq/u_dut/state_name
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1710000 ps} 0}
configure wave -namecolwidth 150
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
configure wave -timelineunits ps
update
WaveRestoreZoom {1209900 ps} {2419597 ps}
