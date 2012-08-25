
# (C) 2001-2012 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Altera 
# Program License Subscription Agreement, Altera MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by Altera 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ----------------------------------------
# Auto-generated simulation script

# ----------------------------------------
# Initialize the variable
if ![info exists SYSTEM_INSTANCE_NAME] { 
  set SYSTEM_INSTANCE_NAME ""
} elseif { ![ string match "" $SYSTEM_INSTANCE_NAME ] } { 
  set SYSTEM_INSTANCE_NAME "/$SYSTEM_INSTANCE_NAME"
} 

if ![info exists TOP_LEVEL_NAME] { 
  set TOP_LEVEL_NAME "demo_de0_sys_tb"
} elseif { ![ string match "" $TOP_LEVEL_NAME ] } { 
  set TOP_LEVEL_NAME "$TOP_LEVEL_NAME"
} 

if ![info exists QSYS_SIMDIR] { 
  set QSYS_SIMDIR "./../"
} elseif { ![ string match "" $QSYS_SIMDIR ] } { 
  set QSYS_SIMDIR "$QSYS_SIMDIR"
} 


# ----------------------------------------
# Copy ROM/RAM files to simulation directory
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vctrl_code.mif ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_fram.mif ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_rom.mif ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2visdq_cmem.mif ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vmc_fetch.mif ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vvld_table.mif ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_ram_0.hex ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_rf_ram_b.mif ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_rf_ram_a.hex ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_rf_ram_b.hex ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_rf_ram_a.mif ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_ociram_default_contents.dat ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_rf_ram_a.dat ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_rf_ram_b.dat ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_ociram_default_contents.mif ./
file copy -force $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_ociram_default_contents.hex ./

# ----------------------------------------
# Create compilation libraries
proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }
ensure_lib      ./libraries/     
ensure_lib      ./libraries/work/
vmap       work ./libraries/work/
if { ![ string match "*ModelSim ALTERA*" [ vsim -version ] ] } {
  ensure_lib                  ./libraries/altera_ver/      
  vmap       altera_ver       ./libraries/altera_ver/      
  ensure_lib                  ./libraries/lpm_ver/         
  vmap       lpm_ver          ./libraries/lpm_ver/         
  ensure_lib                  ./libraries/sgate_ver/       
  vmap       sgate_ver        ./libraries/sgate_ver/       
  ensure_lib                  ./libraries/altera_mf_ver/   
  vmap       altera_mf_ver    ./libraries/altera_mf_ver/   
  ensure_lib                  ./libraries/altera_lnsim_ver/
  vmap       altera_lnsim_ver ./libraries/altera_lnsim_ver/
  ensure_lib                  ./libraries/cycloneiii_ver/  
  vmap       cycloneiii_ver   ./libraries/cycloneiii_ver/  
}
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_tda/                                                                       
vmap       demo_de0_sys_tb_tda                                                                        ./libraries/demo_de0_sys_tb_tda/                                                                       
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_tdt/                                                                       
vmap       demo_de0_sys_tb_tdt                                                                        ./libraries/demo_de0_sys_tb_tdt/                                                                       
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_irq_mapper/                                                                
vmap       demo_de0_sys_tb_irq_mapper                                                                 ./libraries/demo_de0_sys_tb_irq_mapper/                                                                
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_crosser/                                                                   
vmap       demo_de0_sys_tb_crosser                                                                    ./libraries/demo_de0_sys_tb_crosser/                                                                   
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_width_adapter/                                                             
vmap       demo_de0_sys_tb_width_adapter                                                              ./libraries/demo_de0_sys_tb_width_adapter/                                                             
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_rsp_xbar_demux_013/                                                        
vmap       demo_de0_sys_tb_rsp_xbar_demux_013                                                         ./libraries/demo_de0_sys_tb_rsp_xbar_demux_013/                                                        
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_cmd_xbar_mux_013/                                                          
vmap       demo_de0_sys_tb_cmd_xbar_mux_013                                                           ./libraries/demo_de0_sys_tb_cmd_xbar_mux_013/                                                          
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_cmd_xbar_demux_002/                                                        
vmap       demo_de0_sys_tb_cmd_xbar_demux_002                                                         ./libraries/demo_de0_sys_tb_cmd_xbar_demux_002/                                                        
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_rsp_xbar_mux_001/                                                          
vmap       demo_de0_sys_tb_rsp_xbar_mux_001                                                           ./libraries/demo_de0_sys_tb_rsp_xbar_mux_001/                                                          
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_rsp_xbar_mux/                                                              
vmap       demo_de0_sys_tb_rsp_xbar_mux                                                               ./libraries/demo_de0_sys_tb_rsp_xbar_mux/                                                              
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_rsp_xbar_demux_003/                                                        
vmap       demo_de0_sys_tb_rsp_xbar_demux_003                                                         ./libraries/demo_de0_sys_tb_rsp_xbar_demux_003/                                                        
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_rsp_xbar_demux/                                                            
vmap       demo_de0_sys_tb_rsp_xbar_demux                                                             ./libraries/demo_de0_sys_tb_rsp_xbar_demux/                                                            
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_cmd_xbar_mux/                                                              
vmap       demo_de0_sys_tb_cmd_xbar_mux                                                               ./libraries/demo_de0_sys_tb_cmd_xbar_mux/                                                              
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_cmd_xbar_demux_001/                                                        
vmap       demo_de0_sys_tb_cmd_xbar_demux_001                                                         ./libraries/demo_de0_sys_tb_cmd_xbar_demux_001/                                                        
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_cmd_xbar_demux/                                                            
vmap       demo_de0_sys_tb_cmd_xbar_demux                                                             ./libraries/demo_de0_sys_tb_cmd_xbar_demux/                                                            
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_rst_controller/                                                            
vmap       demo_de0_sys_tb_rst_controller                                                             ./libraries/demo_de0_sys_tb_rst_controller/                                                            
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_burst_adapter/                                                             
vmap       demo_de0_sys_tb_burst_adapter                                                              ./libraries/demo_de0_sys_tb_burst_adapter/                                                             
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_id_router_013/                                                             
vmap       demo_de0_sys_tb_id_router_013                                                              ./libraries/demo_de0_sys_tb_id_router_013/                                                             
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_addr_router_002/                                                           
vmap       demo_de0_sys_tb_addr_router_002                                                            ./libraries/demo_de0_sys_tb_addr_router_002/                                                           
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_id_router_003/                                                             
vmap       demo_de0_sys_tb_id_router_003                                                              ./libraries/demo_de0_sys_tb_id_router_003/                                                             
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_id_router_002/                                                             
vmap       demo_de0_sys_tb_id_router_002                                                              ./libraries/demo_de0_sys_tb_id_router_002/                                                             
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_id_router/                                                                 
vmap       demo_de0_sys_tb_id_router                                                                  ./libraries/demo_de0_sys_tb_id_router/                                                                 
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_addr_router_001/                                                           
vmap       demo_de0_sys_tb_addr_router_001                                                            ./libraries/demo_de0_sys_tb_addr_router_001/                                                           
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_addr_router/                                                               
vmap       demo_de0_sys_tb_addr_router                                                                ./libraries/demo_de0_sys_tb_addr_router/                                                               
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator_avalon_universal_master_0_agent/
vmap       demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator_avalon_universal_master_0_agent ./libraries/demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator_avalon_universal_master_0_agent/
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent_rsp_fifo/          
vmap       demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent_rsp_fifo           ./libraries/demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent_rsp_fifo/          
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent/                   
vmap       demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent                    ./libraries/demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent/                   
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_nios2_qsys_0_jtag_debug_module_translator/                                 
vmap       demo_de0_sys_tb_nios2_qsys_0_jtag_debug_module_translator                                  ./libraries/demo_de0_sys_tb_nios2_qsys_0_jtag_debug_module_translator/                                 
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator/                                
vmap       demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator                                 ./libraries/demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator/                                
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_pio_0/                                                                     
vmap       demo_de0_sys_tb_pio_0                                                                      ./libraries/demo_de0_sys_tb_pio_0/                                                                     
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_spi_0/                                                                     
vmap       demo_de0_sys_tb_spi_0                                                                      ./libraries/demo_de0_sys_tb_spi_0/                                                                     
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_timer_0/                                                                   
vmap       demo_de0_sys_tb_timer_0                                                                    ./libraries/demo_de0_sys_tb_timer_0/                                                                   
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_timing_adapter/                                                            
vmap       demo_de0_sys_tb_timing_adapter                                                             ./libraries/demo_de0_sys_tb_timing_adapter/                                                            
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_data_format_adapter/                                                       
vmap       demo_de0_sys_tb_data_format_adapter                                                        ./libraries/demo_de0_sys_tb_data_format_adapter/                                                       
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_sdram_0/                                                                   
vmap       demo_de0_sys_tb_sdram_0                                                                    ./libraries/demo_de0_sys_tb_sdram_0/                                                                   
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_m2vdd_hx8347a_0/                                                           
vmap       demo_de0_sys_tb_m2vdd_hx8347a_0                                                            ./libraries/demo_de0_sys_tb_m2vdd_hx8347a_0/                                                           
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_hexdisp_0/                                                                 
vmap       demo_de0_sys_tb_hexdisp_0                                                                  ./libraries/demo_de0_sys_tb_hexdisp_0/                                                                 
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_m2vdec_0/                                                                  
vmap       demo_de0_sys_tb_m2vdec_0                                                                   ./libraries/demo_de0_sys_tb_m2vdec_0/                                                                  
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_fifo_0/                                                                    
vmap       demo_de0_sys_tb_fifo_0                                                                     ./libraries/demo_de0_sys_tb_fifo_0/                                                                    
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_flash_0/                                                                   
vmap       demo_de0_sys_tb_flash_0                                                                    ./libraries/demo_de0_sys_tb_flash_0/                                                                   
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_rom_0/                                                                     
vmap       demo_de0_sys_tb_rom_0                                                                      ./libraries/demo_de0_sys_tb_rom_0/                                                                     
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_ram_0/                                                                     
vmap       demo_de0_sys_tb_ram_0                                                                      ./libraries/demo_de0_sys_tb_ram_0/                                                                     
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_sysid_qsys_0/                                                              
vmap       demo_de0_sys_tb_sysid_qsys_0                                                               ./libraries/demo_de0_sys_tb_sysid_qsys_0/                                                              
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_nios2_qsys_0/                                                              
vmap       demo_de0_sys_tb_nios2_qsys_0                                                               ./libraries/demo_de0_sys_tb_nios2_qsys_0/                                                              
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_altpll_0/                                                                  
vmap       demo_de0_sys_tb_altpll_0                                                                   ./libraries/demo_de0_sys_tb_altpll_0/                                                                  
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_sdram_0_my_partner/                                                        
vmap       demo_de0_sys_tb_sdram_0_my_partner                                                         ./libraries/demo_de0_sys_tb_sdram_0_my_partner/                                                        
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_rom_0_external_mem_bfm/                                                    
vmap       demo_de0_sys_tb_rom_0_external_mem_bfm                                                     ./libraries/demo_de0_sys_tb_rom_0_external_mem_bfm/                                                    
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_flash_0_tcb_translator/                                                    
vmap       demo_de0_sys_tb_flash_0_tcb_translator                                                     ./libraries/demo_de0_sys_tb_flash_0_tcb_translator/                                                    
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_sw_bfm/                                                  
vmap       demo_de0_sys_tb_demo_de0_sys_inst_sw_bfm                                                   ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_sw_bfm/                                                  
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_sdcard_bfm/                                              
vmap       demo_de0_sys_tb_demo_de0_sys_inst_sdcard_bfm                                               ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_sdcard_bfm/                                              
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_lcd_bfm/                                                 
vmap       demo_de0_sys_tb_demo_de0_sys_inst_lcd_bfm                                                  ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_lcd_bfm/                                                 
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_hd_bfm/                                                  
vmap       demo_de0_sys_tb_demo_de0_sys_inst_hd_bfm                                                   ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_hd_bfm/                                                  
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_pll_areset_bfm/                                          
vmap       demo_de0_sys_tb_demo_de0_sys_inst_pll_areset_bfm                                           ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_pll_areset_bfm/                                          
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_pll_phasedone_bfm/                                       
vmap       demo_de0_sys_tb_demo_de0_sys_inst_pll_phasedone_bfm                                        ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_pll_phasedone_bfm/                                       
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_reset_bfm/                                               
vmap       demo_de0_sys_tb_demo_de0_sys_inst_reset_bfm                                                ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_reset_bfm/                                               
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_clk_bfm/                                                 
vmap       demo_de0_sys_tb_demo_de0_sys_inst_clk_bfm                                                  ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_clk_bfm/                                                 
ensure_lib                                                                                            ./libraries/demo_de0_sys_tb_demo_de0_sys_inst/                                                         
vmap       demo_de0_sys_tb_demo_de0_sys_inst                                                          ./libraries/demo_de0_sys_tb_demo_de0_sys_inst/                                                         

# ----------------------------------------
# Compile device library files
alias dev_com {
  echo "\[exec\] dev_com"
  if { ![ string match "*ModelSim ALTERA*" [ vsim -version ] ] } {
    vlog     "/opt/altera/11.1sp2/quartus/eda/sim_lib/altera_primitives.v" -work altera_ver      
    vlog     "/opt/altera/11.1sp2/quartus/eda/sim_lib/220model.v"          -work lpm_ver         
    vlog     "/opt/altera/11.1sp2/quartus/eda/sim_lib/sgate.v"             -work sgate_ver       
    vlog     "/opt/altera/11.1sp2/quartus/eda/sim_lib/altera_mf.v"         -work altera_mf_ver   
    vlog -sv "/opt/altera/11.1sp2/quartus/eda/sim_lib/altera_lnsim.sv"     -work altera_lnsim_ver
    vlog     "/opt/altera/11.1sp2/quartus/eda/sim_lib/cycloneiii_atoms.v"  -work cycloneiii_ver  
  }
}

# ----------------------------------------
# Compile the design files in correct order
alias com {
  echo "\[exec\] com"
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_tristate_controller_aggregator.sv"              -work demo_de0_sys_tb_tda                                                                       
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_tristate_controller_translator.sv"              -work demo_de0_sys_tb_tdt                                                                       
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_irq_mapper.sv"                            -work demo_de0_sys_tb_irq_mapper                                                                
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_st_handshake_clock_crosser.v"            -work demo_de0_sys_tb_crosser                                                                   
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_st_clock_crosser.v"                      -work demo_de0_sys_tb_crosser                                                                   
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_st_pipeline_base.v"                      -work demo_de0_sys_tb_crosser                                                                   
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_width_adapter.sv"                        -work demo_de0_sys_tb_width_adapter                                                             
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_burst_uncompressor.sv"                   -work demo_de0_sys_tb_width_adapter                                                             
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_demux_013.sv"                    -work demo_de0_sys_tb_rsp_xbar_demux_013                                                        
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_arbitrator.sv"                           -work demo_de0_sys_tb_cmd_xbar_mux_013                                                          
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_mux_013.sv"                      -work demo_de0_sys_tb_cmd_xbar_mux_013                                                          
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_demux_002.sv"                    -work demo_de0_sys_tb_cmd_xbar_demux_002                                                        
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_arbitrator.sv"                           -work demo_de0_sys_tb_rsp_xbar_mux_001                                                          
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_mux_001.sv"                      -work demo_de0_sys_tb_rsp_xbar_mux_001                                                          
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_arbitrator.sv"                           -work demo_de0_sys_tb_rsp_xbar_mux                                                              
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_mux.sv"                          -work demo_de0_sys_tb_rsp_xbar_mux                                                              
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_demux_003.sv"                    -work demo_de0_sys_tb_rsp_xbar_demux_003                                                        
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_demux.sv"                        -work demo_de0_sys_tb_rsp_xbar_demux                                                            
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_arbitrator.sv"                           -work demo_de0_sys_tb_cmd_xbar_mux                                                              
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_mux.sv"                          -work demo_de0_sys_tb_cmd_xbar_mux                                                              
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_demux_001.sv"                    -work demo_de0_sys_tb_cmd_xbar_demux_001                                                        
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_demux.sv"                        -work demo_de0_sys_tb_cmd_xbar_demux                                                            
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_reset_controller.v"                             -work demo_de0_sys_tb_rst_controller                                                            
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_reset_synchronizer.v"                           -work demo_de0_sys_tb_rst_controller                                                            
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_burst_adapter.sv"                        -work demo_de0_sys_tb_burst_adapter                                                             
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_id_router_013.sv"                         -work demo_de0_sys_tb_id_router_013                                                             
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_addr_router_002.sv"                       -work demo_de0_sys_tb_addr_router_002                                                           
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_id_router_003.sv"                         -work demo_de0_sys_tb_id_router_003                                                             
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_id_router_002.sv"                         -work demo_de0_sys_tb_id_router_002                                                             
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_id_router.sv"                             -work demo_de0_sys_tb_id_router                                                                 
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_addr_router_001.sv"                       -work demo_de0_sys_tb_addr_router_001                                                           
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_addr_router.sv"                           -work demo_de0_sys_tb_addr_router                                                               
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_master_agent.sv"                         -work demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator_avalon_universal_master_0_agent
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_sc_fifo.v"                               -work demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent_rsp_fifo          
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_slave_agent.sv"                          -work demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent                   
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_burst_uncompressor.sv"                   -work demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent                   
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_slave_translator.sv"                     -work demo_de0_sys_tb_nios2_qsys_0_jtag_debug_module_translator                                 
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_master_translator.sv"                    -work demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator                                
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_pio_0.v"                                  -work demo_de0_sys_tb_pio_0                                                                     
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_spi_0.v"                                  -work demo_de0_sys_tb_spi_0                                                                     
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_timer_0.v"                                -work demo_de0_sys_tb_timer_0                                                                   
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_timing_adapter.v"                         -work demo_de0_sys_tb_timing_adapter                                                            
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_timing_adapter_fifo.v"                    -work demo_de0_sys_tb_timing_adapter                                                            
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_data_format_adapter.v"                    -work demo_de0_sys_tb_data_format_adapter                                                       
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_data_format_adapter_state_ram.v"          -work demo_de0_sys_tb_data_format_adapter                                                       
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_data_format_adapter_data_ram.v"           -work demo_de0_sys_tb_data_format_adapter                                                       
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_sdram_0_test_component.v"                 -work demo_de0_sys_tb_sdram_0                                                                   
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_sdram_0.v"                                -work demo_de0_sys_tb_sdram_0                                                                   
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vdd_hx8347a.v"                                       -work demo_de0_sys_tb_m2vdd_hx8347a_0                                                           
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vfbagen.v"                                           -work demo_de0_sys_tb_m2vdd_hx8347a_0                                                           
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/ycbcr2rgb.v"                                           -work demo_de0_sys_tb_m2vdd_hx8347a_0                                                           
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vdd_hx8347a_buf.v"                                   -work demo_de0_sys_tb_m2vdd_hx8347a_0                                                           
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vdd_hx8347a_fifo.v"                                  -work demo_de0_sys_tb_m2vdd_hx8347a_0                                                           
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/ycbcr2rgb_mac.v"                                       -work demo_de0_sys_tb_m2vdd_hx8347a_0                                                           
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/seg7led_static.v"                                      -work demo_de0_sys_tb_hexdisp_0                                                                 
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vdec.v"                                              -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vfbagen.v"                                           -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vctrl.v"                                             -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vctrl_code.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct.v"                                             -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_fram.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_iram.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_mult.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_rom.v"                                         -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2visdq.v"                                             -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2visdq_cmem.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2visdq_dmem.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2visdq_mult.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vmc.v"                                               -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vmc_fetch.v"                                         -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vmc_frameptr.v"                                      -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vsdp.v"                                              -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vside1.v"                                            -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vside2.v"                                            -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vside3.v"                                            -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vside4.v"                                            -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vstbuf.v"                                            -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vstbuf_fifo.v"                                       -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vstbuf_shifter.v"                                    -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vvld.v"                                              -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vvld_table.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_fifo_0.v"                                 -work demo_de0_sys_tb_fifo_0                                                                    
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_flash_0.sv"                               -work demo_de0_sys_tb_flash_0                                                                   
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rom_0.v"                                  -work demo_de0_sys_tb_rom_0                                                                     
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_ram_0.v"                                  -work demo_de0_sys_tb_ram_0                                                                     
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_sysid_qsys_0.vo"                          -work demo_de0_sys_tb_sysid_qsys_0                                                              
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_jtag_debug_module_tck.v"     -work demo_de0_sys_tb_nios2_qsys_0                                                              
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_test_bench.v"                -work demo_de0_sys_tb_nios2_qsys_0                                                              
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0.v"                           -work demo_de0_sys_tb_nios2_qsys_0                                                              
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_jtag_debug_module_wrapper.v" -work demo_de0_sys_tb_nios2_qsys_0                                                              
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_jtag_debug_module_sysclk.v"  -work demo_de0_sys_tb_nios2_qsys_0                                                              
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_oci_test_bench.v"            -work demo_de0_sys_tb_nios2_qsys_0                                                              
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_altpll_0.vo"                              -work demo_de0_sys_tb_altpll_0                                                                  
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_sdram_partner_module.v"                         -work demo_de0_sys_tb_sdram_0_my_partner                                                        
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_external_memory_bfm.sv"                         -work demo_de0_sys_tb_rom_0_external_mem_bfm                                                    
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_inout.sv"                                       -work demo_de0_sys_tb_flash_0_tcb_translator                                                    
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_tristate_conduit_bridge_translator.sv"          -work demo_de0_sys_tb_flash_0_tcb_translator                                                    
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_sw_bfm                                                  
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0006.sv"                            -work demo_de0_sys_tb_demo_de0_sys_inst_sw_bfm                                                  
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_sdcard_bfm                                              
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0005.sv"                            -work demo_de0_sys_tb_demo_de0_sys_inst_sdcard_bfm                                              
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_lcd_bfm                                                 
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0004.sv"                            -work demo_de0_sys_tb_demo_de0_sys_inst_lcd_bfm                                                 
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_hd_bfm                                                  
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0003.sv"                            -work demo_de0_sys_tb_demo_de0_sys_inst_hd_bfm                                                  
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_pll_areset_bfm                                          
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0002.sv"                            -work demo_de0_sys_tb_demo_de0_sys_inst_pll_areset_bfm                                          
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_pll_phasedone_bfm                                       
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm.sv"                                 -work demo_de0_sys_tb_demo_de0_sys_inst_pll_phasedone_bfm                                       
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_reset_bfm                                               
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_reset_source.sv"                         -work demo_de0_sys_tb_demo_de0_sys_inst_reset_bfm                                               
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_clk_bfm                                                 
  vlog -sv "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_clock_source.sv"                         -work demo_de0_sys_tb_demo_de0_sys_inst_clk_bfm                                                 
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys.v"                                        -work demo_de0_sys_tb_demo_de0_sys_inst                                                         
  vlog     "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/demo_de0_sys_tb.v"                                                                                                                                                
}

# ----------------------------------------
# Elaborate top level design
alias elab {
  echo "\[exec\] elab"
  vsim -t ps -L work -L demo_de0_sys_tb_tda -L demo_de0_sys_tb_tdt -L demo_de0_sys_tb_irq_mapper -L demo_de0_sys_tb_crosser -L demo_de0_sys_tb_width_adapter -L demo_de0_sys_tb_rsp_xbar_demux_013 -L demo_de0_sys_tb_cmd_xbar_mux_013 -L demo_de0_sys_tb_cmd_xbar_demux_002 -L demo_de0_sys_tb_rsp_xbar_mux_001 -L demo_de0_sys_tb_rsp_xbar_mux -L demo_de0_sys_tb_rsp_xbar_demux_003 -L demo_de0_sys_tb_rsp_xbar_demux -L demo_de0_sys_tb_cmd_xbar_mux -L demo_de0_sys_tb_cmd_xbar_demux_001 -L demo_de0_sys_tb_cmd_xbar_demux -L demo_de0_sys_tb_rst_controller -L demo_de0_sys_tb_burst_adapter -L demo_de0_sys_tb_id_router_013 -L demo_de0_sys_tb_addr_router_002 -L demo_de0_sys_tb_id_router_003 -L demo_de0_sys_tb_id_router_002 -L demo_de0_sys_tb_id_router -L demo_de0_sys_tb_addr_router_001 -L demo_de0_sys_tb_addr_router -L demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator_avalon_universal_master_0_agent -L demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent_rsp_fifo -L demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent -L demo_de0_sys_tb_nios2_qsys_0_jtag_debug_module_translator -L demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator -L demo_de0_sys_tb_pio_0 -L demo_de0_sys_tb_spi_0 -L demo_de0_sys_tb_timer_0 -L demo_de0_sys_tb_timing_adapter -L demo_de0_sys_tb_data_format_adapter -L demo_de0_sys_tb_sdram_0 -L demo_de0_sys_tb_m2vdd_hx8347a_0 -L demo_de0_sys_tb_hexdisp_0 -L demo_de0_sys_tb_m2vdec_0 -L demo_de0_sys_tb_fifo_0 -L demo_de0_sys_tb_flash_0 -L demo_de0_sys_tb_rom_0 -L demo_de0_sys_tb_ram_0 -L demo_de0_sys_tb_sysid_qsys_0 -L demo_de0_sys_tb_nios2_qsys_0 -L demo_de0_sys_tb_altpll_0 -L demo_de0_sys_tb_sdram_0_my_partner -L demo_de0_sys_tb_rom_0_external_mem_bfm -L demo_de0_sys_tb_flash_0_tcb_translator -L demo_de0_sys_tb_demo_de0_sys_inst_sw_bfm -L demo_de0_sys_tb_demo_de0_sys_inst_sdcard_bfm -L demo_de0_sys_tb_demo_de0_sys_inst_lcd_bfm -L demo_de0_sys_tb_demo_de0_sys_inst_hd_bfm -L demo_de0_sys_tb_demo_de0_sys_inst_pll_areset_bfm -L demo_de0_sys_tb_demo_de0_sys_inst_pll_phasedone_bfm -L demo_de0_sys_tb_demo_de0_sys_inst_reset_bfm -L demo_de0_sys_tb_demo_de0_sys_inst_clk_bfm -L demo_de0_sys_tb_demo_de0_sys_inst -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneiii_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Elaborate the top level design with novopt option
alias elab_debug {
  echo "\[exec\] elab_debug"
  vsim -novopt -t ps -L work -L demo_de0_sys_tb_tda -L demo_de0_sys_tb_tdt -L demo_de0_sys_tb_irq_mapper -L demo_de0_sys_tb_crosser -L demo_de0_sys_tb_width_adapter -L demo_de0_sys_tb_rsp_xbar_demux_013 -L demo_de0_sys_tb_cmd_xbar_mux_013 -L demo_de0_sys_tb_cmd_xbar_demux_002 -L demo_de0_sys_tb_rsp_xbar_mux_001 -L demo_de0_sys_tb_rsp_xbar_mux -L demo_de0_sys_tb_rsp_xbar_demux_003 -L demo_de0_sys_tb_rsp_xbar_demux -L demo_de0_sys_tb_cmd_xbar_mux -L demo_de0_sys_tb_cmd_xbar_demux_001 -L demo_de0_sys_tb_cmd_xbar_demux -L demo_de0_sys_tb_rst_controller -L demo_de0_sys_tb_burst_adapter -L demo_de0_sys_tb_id_router_013 -L demo_de0_sys_tb_addr_router_002 -L demo_de0_sys_tb_id_router_003 -L demo_de0_sys_tb_id_router_002 -L demo_de0_sys_tb_id_router -L demo_de0_sys_tb_addr_router_001 -L demo_de0_sys_tb_addr_router -L demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator_avalon_universal_master_0_agent -L demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent_rsp_fifo -L demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent -L demo_de0_sys_tb_nios2_qsys_0_jtag_debug_module_translator -L demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator -L demo_de0_sys_tb_pio_0 -L demo_de0_sys_tb_spi_0 -L demo_de0_sys_tb_timer_0 -L demo_de0_sys_tb_timing_adapter -L demo_de0_sys_tb_data_format_adapter -L demo_de0_sys_tb_sdram_0 -L demo_de0_sys_tb_m2vdd_hx8347a_0 -L demo_de0_sys_tb_hexdisp_0 -L demo_de0_sys_tb_m2vdec_0 -L demo_de0_sys_tb_fifo_0 -L demo_de0_sys_tb_flash_0 -L demo_de0_sys_tb_rom_0 -L demo_de0_sys_tb_ram_0 -L demo_de0_sys_tb_sysid_qsys_0 -L demo_de0_sys_tb_nios2_qsys_0 -L demo_de0_sys_tb_altpll_0 -L demo_de0_sys_tb_sdram_0_my_partner -L demo_de0_sys_tb_rom_0_external_mem_bfm -L demo_de0_sys_tb_flash_0_tcb_translator -L demo_de0_sys_tb_demo_de0_sys_inst_sw_bfm -L demo_de0_sys_tb_demo_de0_sys_inst_sdcard_bfm -L demo_de0_sys_tb_demo_de0_sys_inst_lcd_bfm -L demo_de0_sys_tb_demo_de0_sys_inst_hd_bfm -L demo_de0_sys_tb_demo_de0_sys_inst_pll_areset_bfm -L demo_de0_sys_tb_demo_de0_sys_inst_pll_phasedone_bfm -L demo_de0_sys_tb_demo_de0_sys_inst_reset_bfm -L demo_de0_sys_tb_demo_de0_sys_inst_clk_bfm -L demo_de0_sys_tb_demo_de0_sys_inst -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneiii_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Compile all the design files and elaborate the top level design
alias ld "
  dev_com
  com
  elab
"

# ----------------------------------------
# Compile all the design files and elaborate the top level design with -novopt
alias ld_debug "
  dev_com
  com
  elab_debug
"

# ----------------------------------------
# Print out user commmand line aliases
alias h {
  echo "List Of Command Line Aliases"
  echo
  echo "dev_com                       -- Compile device library files"
  echo
  echo "com                           -- Compile the design files in correct order"
  echo
  echo "elab                          -- Elaborate top level design"
  echo
  echo "elab_debug                    -- Elaborate the top level design with novopt option"
  echo
  echo "ld                            -- Compile all the design files and elaborate the top level design"
  echo
  echo "ld_debug                      -- Compile all the design files and elaborate the top level design with -novopt"
  echo
  echo 
  echo
  echo "List Of Variables"
  echo
  echo "TOP_LEVEL_NAME                -- Top level module name."
  echo
  echo "SYSTEM_INSTANCE_NAME          -- Instantiated system module name inside top level module."
  echo
  echo "QSYS_SIMDIR                   -- Qsys base simulation directory."
}
h
