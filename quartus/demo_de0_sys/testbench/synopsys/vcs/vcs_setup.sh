
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
# vcs - auto-generated simulation script

# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="demo_de0_sys_tb"
SKIP_FILE_COPY=0
QSYS_SIMDIR="./../../"
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

vcs -lca -timescale=1ps/1ps +v2k +systemverilogext+.sv -ntb_opts dtm $USER_DEFINED_ELAB_OPTIONS \
  -v /opt/altera/11.1sp2/quartus/eda/sim_lib/altera_primitives.v \
  -v /opt/altera/11.1sp2/quartus/eda/sim_lib/220model.v \
  -v /opt/altera/11.1sp2/quartus/eda/sim_lib/sgate.v \
  -v /opt/altera/11.1sp2/quartus/eda/sim_lib/altera_mf.v \
  /opt/altera/11.1sp2/quartus/eda/sim_lib/altera_lnsim.sv \
  -v /opt/altera/11.1sp2/quartus/eda/sim_lib/cycloneiii_atoms.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_tristate_controller_aggregator.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_tristate_controller_translator.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_irq_mapper.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_st_handshake_clock_crosser.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_st_clock_crosser.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_st_pipeline_base.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_width_adapter.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_burst_uncompressor.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_demux_013.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_arbitrator.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_mux_013.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_demux_002.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_mux_001.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_mux.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_demux_003.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rsp_xbar_demux.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_mux.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_demux_001.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_cmd_xbar_demux.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_reset_controller.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_reset_synchronizer.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_burst_adapter.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_id_router_013.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_addr_router_002.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_id_router_003.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_id_router_002.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_id_router.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_addr_router_001.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_addr_router.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_master_agent.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_sc_fifo.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_slave_agent.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_slave_translator.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_merlin_master_translator.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_pio_0.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_spi_0.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_timer_0.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_timing_adapter.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_timing_adapter_fifo.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_data_format_adapter.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_data_format_adapter_state_ram.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_data_format_adapter_data_ram.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_sdram_0_test_component.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_sdram_0.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vdd_hx8347a.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vfbagen.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/ycbcr2rgb.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vdd_hx8347a_buf.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vdd_hx8347a_fifo.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/ycbcr2rgb_mac.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/seg7led_static.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vdec.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vctrl.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vctrl_code.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_fram.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_iram.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_mult.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vidct_rom.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2visdq.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2visdq_cmem.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2visdq_dmem.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2visdq_mult.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vmc.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vmc_fetch.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vmc_frameptr.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vsdp.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vside1.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vside2.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vside3.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vside4.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vstbuf.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vstbuf_fifo.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vstbuf_shifter.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vvld.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/m2vvld_table.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_fifo_0.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_flash_0.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_rom_0.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_ram_0.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_sysid_qsys_0.vo \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_jtag_debug_module_tck.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_test_bench.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_jtag_debug_module_wrapper.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_jtag_debug_module_sysclk.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_nios2_qsys_0_oci_test_bench.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys_altpll_0.vo \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_sdram_partner_module.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_external_memory_bfm.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_inout.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_tristate_conduit_bridge_translator.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/verbosity_pkg.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0006.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0005.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0004.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0003.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm_0002.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_conduit_bfm.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_reset_source.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/altera_avalon_clock_source.sv \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/submodules/demo_de0_sys.v \
  $QSYS_SIMDIR/demo_de0_sys_tb/simulation/demo_de0_sys_tb.v \
  -top $TOP_LEVEL_NAME
# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $USER_DEFINED_SIM_OPTIONS
fi
