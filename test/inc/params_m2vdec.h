
#ifndef __PARAMS_M2VDEC_H__
#define __PARAMS_M2VDEC_H__

#define MEM_WIDTH	21
#define MVH_WIDTH	16
#define MVV_WIDTH	15
#define MBX_WIDTH	6
#define MBY_WIDTH	5

#define IS_LUMA(a)		(!(((a)>>(MBY_WIDTH+MBX_WIDTH+8))&1))
#define IS_Y(a)			IS_LUMA(a)
#define IS_CHROMA(a)	(!IS_LUMA(a))
#define IS_Cb(a)		(IS_CHROMA(a)&&(~(((a)>>1)&1)))
#define IS_Cr(a)		(IS_CHROMA(a)&&(((a)>>1)&1))

#define GET_FRAME(a)	(((a)>>(MBY_WIDTH+MBX_WIDTH+9))&1)
#define GET_MBX(a)		(((a)>>8)&((1<<MBX_WIDTH)-1))
#define GET_MBY(a)		(((a)>>(8+MBX_WIDTH))&((1<<MBY_WIDTH)-1))
#define GET_LUMA_X(a)	((GET_MBX(a)<<4)|((a)&14))
#define GET_LUMA_Y(a)	((GET_MBY(a)<<4)|(((a)>>4)&15))
#define GET_CHROMA_X(a)	((GET_MBX(a)<<4)|(((a)&12)>>0))
#define GET_CHROMA_Y(a)	((GET_MBY(a)<<4)|(((a)>>4)&14))

#endif	/* !__PARAMS_M2VDEC_H__ */

