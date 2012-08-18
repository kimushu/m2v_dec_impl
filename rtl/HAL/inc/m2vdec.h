//================================================================================
// HAL driver header for m2vdec
// written by @kimu_shu
//================================================================================

#ifndef __M2VDEC_H__
#define __M2VDEC_H__

#ifdef __cplusplus
extern "C" {
#endif	/* __cplusplus */

typedef struct m2vdec_state_s
{
	void*	base;
}
m2vdec_state;

#define M2VDEC_INSTANCE(name, state)	\
	m2vdec_state state = {				\
		(void*)name##_BASE				\
	}

extern void m2vdec_init(m2vdec_state* sp);

#define M2VDEC_INIT(name, state)		\
	m2vdec_init(&state)

#ifdef __cplusplus
}
#endif	/* __cplusplus */

#endif	/* !__M2VDEC_H__ */

