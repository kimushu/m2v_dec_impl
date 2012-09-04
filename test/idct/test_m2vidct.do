onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_m2vidct/u_dut/clk
add wave -noupdate /test_m2vidct/u_dut/reset_n
add wave -noupdate /test_m2vidct/u_dut/softreset
add wave -noupdate /test_m2vidct/u_dut/ready_idct
add wave -noupdate /test_m2vidct/u_dut/block_start
add wave -noupdate /test_m2vidct/u_dut/s2_enable
add wave -noupdate /test_m2vidct/u_dut/s2_coded
add wave -noupdate /test_m2vidct/u_dut/s3_enable
add wave -noupdate /test_m2vidct/u_dut/s3_coded
add wave -noupdate /test_m2vidct/s4_enable_r
add wave -noupdate /test_m2vidct/s4_coded_r
add wave -noupdate /test_m2vidct/u_dut/coef_next
add wave -noupdate /test_m2vidct/u_dut/coef_sign
add wave -noupdate -radix unsigned /test_m2vidct/u_dut/coef_data
add wave -noupdate -radix symbolic /test_m2vidct/u_dut/pixel_coded
add wave -noupdate -radix unsigned /test_m2vidct/u_dut/pixel_addr
add wave -noupdate -radix decimal /test_m2vidct/u_dut/pixel_data0
add wave -noupdate -radix decimal /test_m2vidct/u_dut/pixel_data1
add wave -noupdate /test_m2vidct/u_dut/busy_r
add wave -noupdate /test_m2vidct/u_dut/wpage_r
add wave -noupdate /test_m2vidct/u_dut/rpage_r
add wave -noupdate -radix unsigned /test_m2vidct/u_dut/taddr_r
add wave -noupdate /test_m2vidct/u_dut/romdata_w
add wave -noupdate -radix decimal /test_m2vidct/u_dut/coefxp_w
add wave -noupdate -radix decimal /test_m2vidct/u_dut/coefxm_w
add wave -noupdate -radix decimal /test_m2vidct/u_dut/coefyp_w
add wave -noupdate -radix decimal /test_m2vidct/u_dut/coefym_w
add wave -noupdate -radix unsigned /test_m2vidct/u_dut/t0idx_w
add wave -noupdate -radix unsigned /test_m2vidct/u_dut/t1idx_w
add wave -noupdate -radix unsigned /test_m2vidct/u_dut/midx_w
add wave -noupdate /test_m2vidct/u_dut/imed_w
add wave -noupdate /test_m2vidct/u_dut/save_w
add wave -noupdate /test_m2vidct/u_dut/askip_w
add wave -noupdate /test_m2vidct/u_dut/final_w
add wave -noupdate -color Magenta -radix decimal /test_m2vidct/u_dut/cm0res_w
add wave -noupdate -color Magenta -radix decimal /test_m2vidct/u_dut/cm1res_w
add wave -noupdate -radix decimal /test_m2vidct/u_dut/ca0a_w
add wave -noupdate -radix decimal /test_m2vidct/u_dut/ca0b_w
add wave -noupdate -radix decimal /test_m2vidct/u_dut/ca0s_w
add wave -noupdate -radix decimal /test_m2vidct/u_dut/ca1a_w
add wave -noupdate -radix decimal /test_m2vidct/u_dut/ca1b_w
add wave -noupdate /test_m2vidct/u_dut/ca1c_w
add wave -noupdate -radix decimal /test_m2vidct/u_dut/ca1s_w
add wave -noupdate -color Yellow -radix decimal /test_m2vidct/u_dut/ct0d_w
add wave -noupdate -color Yellow -radix decimal /test_m2vidct/u_dut/ct1d_w
add wave -noupdate /test_m2vidct/u_dut/irhigh_r
add wave -noupdate /test_m2vidct/u_dut/iwrdata0_w
add wave -noupdate /test_m2vidct/u_dut/iwrdata1_w
add wave -noupdate /test_m2vidct/u_dut/iwraddr_w
add wave -noupdate /test_m2vidct/u_dut/irdaddr_w
add wave -noupdate /test_m2vidct/u_dut/coldata_w
add wave -noupdate /test_m2vidct/u_dut/rm0res_w
add wave -noupdate /test_m2vidct/u_dut/rm1res_w
add wave -noupdate /test_m2vidct/u_dut/ra0a_w
add wave -noupdate /test_m2vidct/u_dut/ra0b_w
add wave -noupdate /test_m2vidct/u_dut/ra0s_w
add wave -noupdate /test_m2vidct/u_dut/ra1a_w
add wave -noupdate /test_m2vidct/u_dut/ra1b_w
add wave -noupdate /test_m2vidct/u_dut/ra1c_w
add wave -noupdate /test_m2vidct/u_dut/ra1s_w
add wave -noupdate /test_m2vidct/u_dut/rt0d_w
add wave -noupdate /test_m2vidct/u_dut/rt1d_w
add wave -noupdate /test_m2vidct/u_dut/teven_r
add wave -noupdate /test_m2vidct/u_dut/byteena_w
add wave -noupdate /test_m2vidct/u_dut/clip0_w
add wave -noupdate /test_m2vidct/u_dut/clip1_w
add wave -noupdate /test_m2vidct/u_dut/fwraddr_w
add wave -noupdate /test_m2vidct/u_dut/frdaddr_w
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {72404 ps} 0}
configure wave -namecolwidth 153
configure wave -valuecolwidth 99
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
WaveRestoreZoom {0 ps} {245185500 ps}
