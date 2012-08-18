//================================================================================
// HAL driver header for m2vdd_hx8347a
// written by @kimu_shu
//================================================================================

#ifndef __M2VDD_HX8347A_H__
#define __M2VDD_HX8347A_H__

#ifdef __cplusplus
extern "C" {
#endif	/* __cplusplus */

typedef struct m2vdd_hx8347a_state_s
{
	void*	base;
}
m2vdd_hx8347a_state;

#define M2VDD_HX8347A_INSTANCE(name, state)	\
	m2vdd_hx8347a_state state = {			\
		(void*)name##_BASE					\
	}

extern void m2vdd_hx8347a_init(m2vdd_hx8347a_state* sp);

#define M2VDD_HX8347A_INIT(name, state)		\
	m2vdd_hx8347a_init(&state)

extern void m2vdd_hx8347a_write_reg(unsigned long base, unsigned char index, unsigned short value);

#ifdef __cplusplus
}
#endif	/* __cplusplus */

#endif	/* !__M2VDD_HX8347A_H__ */

