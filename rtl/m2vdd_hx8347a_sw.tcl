#================================================================================
# Driver definition for m2vdd_hx8347a
# written by @kimu_shu
#================================================================================

create_driver m2vdd_hx8347a_driver
set_sw_property hw_class_name m2vdd_hx8347a
set_sw_property version 1.0
set_sw_property min_compatible_hw_version 1.0

#set_sw_property isr_preemption_supported true
#set_sw_property supported_interrupt_apis "legacy_interrupt_api enhanced_interrupt_api"

set_sw_property auto_initialize true
set_sw_property bsp_subdirectory drivers

add_sw_property c_source HAL/src/m2vdd_hx8347a.c
add_sw_property include_source HAL/inc/m2vdd_hx8347a.h
add_sw_property include_source inc/m2vdd_hx8347a_regs.h

add_sw_property supported_bsp_type HAL

