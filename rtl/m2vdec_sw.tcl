#================================================================================
# Driver definition for m2vdec
# written by @kimu_shu
#================================================================================

create_driver m2vdec_driver
set_sw_property hw_class_name m2vdec
set_sw_property version 1.0
set_sw_property min_compatible_hw_version 1.0

#set_sw_property isr_preemption_supported true
#set_sw_property supported_interrupt_apis "legacy_interrupt_api enhanced_interrupt_api"

set_sw_property auto_initialize true
set_sw_property bsp_subdirectory drivers

add_sw_property c_source HAL/src/m2vdec.c
add_sw_property include_source HAL/inc/m2vdec.h
add_sw_property include_source inc/m2vdec_regs.h

add_sw_property supported_bsp_type HAL

