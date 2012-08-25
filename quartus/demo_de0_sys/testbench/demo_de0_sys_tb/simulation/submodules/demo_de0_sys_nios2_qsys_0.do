add wave -noupdate -divider {demo_de0_sys_nios2_qsys_0: top-level ports}
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/d_irq
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/d_waitrequest
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/d_address
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/d_byteenable
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/d_read
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/d_readdata
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/d_write
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/d_writedata
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/i_waitrequest
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/i_address
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/i_read
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/i_readdata
add wave -noupdate -divider {demo_de0_sys_nios2_qsys_0: common}
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/clk
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/reset_n
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/F_pcb_nxt
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/F_pcb
add wave -noupdate -format Logic -radix ascii /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/F_vinst
add wave -noupdate -format Logic -radix ascii /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/D_vinst
add wave -noupdate -format Logic -radix ascii /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/R_vinst
add wave -noupdate -format Logic -radix ascii /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/E_vinst
add wave -noupdate -format Logic -radix ascii /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/W_vinst
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/F_valid
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/D_valid
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/R_valid
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/E_valid
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/W_valid
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/D_wr_dst_reg
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/D_dst_regnum
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/W_wr_data
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/F_iw
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/D_iw
add wave -noupdate -divider {demo_de0_sys_nios2_qsys_0: breaks}
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/hbreak_req
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/oci_hbreak_req
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/hbreak_enabled
add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_demo_de0_sys_nios2_qsys_0/wait_for_one_post_bret_inst

configure wave -justifyvalue right
configure wave -signalnamewidth 1
TreeUpdate [SetDefaultTree]
