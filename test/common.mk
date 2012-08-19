#================================================================================
# Common makefile for testing
#================================================================================

# Directories
TEST_ROOT = $(dir $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))
WORK_DIR = $(TEST_ROOT)work
OBJ_DIR = ./obj
RTL_DIR = $(TEST_ROOT)../rtl
vpath %.v $(RTL_DIR)

# Modules (except m2vdec)
MODULES_V += \
	m2vctrl \
		m2vctrl_code \
		m2vsdp \
		m2vstbuf \
			m2vstbuf_fifo m2vstbuf_shifter \
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

# Environments
Q ?= @
VLFLAGS += -lint -quiet +incdir+$(RTL_DIR) +define+SIM=1
CXXFLAGS += -m32 -pthread -O2 -Wall -fPIC \
			-I. -I$(OBJ_DIR) -I$(dir $(shell which vlog))../include

# Common targets
.PHONY: compile vlog cc
compile: vlog dpic
vlog: dir.work $(foreach v,$(MODULES_V) $(MODULES_DPI_C),$(WORK_DIR)/$(v)/_primary.dat)
dpic: dir.obj $(foreach v,$(MODULES_DPI_C),$(OBJ_DIR)/$(v).so)

$(WORK_DIR)/%/_primary.dat: %.v
	@echo "Compiling $<"
	$(Q)vlog $(VLFLAGS) -work $(WORK_DIR) $<

$(WORK_DIR)/%/_primary.dat: %.sv
	@echo "Compiling $<"
	$(Q)vlog $(VLFLAGS) -work $(WORK_DIR) \
		$(foreach m,$(filter $(MODULES_DPI_C),$*),-dpiheader $(m).h) $<

.PRECIOUS: $(addprefix $(OBJ_DIR)/,$(SOURCES:.cpp=.o))
$(OBJ_DIR)/%.o: %.cpp
	@echo "Compiling $<"
	$(Q)g++ $(CXXFLAGS) -c -o $@ $<

.PRECIOUS: $(foreach v,$(MODULES_DPI_C),$(OBJ_DIR)/$(v).o)
$(OBJ_DIR)/%.o: $(WORK_DIR)/%/_primary.dat
	@echo "Generating DPI-export object for $*"
	$(Q)(vsim $(VSFLAGS) -c -lib $(WORK_DIR) -dpiexportobj $(basename $@) $* > $(basename $@).log) || \
		(grep -i error --color $(basename $@).log; test)
	$(Q)rm $(basename $@).so

$(OBJ_DIR)/%.so: $(OBJ_DIR)/%.o $(addprefix $(OBJ_DIR)/,$(SOURCES:.cpp=.o))
	@echo "Linking ($*)"
	$(Q)g++ $(LDFLAGS) $(CXXFLAGS) -shared -o $@ $^

.PHONY: dir.work
dir.work: $(WORK_DIR)/_info

$(WORK_DIR)/_info:
	@echo Creating work directory at $(WORK_DIR)
	$(Q)vlib $(WORK_DIR)

.PHONY: dir.obj
dir.obj: $(OBJ_DIR)

$(OBJ_DIR):
	$(Q)mkdir -p $@

.PHONY: clean.common
clean.common:
	@echo Cleaning up
	$(Q)rm -rf $(WORK_DIR) $(OBJ_DIR)
	$(Q)rm -f $(addsuffix .h,$(MODULES_DPI_C))
	$(Q)rm -f transcript

