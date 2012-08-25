# Legal Notice: (C)2012 Altera Corporation. All rights reserved.  Your
# use of Altera Corporation's design tools, logic functions and other
# software and tools, and its AMPP partner logic functions, and any
# output files any of the foregoing (including device programming or
# simulation files), and any associated documentation or information are
# expressly subject to the terms and conditions of the Altera Program
# License Subscription Agreement or other applicable license agreement,
# including, without limitation, that your use is for the sole purpose
# of programming logic devices manufactured by Altera and sold by Altera
# or its authorized distributors.  Please refer to the applicable
# agreement for further details.

#**************************************************************
# Timequest JTAG clock definition
#   Uncommenting the following lines will define the JTAG
#   clock in TimeQuest Timing Analyzer
#**************************************************************

#create_clock -period 10MHz {altera_reserved_tck}
#set_clock_groups -asynchronous -group {altera_reserved_tck}

#**************************************************************
# Set TCL Path Variables 
#**************************************************************

set 	demo_de0_sys_nios2_qsys_0 	demo_de0_sys_nios2_qsys_0:*
set 	demo_de0_sys_nios2_qsys_0_oci 	demo_de0_sys_nios2_qsys_0_nios2_oci:the_demo_de0_sys_nios2_qsys_0_nios2_oci
set 	demo_de0_sys_nios2_qsys_0_oci_break 	demo_de0_sys_nios2_qsys_0_nios2_oci_break:the_demo_de0_sys_nios2_qsys_0_nios2_oci_break
set 	demo_de0_sys_nios2_qsys_0_ocimem 	demo_de0_sys_nios2_qsys_0_nios2_ocimem:the_demo_de0_sys_nios2_qsys_0_nios2_ocimem
set 	demo_de0_sys_nios2_qsys_0_oci_debug 	demo_de0_sys_nios2_qsys_0_nios2_oci_debug:the_demo_de0_sys_nios2_qsys_0_nios2_oci_debug
set 	demo_de0_sys_nios2_qsys_0_wrapper 	demo_de0_sys_nios2_qsys_0_jtag_debug_module_wrapper:the_demo_de0_sys_nios2_qsys_0_jtag_debug_module_wrapper
set 	demo_de0_sys_nios2_qsys_0_jtag_tck 	demo_de0_sys_nios2_qsys_0_jtag_debug_module_tck:the_demo_de0_sys_nios2_qsys_0_jtag_debug_module_tck
set 	demo_de0_sys_nios2_qsys_0_jtag_sysclk 	demo_de0_sys_nios2_qsys_0_jtag_debug_module_sysclk:the_demo_de0_sys_nios2_qsys_0_jtag_debug_module_sysclk
set 	demo_de0_sys_nios2_qsys_0_oci_path 	 [format "%s|%s" $demo_de0_sys_nios2_qsys_0 $demo_de0_sys_nios2_qsys_0_oci]
set 	demo_de0_sys_nios2_qsys_0_oci_break_path 	 [format "%s|%s" $demo_de0_sys_nios2_qsys_0_oci_path $demo_de0_sys_nios2_qsys_0_oci_break]
set 	demo_de0_sys_nios2_qsys_0_ocimem_path 	 [format "%s|%s" $demo_de0_sys_nios2_qsys_0_oci_path $demo_de0_sys_nios2_qsys_0_ocimem]
set 	demo_de0_sys_nios2_qsys_0_oci_debug_path 	 [format "%s|%s" $demo_de0_sys_nios2_qsys_0_oci_path $demo_de0_sys_nios2_qsys_0_oci_debug]
set 	demo_de0_sys_nios2_qsys_0_jtag_tck_path 	 [format "%s|%s|%s" $demo_de0_sys_nios2_qsys_0_oci_path $demo_de0_sys_nios2_qsys_0_wrapper $demo_de0_sys_nios2_qsys_0_jtag_tck]
set 	demo_de0_sys_nios2_qsys_0_jtag_sysclk_path 	 [format "%s|%s|%s" $demo_de0_sys_nios2_qsys_0_oci_path $demo_de0_sys_nios2_qsys_0_wrapper $demo_de0_sys_nios2_qsys_0_jtag_sysclk]
set 	demo_de0_sys_nios2_qsys_0_jtag_sr 	 [format "%s|*sr" $demo_de0_sys_nios2_qsys_0_jtag_tck_path]

#**************************************************************
# Set False Paths
#**************************************************************

set_false_path -from [get_keepers *$demo_de0_sys_nios2_qsys_0_oci_break_path|break_readreg*] -to [get_keepers *$demo_de0_sys_nios2_qsys_0_jtag_sr*]
set_false_path -from [get_keepers *$demo_de0_sys_nios2_qsys_0_oci_debug_path|*resetlatch]     -to [get_keepers *$demo_de0_sys_nios2_qsys_0_jtag_sr[33]]
set_false_path -from [get_keepers *$demo_de0_sys_nios2_qsys_0_oci_debug_path|monitor_ready]  -to [get_keepers *$demo_de0_sys_nios2_qsys_0_jtag_sr[0]]
set_false_path -from [get_keepers *$demo_de0_sys_nios2_qsys_0_oci_debug_path|monitor_error]  -to [get_keepers *$demo_de0_sys_nios2_qsys_0_jtag_sr[34]]
set_false_path -from [get_keepers *$demo_de0_sys_nios2_qsys_0_ocimem_path|*MonDReg*] -to [get_keepers *$demo_de0_sys_nios2_qsys_0_jtag_sr*]
set_false_path -from *$demo_de0_sys_nios2_qsys_0_jtag_sr*    -to *$demo_de0_sys_nios2_qsys_0_jtag_sysclk_path|*jdo*
set_false_path -from sld_hub:*|irf_reg* -to *$demo_de0_sys_nios2_qsys_0_jtag_sysclk_path|ir*
set_false_path -from sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1] -to *$demo_de0_sys_nios2_qsys_0_oci_debug_path|monitor_go
