#================================================================================
# Makefile for rtl
#
# 1) Generate top module (m2vdec.v) from sub modules
# 2) Generate MIF files
#================================================================================

Q ?= @
MIFS = m2vctrl_code m2vidct_fram m2vidct_rom m2visdq_cmem m2vmc_fetch m2vvld_table

GENTOP = ruby ../tools/gentop.rb
TOP = m2vdec
DESCRIPTION = "MPEG2 Decoder"
HEADERS =
SUBMODULES = \
	m2vctrl m2visdq m2vidct m2vmc m2vside1 m2vside2 m2vside3 m2vside4
PREFIXES = clk=csi reset=rsi control=avs irq=ins stream=asi fbuf=avm fptr=coe

.PHONY: all
all: mif top

.PHONY: mif
mif: $(addsuffix .mif,$(MIFS))

%.mif %.log: %.rb
	@echo Generating $@ ...
	$(Q)ruby $< 1> $@ 2> $*.log || (rm -f $@; test)

.PHONY: top
top: $(TOP).v

$(TOP).v: $(addsuffix .v,$(SUBMODULES))
	@echo Generating top module ...
	$(Q)$(GENTOP) -n $(TOP) -d $(DESCRIPTION) \
		$(addprefix -p,$(PREFIXES)) \
		$(addprefix -i,$(HEADERS)) $^ > $@ || (rm -f $@; test)

.PHONY: clean
clean:
	$(Q)rm -f $(foreach f,$(MIFS),$(f).{mif,log})
	$(Q)rm -f $(TOP).v

