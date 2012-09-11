#================================================================================
# Altera environments
#================================================================================

QUARTUS_BIN := $(patsubst %/,%,$(dir $(shell which quartus 2> /dev/null)))
ALTERA_ROOT  = $(QUARTUS_BIN)/../..
SOPC_ROOT    = $(ALTERA_ROOT)/ip/altera/sopc_builder_ip
VS_LIBS     += altera_mf_ver lpm_ver

vpath %.sv $(SOPC_ROOT)/verification/lib
vpath %.sv $(SOPC_ROOT)/verification/altera_avalon_mm_master_bfm
vpath %.sv $(SOPC_ROOT)/verification/altera_avalon_mm_slave_bfm

MODULES_V += verbosity_pkg avalon_mm_pkg
MODULES_V += altera_avalon_mm_master_bfm
MODULES_V += altera_avalon_mm_slave_bfm

.PHONY: env.altera
ifeq ($(QUARTUS_BIN),)
env.altera:
	@echo "****"
	@echo "**** Cannot find quartus!"
	@echo "**** Add directory which Quartus installed to \$$PATH"
	@echo "****"
	@test
else
env.altera:
endif

