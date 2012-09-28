#================================================================================
# Common makefile for testing
#================================================================================

# Default target
compile:

# Directories
TEST_ROOT := $(patsubst %/,%,$(dir $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))))
RTL_DIR    = $(TEST_ROOT)/../rtl
WORK_DIR   = ./work
OBJ_DIR    = ./obj
DUMP_DIR   = ./dump
REF_DIR    = $(TEST_ROOT)/ref
SIM_TOOL   = modelsim

vpath %.v $(RTL_DIR)

# Environments
include $(TEST_ROOT)/../altera.mk
#include $(TEST_ROOT)/$(SIM_TOOL).mk
Q ?= @
VLFLAGS += -lint -quiet +incdir+$(RTL_DIR) +define+SIM=1
VSFLAGS = -lib $(WORK_DIR) $(addprefix -L ,$(VS_LIBS)) \
			-GREF_DIR=\"$(REF_DIR)\" -GDUMP_DIR=\"$(DUMP_DIR)\" \
			-sv_root $(OBJ_DIR)
CXXFLAGS += -m32 -pthread -O2 -Wall -fPIC -g \
			-I$(TEST_ROOT) -I$(dir $(shell which vlog))../include

include $(TEST_ROOT)/modules.mk

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
	$(Q)(vsim $(VSFLAGS) -c -l /dev/null -dpiexportobj $(basename $@) $* > $(basename $@).log) || \
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
	@echo "****"
	@echo "**** Please create symbolic link to reference data directory generated"
	@echo "**** by software decoder (m2v_dec_eval) at \`$@'."
	@echo "**** (This is NOT automatically executed by Makefiles)"
	@echo "**** For example: ln -s <project_root>/m2v_dec_eval/ref_testmovie1.mpg.vs $@"
	@echo "****"
	@test

# MIF generation & create symbolic links
.PHONY: mif mif.gen mif.link
mif: mif.gen mif.link

mif.gen:
	$(Q)$(MAKE) -C $(RTL_DIR) mif

mif.link: $(notdir $(wildcard $(RTL_DIR)/*.mif))

%.mif: $(RTL_DIR)/%.mif
	$(Q)ln -s $< $@

# Simulation environments
.PHONY: env
env: env.altera

# Execute simulation
SIM_CMD = vsim $(VSFLAGS) $(addprefix -sv_lib ,$(MODULES_DPI_C)) $(MODULES_DPI_C)

.PHONY: test wave
test: env compile mif dir.ref
	$(Q)LANG=C $(SIM_CMD) -c -do "run -all; quit -force"

wave: env compile mif dir.ref
	$(Q)LANG=C vsim -do "proc load_tb {} {$(SIM_CMD); do $(firstword $(MODULES_DPI_C)).do}; load_tb"

# Cleanup
.PHONY: clean.common
clean.common:
	@echo Cleaning up
	$(Q)rm -rf $(WORK_DIR) $(OBJ_DIR)
	$(Q)rm -f $(addsuffix .h,$(MODULES_DPI_C))
	$(Q)rm -f *.mif *.ver
	$(Q)rm -f transcript vsim.wlf

