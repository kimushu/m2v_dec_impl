#================================================================================
# Modules for m2vdec
#================================================================================

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

