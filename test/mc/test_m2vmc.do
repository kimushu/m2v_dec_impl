onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_m2vmc/u_dut/clk
add wave -noupdate /test_m2vmc/u_dut/reset_n
add wave -noupdate /test_m2vmc/u_dut/softreset
add wave -noupdate /test_m2vmc/u_dut/ready_mc
add wave -noupdate /test_m2vmc/u_dut/block_start
add wave -noupdate /test_m2vmc/u_dut/picture_complete
add wave -noupdate /test_m2vmc/u_dut/pixel_coded
add wave -noupdate -radix unsigned /test_m2vmc/u_dut/pixel_addr
add wave -noupdate -radix decimal /test_m2vmc/u_dut/pixel_data0
add wave -noupdate -radix decimal /test_m2vmc/u_dut/pixel_data1
add wave -noupdate /test_m2vmc/u_dut/sa_iframe
add wave -noupdate -radix decimal /test_m2vmc/u_dut/s3_mv_h
add wave -noupdate -radix decimal /test_m2vmc/u_dut/s3_mv_v
add wave -noupdate -radix unsigned /test_m2vmc/u_dut/s3_mb_x
add wave -noupdate -radix unsigned /test_m2vmc/u_dut/s3_mb_y
add wave -noupdate /test_m2vmc/u_dut/s3_mb_intra
add wave -noupdate -radix unsigned /test_m2vmc/u_dut/s3_block
add wave -noupdate /test_m2vmc/u_dut/s3_coded
add wave -noupdate /test_m2vmc/u_dut/s3_enable
add wave -noupdate -radix unsigned /test_m2vmc/u_dut/s4_mb_x
add wave -noupdate -radix unsigned /test_m2vmc/u_dut/s4_mb_y
add wave -noupdate /test_m2vmc/u_dut/s4_mb_intra
add wave -noupdate -radix unsigned /test_m2vmc/u_dut/s4_block
add wave -noupdate /test_m2vmc/u_dut/s4_coded
add wave -noupdate /test_m2vmc/u_dut/s4_enable
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/fbuf_address
add wave -noupdate /test_m2vmc/u_dut/fbuf_read
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/fbuf_readdata
add wave -noupdate /test_m2vmc/u_dut/fbuf_write
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/fbuf_writedata
add wave -noupdate /test_m2vmc/u_dut/fbuf_waitrequest
add wave -noupdate /test_m2vmc/u_dut/fbuf_readdatavalid
add wave -noupdate /test_m2vmc/u_dut/fptr_address
add wave -noupdate /test_m2vmc/u_dut/fptr_updated
add wave -noupdate /test_m2vmc/u_dut/fptr_number
add wave -noupdate /test_m2vmc/u_dut/state_r
add wave -noupdate -radix ascii /test_m2vmc/u_dut/state_name
add wave -noupdate /test_m2vmc/u_dut/xhalf_r
add wave -noupdate /test_m2vmc/u_dut/xodd_r
add wave -noupdate /test_m2vmc/u_dut/yhalf_r
add wave -noupdate /test_m2vmc/u_dut/fptr_fetch_w
add wave -noupdate -radix unsigned /test_m2vmc/u_dut/xref_r
add wave -noupdate -radix unsigned /test_m2vmc/u_dut/yref_r
add wave -noupdate /test_m2vmc/u_dut/rxcnt_r
add wave -noupdate /test_m2vmc/u_dut/rycnt_r
add wave -noupdate /test_m2vmc/u_dut/xref_1d_r
add wave -noupdate /test_m2vmc/u_dut/yref_1d_r
add wave -noupdate /test_m2vmc/u_dut/fptr_fetch_1d_r
add wave -noupdate /test_m2vmc/u_dut/use_1d_fptr_r
add wave -noupdate /test_m2vmc/u_dut/fren_r
add wave -noupdate /test_m2vmc/u_dut/xraa_w
add wave -noupdate /test_m2vmc/u_dut/xrab_w
add wave -noupdate /test_m2vmc/u_dut/xrac_w
add wave -noupdate /test_m2vmc/u_dut/xrar_w
add wave -noupdate /test_m2vmc/u_dut/yraa_w
add wave -noupdate /test_m2vmc/u_dut/yrab_w
add wave -noupdate /test_m2vmc/u_dut/yrac_w
add wave -noupdate /test_m2vmc/u_dut/yrar_w
add wave -noupdate /test_m2vmc/u_dut/fptr_fetch_wait_w
add wave -noupdate /test_m2vmc/u_dut/frmbyx_w
add wave -noupdate /test_m2vmc/u_dut/fb_fraddr_w
add wave -noupdate /test_m2vmc/u_dut/wxcnt_r
add wave -noupdate /test_m2vmc/u_dut/wycnt_r
add wave -noupdate /test_m2vmc/u_dut/wxcnt_1d_r
add wave -noupdate /test_m2vmc/u_dut/wycnt_1d_r
add wave -noupdate /test_m2vmc/u_dut/px1_1d_r
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/i0ram_r
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/i1ram_r
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/px0_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/px1_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/i0out_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/i1out_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/sum0a_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/sum0b_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/sum0r_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/sum1a_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/sum1b_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/sum1r_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/sum2a_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/sum2b_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/sum2r_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/sum3a_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/sum3b_w
add wave -noupdate -radix hexadecimal /test_m2vmc/u_dut/sum3r_w
add wave -noupdate /test_m2vmc/u_dut/fwaddr0_w
add wave -noupdate /test_m2vmc/u_dut/fwaddr1_w
add wave -noupdate /test_m2vmc/u_dut/fwxen0_w
add wave -noupdate /test_m2vmc/u_dut/fwxen1_w
add wave -noupdate /test_m2vmc/u_dut/fwen0_w
add wave -noupdate /test_m2vmc/u_dut/fwen1_w
add wave -noupdate /test_m2vmc/u_dut/mraddr_r
add wave -noupdate /test_m2vmc/u_dut/mrlast_r
add wave -noupdate /test_m2vmc/u_dut/mwaddr_r
add wave -noupdate /test_m2vmc/u_dut/mwen_r
add wave -noupdate /test_m2vmc/u_dut/waitreq_1d_r
add wave -noupdate /test_m2vmc/u_dut/next_mraddr_w
add wave -noupdate /test_m2vmc/u_dut/mrdata0_w
add wave -noupdate /test_m2vmc/u_dut/mrdata1_w
add wave -noupdate /test_m2vmc/u_dut/p0sum_w
add wave -noupdate /test_m2vmc/u_dut/p1sum_w
add wave -noupdate /test_m2vmc/u_dut/p0clip_w
add wave -noupdate /test_m2vmc/u_dut/p1clip_w
add wave -noupdate /test_m2vmc/u_dut/p0clip_r
add wave -noupdate /test_m2vmc/u_dut/p1clip_r
add wave -noupdate /test_m2vmc/u_dut/mwmbyx_w
add wave -noupdate /test_m2vmc/u_dut/fb_mwaddr_w
add wave -noupdate /test_m2vmc/u_dut/fptr_mix_w
add wave -noupdate /test_m2vmc/u_dut/fptr_update_w
add wave -noupdate /test_m2vmc/u_dut/fptr_page1_r
add wave -noupdate /test_m2vmc/u_dut/fptr_addrb_r
add wave -noupdate /test_m2vmc/u_dut/fptr_addra_w
add wave -noupdate /test_m2vmc/u_dut/next_fpaddrb_w
add wave -noupdate /test_m2vmc/u_dut/last_fpaddrb_w
add wave -noupdate /test_m2vmc/u_dut/fpn_datab_w
add wave -noupdate /test_m2vmc/u_dut/fpn_douta_w
add wave -noupdate /test_m2vmc/u_dut/fpu_datab_w
add wave -noupdate /test_m2vmc/u_dut/fpu_douta_w
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {604896169 ps} 0}
configure wave -namecolwidth 165
configure wave -valuecolwidth 64
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
WaveRestoreZoom {604857866 ps} {605026317 ps}
