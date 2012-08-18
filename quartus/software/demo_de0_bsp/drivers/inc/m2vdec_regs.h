//================================================================================
// Register definitions for m2vdec
// written by @kimu_shu
//================================================================================

#ifndef __M2VDEC_REGS_H__
#define __M2VDEC_REGS_H__

#include <io.h>

#define M2VDEC_STATUS_REG				0
#define IOADDR_M2VDEC_STATUS(base)		\
	__IO_CALC_ADDRESS_NATIVE(base, M2VDEC_STATUS_REG)
#define IORD_M2VDEC_STATUS(base)		\
	IORD(base, M2VDEC_STATUS_REG)
#define IOWR_M2VDEC_STATUS(base, data)	\
	IOWR(base, M2VDEC_STATUS_REG, data)

#define M2VDEC_STATUS_IRQ_SEQ_MSK		(0x08)
#define M2VDEC_STATUS_IRQ_SEQ_OFST		(3)
#define M2VDEC_STATUS_IRQ_PIC_MSK		(0x10)
#define M2VDEC_STATUS_IRQ_PIC_OFST		(4)
#define M2VDEC_STATUS_PAUSE_MSK			(0x20)
#define M2VDEC_STATUS_PAUSE_OFST		(5)
#define M2VDEC_STATUS_ERROR_MSK			(0x40)
#define M2VDEC_STATUS_ERROR_OFST		(6)
#define M2VDEC_STATUS_SRST_MSK			(0x80)
#define M2VDEC_STATUS_SRST_OFST			(7)

#define M2VDEC_VIDEO_REG				1
#define IOADDR_M2VDEC_VIDEO(base)		\
	__IO_CALC_ADDRESS_NATIVE(base, M2VDEC_VIDEO_REG)
#define IORD_M2VDEC_VIDEO(base)		\
	IORD(base, M2VDEC_VIDEO_REG)
#define IOWR_M2VDEC_VIDEO(base, data)	\
	IOWR(base, M2VDEC_VIDEO_REG, data)

#define M2VDEC_VIDEO_WIDTH_MSK			(0x00003fff)
#define M2VDEC_VIDEO_WIDTH_OFST			(0)
#define M2VDEC_VIDEO_HEIGHT_MSK			(0x0fffc000)
#define M2VDEC_VIDEO_HEIGHT_OFST		(14)
#define M2VDEC_VIDEO_FRATE_MSK			(0xf0000000)
#define M2VDEC_VIDEO_FRATE_OFST			(28)

#endif	/* !__M2VDEC_REGS_H__ */

