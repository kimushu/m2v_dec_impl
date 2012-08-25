#================================================================================
# Altera environments
#================================================================================

QUARTUS_BIN := $(dir $(shell which quartus 2> /dev/null))
ALTERA_ROOT  = $(QUARTUS_BIN)../..
SOPC_ROOT    = $(ALTERA_ROOT)/ip/altera/sopc_builder_ip
VS_LIBS     += altera_mf_ver lpm_ver

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

