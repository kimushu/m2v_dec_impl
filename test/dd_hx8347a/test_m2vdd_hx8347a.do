onerror {resume}
quietly virtual signal -install /test_m2vdd_hx8347a/u_dut { /test_m2vdd_hx8347a/u_dut/lcd_data[15:11]} lcd_data_R
quietly virtual signal -install /test_m2vdd_hx8347a/u_dut { /test_m2vdd_hx8347a/u_dut/lcd_data[10:5]} lcd_data_G
quietly virtual signal -install /test_m2vdd_hx8347a/u_dut { /test_m2vdd_hx8347a/u_dut/lcd_data[4:0]} lcd_data_B
quietly virtual signal -install /test_m2vdd_hx8347a/u_dut { (context /test_m2vdd_hx8347a/u_dut )&{ rout_w[7:3] , gout_w[7:2] , bout_w[7:3] }} rgb_out
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider lcdclk
add wave -noupdate /test_m2vdd_hx8347a/u_dut/lcd_clk
add wave -noupdate /test_m2vdd_hx8347a/u_dut/lcd_reset_n
add wave -noupdate /test_m2vdd_hx8347a/u_dut/lcd_cs
add wave -noupdate /test_m2vdd_hx8347a/u_dut/lcd_rs
add wave -noupdate -radix hexadecimal -childformat {{{/test_m2vdd_hx8347a/u_dut/lcd_data[15]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[14]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[13]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[12]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[11]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[10]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[9]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[8]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[7]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[6]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[5]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[4]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[3]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[2]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[1]} -radix hexadecimal} {{/test_m2vdd_hx8347a/u_dut/lcd_data[0]} -radix hexadecimal}} -subitemconfig {{/test_m2vdd_hx8347a/u_dut/lcd_data[15]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[14]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[13]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[12]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[11]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[10]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[9]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[8]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[7]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[6]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[5]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[4]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[3]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[2]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[1]} {-height 15 -radix hexadecimal} {/test_m2vdd_hx8347a/u_dut/lcd_data[0]} {-height 15 -radix hexadecimal}} /test_m2vdd_hx8347a/u_dut/lcd_data
add wave -noupdate -color Red -radix unsigned /test_m2vdd_hx8347a/u_dut/lcd_data_R
add wave -noupdate -color Green -radix unsigned /test_m2vdd_hx8347a/u_dut/lcd_data_G
add wave -noupdate -color Blue -radix unsigned /test_m2vdd_hx8347a/u_dut/lcd_data_B
add wave -noupdate /test_m2vdd_hx8347a/u_dut/lcd_write_n
add wave -noupdate /test_m2vdd_hx8347a/u_dut/lcd_read_n
add wave -noupdate -divider sysclk
add wave -noupdate /test_m2vdd_hx8347a/u_dut/clk
add wave -noupdate /test_m2vdd_hx8347a/u_dut/reset_n
add wave -noupdate /test_m2vdd_hx8347a/u_dut/ctrl_read
add wave -noupdate -radix hexadecimal /test_m2vdd_hx8347a/u_dut/ctrl_readdata
add wave -noupdate /test_m2vdd_hx8347a/u_dut/ctrl_write
add wave -noupdate -radix hexadecimal /test_m2vdd_hx8347a/u_dut/ctrl_writedata
add wave -noupdate /test_m2vdd_hx8347a/u_dut/ctrl_waitrequest
add wave -noupdate /test_m2vdd_hx8347a/u_dut/ctrl_readdatavalid
add wave -noupdate -radix hexadecimal /test_m2vdd_hx8347a/u_dut/fbuf_address
add wave -noupdate /test_m2vdd_hx8347a/u_dut/fbuf_read
add wave -noupdate -radix hexadecimal /test_m2vdd_hx8347a/u_dut/fbuf_readdata
add wave -noupdate /test_m2vdd_hx8347a/u_dut/fbuf_write
add wave -noupdate /test_m2vdd_hx8347a/u_dut/fbuf_writedata
add wave -noupdate /test_m2vdd_hx8347a/u_dut/fbuf_waitrequest
add wave -noupdate /test_m2vdd_hx8347a/u_dut/fbuf_readdatavalid
add wave -noupdate /test_m2vdd_hx8347a/u_dut/fptr_address
add wave -noupdate /test_m2vdd_hx8347a/u_dut/fptr_updated
add wave -noupdate /test_m2vdd_hx8347a/u_dut/fptr_number
add wave -noupdate /test_m2vdd_hx8347a/u_dut/fifo_write_w
add wave -noupdate /test_m2vdd_hx8347a/u_dut/fifo_wdata_w
add wave -noupdate /test_m2vdd_hx8347a/u_dut/fifo_wfull_w
add wave -noupdate /test_m2vdd_hx8347a/u_dut/fifo_read_r
add wave -noupdate -radix hexadecimal /test_m2vdd_hx8347a/u_dut/fifo_rdata_w
add wave -noupdate /test_m2vdd_hx8347a/u_dut/fifo_rempty_w
add wave -noupdate /test_m2vdd_hx8347a/u_dut/state_r
add wave -noupdate -radix ascii /test_m2vdd_hx8347a/u_dut/statename
add wave -noupdate /test_m2vdd_hx8347a/u_dut/ctrl_read_1d_r
add wave -noupdate /test_m2vdd_hx8347a/u_dut/softreset_r
add wave -noupdate -radix unsigned /test_m2vdd_hx8347a/u_dut/max_mbx_r
add wave -noupdate -radix unsigned /test_m2vdd_hx8347a/u_dut/max_mby_r
add wave -noupdate -radix unsigned /test_m2vdd_hx8347a/u_dut/last_pxy_r
add wave -noupdate -radix unsigned /test_m2vdd_hx8347a/u_dut/mbx_r
add wave -noupdate -radix unsigned /test_m2vdd_hx8347a/u_dut/mby_r
add wave -noupdate -radix unsigned /test_m2vdd_hx8347a/u_dut/next_mbx_w
add wave -noupdate -radix unsigned /test_m2vdd_hx8347a/u_dut/next_mby_w
add wave -noupdate /test_m2vdd_hx8347a/u_dut/frpage_r
add wave -noupdate /test_m2vdd_hx8347a/u_dut/frchroma_r
add wave -noupdate -radix unsigned /test_m2vdd_hx8347a/u_dut/frpxx2_r
add wave -noupdate -radix unsigned /test_m2vdd_hx8347a/u_dut/frpxy_r
add wave -noupdate -radix unsigned /test_m2vdd_hx8347a/u_dut/next_frpxx2_w
add wave -noupdate -radix unsigned /test_m2vdd_hx8347a/u_dut/next_frpxy_w
add wave -noupdate /test_m2vdd_hx8347a/u_dut/bwpage_r
add wave -noupdate -radix hexadecimal /test_m2vdd_hx8347a/u_dut/bwaddr_r
add wave -noupdate -radix hexadecimal /test_m2vdd_hx8347a/u_dut/next_bwaddr_w
add wave -noupdate /test_m2vdd_hx8347a/u_dut/bwrite_w
add wave -noupdate /test_m2vdd_hx8347a/u_dut/brfull_r
add wave -noupdate /test_m2vdd_hx8347a/u_dut/brpixel_r
add wave -noupdate /test_m2vdd_hx8347a/u_dut/brluma_r
add wave -noupdate /test_m2vdd_hx8347a/u_dut/brchroma_r
add wave -noupdate /test_m2vdd_hx8347a/u_dut/brend_r
add wave -noupdate /test_m2vdd_hx8347a/u_dut/next_brpixel_w
add wave -noupdate /test_m2vdd_hx8347a/u_dut/braddr_w
add wave -noupdate -radix hexadecimal /test_m2vdd_hx8347a/u_dut/buf_q_w
add wave -noupdate /test_m2vdd_hx8347a/u_dut/convert_r
add wave -noupdate -radix hexadecimal /test_m2vdd_hx8347a/u_dut/brybuf_r
add wave -noupdate -radix hexadecimal /test_m2vdd_hx8347a/u_dut/brcb_w
add wave -noupdate -radix hexadecimal /test_m2vdd_hx8347a/u_dut/brcr_w
add wave -noupdate -radix hexadecimal /test_m2vdd_hx8347a/u_dut/rout_w
add wave -noupdate -radix hexadecimal /test_m2vdd_hx8347a/u_dut/gout_w
add wave -noupdate -radix hexadecimal /test_m2vdd_hx8347a/u_dut/bout_w
add wave -noupdate -color Magenta -radix hexadecimal /test_m2vdd_hx8347a/u_dut/rgb_out
add wave -noupdate /test_m2vdd_hx8347a/u_dut/rgbvalid_w
add wave -noupdate /test_m2vdd_hx8347a/u_dut/lcd_xwr_r
add wave -noupdate /test_m2vdd_hx8347a/u_dut/rempty_1d_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8970000 ps} 0}
configure wave -namecolwidth 167
configure wave -valuecolwidth 89
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
WaveRestoreZoom {8464799 ps} {9193959 ps}
