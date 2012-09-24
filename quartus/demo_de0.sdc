## Generated SDC file "demo_de0.sdc"

## Copyright (C) 1991-2011 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 11.1 Build 259 01/25/2012 Service Pack 2 SJ Web Edition"

## DATE    "Mon Sep 17 10:27:21 2012"

##
## DEVICE  "EP3C16F484C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 20.000 -waveform { 0.000 10.000 } [get_ports {altera_reserved_tck}]
create_clock -name {clk50mhz_1} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk50mhz_1}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {sysclk} -source [get_pins {u_pll|altpll_component|auto_generated|pll1|inclk[0]}] -multiply_by 2 -master_clock {clk50mhz_1} [get_pins { u_pll|altpll_component|auto_generated|pll1|clk[0] }] 
create_generated_clock -name {sdrclk} -source [get_pins {u_pll|altpll_component|auto_generated|pll1|inclk[0]}] -multiply_by 2 -phase -60.000 -master_clock {clk50mhz_1} [get_pins {u_pll|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {lcdclk} -source [get_pins {u_pll|altpll_component|auto_generated|pll1|inclk[0]}] -divide_by 5 -master_clock {clk50mhz_1} [get_pins {u_pll|altpll_component|auto_generated|pll1|clk[2]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_uu8:dffpipe13|dffe14a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_tu8:dffpipe10|dffe11a*}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_b09:dffpipe15|dffe16a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_a09:dffpipe12|dffe13a*}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

