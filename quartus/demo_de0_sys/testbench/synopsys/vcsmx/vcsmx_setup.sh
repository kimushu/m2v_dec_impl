
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
# vcsmx - auto-generated simulation script

# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="demo_de0_sys_tb"
QSYS_SIMDIR="./../../"
SKIP_FILE_COPY=0
SKIP_DEV_COM=0
SKIP_COM=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="+vcs+finish+100"

# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh <simulator>_setup.sh SKIP_ELAB=1 SKIP_SIM=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

# ----------------------------------------
# create compilation libraries
mkdir -p ./libraries/work/
mkdir -p ./libraries/demo_de0_sys_tb_tda/
mkdir -p ./libraries/demo_de0_sys_tb_tdt/
mkdir -p ./libraries/demo_de0_sys_tb_irq_mapper/
mkdir -p ./libraries/demo_de0_sys_tb_crosser/
mkdir -p ./libraries/demo_de0_sys_tb_width_adapter/
mkdir -p ./libraries/demo_de0_sys_tb_rsp_xbar_demux_013/
mkdir -p ./libraries/demo_de0_sys_tb_cmd_xbar_mux_013/
mkdir -p ./libraries/demo_de0_sys_tb_cmd_xbar_demux_002/
mkdir -p ./libraries/demo_de0_sys_tb_rsp_xbar_mux_001/
mkdir -p ./libraries/demo_de0_sys_tb_rsp_xbar_mux/
mkdir -p ./libraries/demo_de0_sys_tb_rsp_xbar_demux_003/
mkdir -p ./libraries/demo_de0_sys_tb_rsp_xbar_demux/
mkdir -p ./libraries/demo_de0_sys_tb_cmd_xbar_mux/
mkdir -p ./libraries/demo_de0_sys_tb_cmd_xbar_demux_001/
mkdir -p ./libraries/demo_de0_sys_tb_cmd_xbar_demux/
mkdir -p ./libraries/demo_de0_sys_tb_rst_controller/
mkdir -p ./libraries/demo_de0_sys_tb_burst_adapter/
mkdir -p ./libraries/demo_de0_sys_tb_id_router_013/
mkdir -p ./libraries/demo_de0_sys_tb_addr_router_002/
mkdir -p ./libraries/demo_de0_sys_tb_id_router_003/
mkdir -p ./libraries/demo_de0_sys_tb_id_router_002/
mkdir -p ./libraries/demo_de0_sys_tb_id_router/
mkdir -p ./libraries/demo_de0_sys_tb_addr_router_001/
mkdir -p ./libraries/demo_de0_sys_tb_addr_router/
mkdir -p ./libraries/demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator_avalon_universal_master_0_agent/
mkdir -p ./libraries/demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent_rsp_fifo/
mkdir -p ./libraries/demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent/
mkdir -p ./libraries/demo_de0_sys_tb_nios2_qsys_0_jtag_debug_module_translator/
mkdir -p ./libraries/demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator/
mkdir -p ./libraries/demo_de0_sys_tb_pio_0/
mkdir -p ./libraries/demo_de0_sys_tb_spi_0/
mkdir -p ./libraries/demo_de0_sys_tb_timer_0/
mkdir -p ./libraries/demo_de0_sys_tb_timing_adapter/
mkdir -p ./libraries/demo_de0_sys_tb_data_format_adapter/
mkdir -p ./libraries/demo_de0_sys_tb_sdram_0/
mkdir -p ./libraries/demo_de0_sys_tb_m2vdd_hx8347a_0/
mkdir -p ./libraries/demo_de0_sys_tb_hexdisp_0/
mkdir -p ./libraries/demo_de0_sys_tb_m2vdec_0/
mkdir -p ./libraries/demo_de0_sys_tb_fifo_0/
mkdir -p ./libraries/demo_de0_sys_tb_flash_0/
mkdir -p ./libraries/demo_de0_sys_tb_rom_0/
mkdir -p ./libraries/demo_de0_sys_tb_ram_0/
mkdir -p ./libraries/demo_de0_sys_tb_sysid_qsys_0/
mkdir -p ./libraries/demo_de0_sys_tb_nios2_qsys_0/
mkdir -p ./libraries/demo_de0_sys_tb_altpll_0/
mkdir -p ./libraries/demo_de0_sys_tb_sdram_0_my_partner/
mkdir -p ./libraries/demo_de0_sys_tb_rom_0_external_mem_bfm/
mkdir -p ./libraries/demo_de0_sys_tb_flash_0_tcb_translator/
mkdir -p ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_sw_bfm/
mkdir -p ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_sdcard_bfm/
mkdir -p ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_lcd_bfm/
mkdir -p ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_hd_bfm/
mkdir -p ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_pll_areset_bfm/
mkdir -p ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_pll_phasedone_bfm/
mkdir -p ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_reset_bfm/
mkdir -p ./libraries/demo_de0_sys_tb_demo_de0_sys_inst_clk_bfm/
mkdir -p ./libraries/demo_de0_sys_tb_demo_de0_sys_inst/
mkdir -p ./libraries/altera_ver/
mkdir -p ./libraries/lpm_ver/
mkdir -p ./libraries/sgate_ver/
mkdir -p ./libraries/altera_mf_ver/
mkdir -p ./libraries/altera_lnsim_ver/
mkdir -p ./libraries/cycloneiii_ver/

# ----------------------------------------
# copy RAM/ROM files to simulation directory
if [ $SKIP_FILE_COPY -eq 0 ]; then
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vctrl_code.mif ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_fram.mif ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_rom.mif ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2visdq_cmem.mif ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vmc_fetch.mif ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vvld_table.mif ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_ram_0.hex ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_rf_ram_b.mif ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_rf_ram_a.hex ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_rf_ram_b.hex ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_rf_ram_a.mif ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_ociram_default_contents.dat ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_rf_ram_a.dat ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_rf_ram_b.dat ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_ociram_default_contents.mif ./
  cp -f $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_ociram_default_contents.hex ./
fi

# ----------------------------------------
# compile device library files
if [ $SKIP_DEV_COM -eq 0 ]; then
  vlogan +v2k           "/opt/altera/11.1sp2/quartus/eda/sim_lib/altera_primitives.v" -work altera_ver      
  vlogan +v2k           "/opt/altera/11.1sp2/quartus/eda/sim_lib/220model.v"          -work lpm_ver         
  vlogan +v2k           "/opt/altera/11.1sp2/quartus/eda/sim_lib/sgate.v"             -work sgate_ver       
  vlogan +v2k           "/opt/altera/11.1sp2/quartus/eda/sim_lib/altera_mf.v"         -work altera_mf_ver   
  vlogan +v2k -sverilog "/opt/altera/11.1sp2/quartus/eda/sim_lib/altera_lnsim.sv"     -work altera_lnsim_ver
  vlogan +v2k           "/opt/altera/11.1sp2/quartus/eda/sim_lib/cycloneiii_atoms.v"  -work cycloneiii_ver  
fi

# ----------------------------------------
# compile design files in correct order
if [ $SKIP_COM -eq 0 ]; then
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_tristate_controller_aggregator.sv"              -work demo_de0_sys_tb_tda                                                                       
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_tristate_controller_translator.sv"              -work demo_de0_sys_tb_tdt                                                                       
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_irq_mapper.sv"                            -work demo_de0_sys_tb_irq_mapper                                                                
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_st_handshake_clock_crosser.v"            -work demo_de0_sys_tb_crosser                                                                   
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_st_clock_crosser.v"                      -work demo_de0_sys_tb_crosser                                                                   
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_st_pipeline_base.v"                      -work demo_de0_sys_tb_crosser                                                                   
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_width_adapter.sv"                        -work demo_de0_sys_tb_width_adapter                                                             
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_burst_uncompressor.sv"                   -work demo_de0_sys_tb_width_adapter                                                             
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_demux_013.sv"                    -work demo_de0_sys_tb_rsp_xbar_demux_013                                                        
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_arbitrator.sv"                           -work demo_de0_sys_tb_cmd_xbar_mux_013                                                          
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_mux_013.sv"                      -work demo_de0_sys_tb_cmd_xbar_mux_013                                                          
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_demux_002.sv"                    -work demo_de0_sys_tb_cmd_xbar_demux_002                                                        
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_arbitrator.sv"                           -work demo_de0_sys_tb_rsp_xbar_mux_001                                                          
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_mux_001.sv"                      -work demo_de0_sys_tb_rsp_xbar_mux_001                                                          
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_arbitrator.sv"                           -work demo_de0_sys_tb_rsp_xbar_mux                                                              
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_mux.sv"                          -work demo_de0_sys_tb_rsp_xbar_mux                                                              
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_demux_003.sv"                    -work demo_de0_sys_tb_rsp_xbar_demux_003                                                        
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_demux.sv"                        -work demo_de0_sys_tb_rsp_xbar_demux                                                            
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_arbitrator.sv"                           -work demo_de0_sys_tb_cmd_xbar_mux                                                              
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_mux.sv"                          -work demo_de0_sys_tb_cmd_xbar_mux                                                              
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_demux_001.sv"                    -work demo_de0_sys_tb_cmd_xbar_demux_001                                                        
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_demux.sv"                        -work demo_de0_sys_tb_cmd_xbar_demux                                                            
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_reset_controller.v"                             -work demo_de0_sys_tb_rst_controller                                                            
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_reset_synchronizer.v"                           -work demo_de0_sys_tb_rst_controller                                                            
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_burst_adapter.sv"                        -work demo_de0_sys_tb_burst_adapter                                                             
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_id_router_013.sv"                         -work demo_de0_sys_tb_id_router_013                                                             
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_addr_router_002.sv"                       -work demo_de0_sys_tb_addr_router_002                                                           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_id_router_003.sv"                         -work demo_de0_sys_tb_id_router_003                                                             
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_id_router_002.sv"                         -work demo_de0_sys_tb_id_router_002                                                             
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_id_router.sv"                             -work demo_de0_sys_tb_id_router                                                                 
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_addr_router_001.sv"                       -work demo_de0_sys_tb_addr_router_001                                                           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_addr_router.sv"                           -work demo_de0_sys_tb_addr_router                                                               
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_master_agent.sv"                         -work demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator_avalon_universal_master_0_agent
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_sc_fifo.v"                               -work demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent_rsp_fifo          
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_slave_agent.sv"                          -work demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent                   
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_burst_uncompressor.sv"                   -work demo_de0_sys_tb_fifo_0_in_csr_translator_avalon_universal_slave_0_agent                   
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_slave_translator.sv"                     -work demo_de0_sys_tb_nios2_qsys_0_jtag_debug_module_translator                                 
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_master_translator.sv"                    -work demo_de0_sys_tb_nios2_qsys_0_instruction_master_translator                                
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_pio_0.v"                                  -work demo_de0_sys_tb_pio_0                                                                     
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_spi_0.v"                                  -work demo_de0_sys_tb_spi_0                                                                     
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_timer_0.v"                                -work demo_de0_sys_tb_timer_0                                                                   
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_timing_adapter.v"                         -work demo_de0_sys_tb_timing_adapter                                                            
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_timing_adapter_fifo.v"                    -work demo_de0_sys_tb_timing_adapter                                                            
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_data_format_adapter.v"                    -work demo_de0_sys_tb_data_format_adapter                                                       
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_data_format_adapter_state_ram.v"          -work demo_de0_sys_tb_data_format_adapter                                                       
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_data_format_adapter_data_ram.v"           -work demo_de0_sys_tb_data_format_adapter                                                       
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_sdram_0_test_component.v"                 -work demo_de0_sys_tb_sdram_0                                                                   
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_sdram_0.v"                                -work demo_de0_sys_tb_sdram_0                                                                   
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vdd_hx8347a.v"                                       -work demo_de0_sys_tb_m2vdd_hx8347a_0                                                           
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vfbagen.v"                                           -work demo_de0_sys_tb_m2vdd_hx8347a_0                                                           
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/ycbcr2rgb.v"                                           -work demo_de0_sys_tb_m2vdd_hx8347a_0                                                           
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vdd_hx8347a_buf.v"                                   -work demo_de0_sys_tb_m2vdd_hx8347a_0                                                           
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vdd_hx8347a_fifo.v"                                  -work demo_de0_sys_tb_m2vdd_hx8347a_0                                                           
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/ycbcr2rgb_mac.v"                                       -work demo_de0_sys_tb_m2vdd_hx8347a_0                                                           
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/seg7led_static.v"                                      -work demo_de0_sys_tb_hexdisp_0                                                                 
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vdec.v"                                              -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vfbagen.v"                                           -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vctrl.v"                                             -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vctrl_code.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct.v"                                             -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_fram.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_iram.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_mult.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_rom.v"                                         -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2visdq.v"                                             -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2visdq_cmem.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2visdq_dmem.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2visdq_mult.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vmc.v"                                               -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vmc_fetch.v"                                         -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vmc_frameptr.v"                                      -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vsdp.v"                                              -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vside1.v"                                            -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vside2.v"                                            -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vside3.v"                                            -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vside4.v"                                            -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vstbuf.v"                                            -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vstbuf_fifo.v"                                       -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vstbuf_shifter.v"                                    -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vvld.v"                                              -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vvld_table.v"                                        -work demo_de0_sys_tb_m2vdec_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_fifo_0.v"                                 -work demo_de0_sys_tb_fifo_0                                                                    
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_flash_0.sv"                               -work demo_de0_sys_tb_flash_0                                                                   
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rom_0.v"                                  -work demo_de0_sys_tb_rom_0                                                                     
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_ram_0.v"                                  -work demo_de0_sys_tb_ram_0                                                                     
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_sysid_qsys_0.vo"                          -work demo_de0_sys_tb_sysid_qsys_0                                                              
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_jtag_debug_module_tck.v"     -work demo_de0_sys_tb_nios2_qsys_0                                                              
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_test_bench.v"                -work demo_de0_sys_tb_nios2_qsys_0                                                              
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0.v"                           -work demo_de0_sys_tb_nios2_qsys_0                                                              
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_jtag_debug_module_wrapper.v" -work demo_de0_sys_tb_nios2_qsys_0                                                              
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_jtag_debug_module_sysclk.v"  -work demo_de0_sys_tb_nios2_qsys_0                                                              
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_oci_test_bench.v"            -work demo_de0_sys_tb_nios2_qsys_0                                                              
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_altpll_0.vo"                              -work demo_de0_sys_tb_altpll_0                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_sdram_partner_module.v"                         -work demo_de0_sys_tb_sdram_0_my_partner                                                        
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_external_memory_bfm.sv"                         -work demo_de0_sys_tb_rom_0_external_mem_bfm                                                    
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_inout.sv"                                       -work demo_de0_sys_tb_flash_0_tcb_translator                                                    
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_tristate_conduit_bridge_translator.sv"          -work demo_de0_sys_tb_flash_0_tcb_translator                                                    
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_sw_bfm                                                  
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0006.sv"                            -work demo_de0_sys_tb_demo_de0_sys_inst_sw_bfm                                                  
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_sdcard_bfm                                              
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0005.sv"                            -work demo_de0_sys_tb_demo_de0_sys_inst_sdcard_bfm                                              
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_lcd_bfm                                                 
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0004.sv"                            -work demo_de0_sys_tb_demo_de0_sys_inst_lcd_bfm                                                 
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_hd_bfm                                                  
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0003.sv"                            -work demo_de0_sys_tb_demo_de0_sys_inst_hd_bfm                                                  
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_pll_areset_bfm                                          
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0002.sv"                            -work demo_de0_sys_tb_demo_de0_sys_inst_pll_areset_bfm                                          
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_pll_phasedone_bfm                                       
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm.sv"                                 -work demo_de0_sys_tb_demo_de0_sys_inst_pll_phasedone_bfm                                       
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_reset_bfm                                               
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_reset_source.sv"                         -work demo_de0_sys_tb_demo_de0_sys_inst_reset_bfm                                               
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv"                                      -work demo_de0_sys_tb_demo_de0_sys_inst_clk_bfm                                                 
  vlogan +v2k -sverilog "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_clock_source.sv"                         -work demo_de0_sys_tb_demo_de0_sys_inst_clk_bfm                                                 
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys.v"                                        -work demo_de0_sys_tb_demo_de0_sys_inst                                                         
  vlogan +v2k           "$QSYS_SIMDIR/demo_de0_sys_tb/simulation/demo_de0_sys_tb.v"                                                                                                                                                
fi

# ----------------------------------------
# elaborate top level design
if [ $SKIP_ELAB -eq 0 ]; then
  vcs -lca -t ps $USER_DEFINED_ELAB_OPTIONS $TOP_LEVEL_NAME
fi

# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $USER_DEFINED_SIM_OPTIONS
fi
