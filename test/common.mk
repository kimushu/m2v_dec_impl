#================================================================================
# Common makefile for testing
#================================================================================

# Directories
TEST_ROOT = $(dir $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))
RTL_DIR   = $(TEST_ROOT)../rtl
WORK_DIR  = $(TEST_ROOT)work
OBJ_DIR   = ./obj
DUMP_DIR  = ./dump
REF_DIR   = $(TEST_ROOT)ref

ALTERA_ROOT = /opt/altera/11.1sp2
SOPC_ROOT   = $(ALTERA_ROOT)/ip/altera/sopc_builder_ip

vpath %.v $(RTL_DIR)

# Environments
Q ?= @
VS_LIBS += altera_mf_ver lpm_ver
VLFLAGS += -lint -quiet +incdir+$(RTL_DIR) +define+SIM=1
VSFLAGS = -lib $(WORK_DIR) $(addprefix -L ,$(VS_LIBS)) \
			-GREF_DIR=\"$(REF_DIR)\" -GDUMP_DIR=\"$(DUMP_DIR)\" \
			-sv_root $(OBJ_DIR)
CXXFLAGS += -m32 -pthread -O2 -Wall -fPIC \
			-I$(TEST_ROOT) -I$(dir $(shell which vlog))../include

# Modules (except m2vdec)
MODULES_V += \
	m2vctrl \
		m2vctrl_code \
		m2vsdp \
		m2vstbuf \
			m2vstbuf_fifo \
			m2vstbuf_shifter \
		m2vvld \
			m2vvld_table \
	m2visdq \
		m2visdq_cmem \
		m2visdq_dmem \
		m2visdq_mult \
	m2vidct \
		m2vidct_fram \
		m2vidct_iram \
		m2vidct_mult \
		m2vidct_rom \
	m2vmc \
		m2vmc_fetch \
		m2vmc_frameptr \
	m2vdd_hx8347a \
		m2vdd_hx8347a_buf \
		m2vdd_hx8347a_fifo \
		ycbcr2rgb \
			ycbcr2rgb_mac

# Common targets
.PHONY: compile vlog cc
compile: vlog dpic
vlog: dir.work $(foreach v,$(MODULES_V) $(MODULES_DPI_C),$(WORK_DIR)/$(v)/_primary.dat)
dpic: dir.obj $(foreach v,$(MODULES_DPI_C),$(OBJ_DIR)/$(v).so)

# Compile verilog files
$(WORK_DIR)/%/_primary.dat: %.v
	@echo "Compiling $<"
	$(Q)vlog $(VLFLAGS) -work $(WORK_DIR) $<

# Compile SystemVerilog files
$(WORK_DIR)/%/_primary.dat: %.sv
	@echo "Compiling $<"
	$(Q)vlog $(VLFLAGS) -work $(WORK_DIR) \
		$(foreach m,$(filter $(MODULES_DPI_C),$*),+define+DPI_C=1 -dpiheader $(m).h) $<

# Compile C++ sources for DPI-C
.PRECIOUS: $(addprefix $(OBJ_DIR)/,$(SOURCES:.cpp=.o))
$(OBJ_DIR)/%.o: %.cpp
	@echo "Compiling $<"
	$(Q)g++ $(CXXFLAGS) -c -o $@ $<

# Export headers for SystemVerilog with DPI-C
.PRECIOUS: $(foreach v,$(MODULES_DPI_C),$(OBJ_DIR)/$(v).o)
$(OBJ_DIR)/%.o: $(WORK_DIR)/%/_primary.dat
	@echo "Generating DPI-export object for $*"
	$(Q)(vsim $(VSFLAGS) -c -dpiexportobj $(basename $@) $* > $(basename $@).log) || \
		(grep Error: --color $(basename $@).log; test)
	$(Q)rm $(basename $@).so

# Link so for vsim
$(OBJ_DIR)/%.so: $(OBJ_DIR)/%.o $(addprefix $(OBJ_DIR)/,$(SOURCES:.cpp=.o))
	@echo "Linking $@"
	$(Q)g++ $(LDFLAGS) $(CXXFLAGS) -shared -o $@ $^

# Create directories
.PHONY: dir.work
dir.work: $(WORK_DIR)/_info

$(WORK_DIR)/_info:
	@echo Creating library at $(WORK_DIR)
	$(Q)vlib $(WORK_DIR)

.PHONY: dir.obj
dir.obj: $(OBJ_DIR)

$(OBJ_DIR):
	$(Q)mkdir -p $@

.PHONY: dir.dump
dir.dump: $(DUMP_DIR)

$(DUMP_DIR):
	$(Q)mkdir -p $@

.PHONY: dir.ref
dir.ref: $(REF_DIR)

$(REF_DIR):
	@echo **** Please create symbolic link to reference data directory generated
	@echo **** by software decoder \(m2v_dec_eval\) at \`$@\'.
	@echo **** (This is NOT automatically executed by Makefiles)
	@echo ****
	@echo **** For example: ln -s \<project_root\>/m2v_dec_eval/ref_testmovie1.mpg.vs $@
	@test

# MIF generation & create symbolic links
.PHONY: mif mif.gen mif.link
mif: mif.gen mif.link

mif.gen:
	$(Q)$(MAKE) -C $(RTL_DIR)

mif.link: $(notdir $(wildcard $(RTL_DIR)/*.mif))

%.mif: $(RTL_DIR)/%.mif
	$(Q)ln -s $< $@

# Execute simulation
.PHONY: sim wave
sim: compile mif
	$(Q)vsim $(VSFLAGS) -do "run -all; quit -force" \
		$(addprefix -sv_lib ,$(MODULES_DPI_C)) $(MODULES_DPI_C)

wave: compile mif
	$(Q)vsim $(VSFLAGS) -do "$(firstword $(MODULES_DPI_C)).do" \
		$(addprefix -sv_lib ,$(MODULES_DPI_C)) $(MODULES_DPI_C)

# Cleanup
.PHONY: clean.common
clean.common:
	@echo Cleaning up
	$(Q)rm -rf $(WORK_DIR) $(OBJ_DIR)
	$(Q)rm -f $(addsuffix .h,$(MODULES_DPI_C))
	$(Q)rm -f *.mif *.ver
	$(Q)rm -f transcript vsim.wlf

