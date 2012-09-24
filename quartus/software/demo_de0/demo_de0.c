
#include "io.h"
#include "system.h"
#include "sys/alt_irq.h"
#include "sys/alt_alarm.h"
#include "altera_avalon_fifo_util.h"
#include "altera_avalon_fifo_regs.h"
#include "m2vdd_hx8347a.h"
#include "m2vdec_regs.h"
#include "m2vdd_hx8347a_regs.h"
#include "ff9/ff.h"
#include "altera_avalon_pio_regs.h"

/*
 * Switches
 *
 * [SW9] [SW8] [SW7] [SW6] [SW5] [SW4] [SW3] [SW2] [SW1] [SW0]  [BT2] [BT1] [BT0]
 * Auto  Slow  <---------------- frame number --------------->  Reset       Next
 *
 */

//#define M2V_FLASH_BASE	0x0f100000
//#define SIM

#ifdef M2V_FLASH_BASE
const alt_u32 test_1mb_m2v = M2V_FLASH_BASE;
/*const __attribute__((section(".testdata")))
#include "pd1m_1mb.h"*/
#endif

volatile int fr_flags;
alt_alarm al_frate;
extern void disk_inittimer();	// in mmc.c
static void m2vdec_irq_handler(void* context, alt_u32 id) __attribute__((section(".exceptions")));
static alt_u32 frame_rate_handler(void* context) __attribute__((section(".exceptions")));

//M2VDD_HX8347A_INSTANCE ( M2VDD_HX8347A_0, m2vdd_hx8347a_0);

static void delay(int ms)
{
#ifndef SIM
	int end = alt_nticks() + ms + 1;
	while(alt_nticks() < end);
#endif
}

int main()
{ 
	FATFS fs;
	FIL f;
	FRESULT res;
	alt_u32 buf[512/4];

	IOWR_32DIRECT(HEXDISP_0_BASE, 0, 0x00E0);
//	M2VDD_HX8347A_INIT ( M2VDD_HX8347A_0, m2vdd_hx8347a_0);
	IOWR_32DIRECT(HEXDISP_0_BASE, 0, 0x10E0);

#ifndef M2V_FLASH_BASE
	disk_inittimer();

	if((res = f_mount(0, &fs)) != FR_OK) while(1);
	IOWR_32DIRECT(HEXDISP_0_BASE, 0, 0x00E1);

	if((res = f_open(&f, "test.m2v", FA_READ)) != FR_OK) while(1);
	IOWR_32DIRECT(HEXDISP_0_BASE, 0, 0x00E2);
#endif

	IOWR_M2VDEC_STATUS(M2VDEC_0_BASE, M2VDEC_STATUS_SRST_MSK);

	{
		// Clear display with black (0x0000)
		int pixels;
		IOWR_M2VDD_HX8347A_CONTROL(M2VDD_HX8347A_0_BASE, 0x22 |
			M2VDD_HX8347A_CONTROL_WRITE_MSK |
			M2VDD_HX8347A_CONTROL_RESET_MSK);
#ifdef SIM
		for(pixels = 0; pixels < 50; pixels++)
#else
		for(pixels = 0; pixels < 320*240; pixels++)
#endif
		{
    		IOWR_M2VDD_HX8347A_CONTROL(M2VDD_HX8347A_0_BASE,
    			M2VDD_HX8347A_CONTROL_WRITE_MSK |
    			M2VDD_HX8347A_CONTROL_RESET_MSK |
    			M2VDD_HX8347A_CONTROL_RS_MSK);
    		while(IORD_M2VDD_HX8347A_CONTROL(M2VDD_HX8347A_0_BASE) & 2);
		}
	}

	IOWR_M2VDEC_STATUS(M2VDEC_0_BASE, 0);
	IOWR_32DIRECT(HEXDISP_0_BASE, 0, 0x00E3);

	fr_flags = 0;
	alt_irq_register(M2VDEC_0_IRQ, (void*)&fr_flags, m2vdec_irq_handler);
	if(alt_alarm_start(&al_frate, frame_rate_handler((void*)&fr_flags), frame_rate_handler, (void*)&fr_flags) < 0)
	{
		while(1);
	}

	if(altera_avalon_fifo_init(FIFO_0_IN_CSR_BASE, 0, 4, FIFO_0_IN_FIFO_DEPTH - 4) != ALTERA_AVALON_FIFO_OK)
	{
		while(1);
	}

	IOWR_32DIRECT(HEXDISP_0_BASE, 0, 0x0000);

	alt_u16 frames = 0;
	alt_u8 stop = 0;
#ifdef M2V_FLASH_BASE
	alt_u32* p = (alt_u32*)test_1mb_m2v;
#else
	alt_u32* p = buf;
	UINT left = 0;
#endif
	while(1)
	{
#ifndef M2V_FLASH_BASE
		if(left == 0)
		{
			if((res = f_read(&f, buf, 512, &left)) != 0)
			{
				IOWR_32DIRECT(HEXDISP_0_BASE, 0, 0xE100);
				while(1);
			}
			p = buf;
		}//-*/
#endif
		while(IORD_ALTERA_AVALON_FIFO_STATUS(FIFO_0_IN_CSR_BASE) & ALTERA_AVALON_FIFO_STATUS_F_MSK)
		{
			if(fr_flags == 3)
			{
				// Refresh display
				IOWR_M2VDD_HX8347A_CONTROL(M2VDD_HX8347A_0_BASE, M2VDD_HX8347A_CONTROL_START_MSK);
				while(IORD_M2VDD_HX8347A_CONTROL(M2VDD_HX8347A_0_BASE) & 1);

#ifndef SIM
				if((alt_u16)stop == (IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE) & 0xff))
				{
					while( (IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE) & (1 << 11)));
					delay(30);
					while(!(IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE) & (1 << 11)));
					delay(30);
					stop = 0;
				}
				else
				{
					++stop;
				}
#endif

				fr_flags = 0;
				IOWR_32DIRECT(HEXDISP_0_BASE, 0, ++frames);

				// Resume decoding
				IOWR_M2VDEC_STATUS(M2VDEC_0_BASE, M2VDEC_STATUS_PAUSE_MSK);
			}
		}
		IOWR_ALTERA_AVALON_FIFO_DATA(FIFO_0_IN_BASE, *p++);
#ifndef M2V_FLASH_BASE
		left -= 4;
#endif
	}

	/* Event loop never exits. */
	while (1);

	return 0;
}

static void m2vdec_irq_handler(void* context, alt_u32 id)
{
	if(IORD_M2VDEC_STATUS(M2VDEC_0_BASE) & M2VDEC_STATUS_IRQ_PIC_MSK)
	{
		*((volatile int*)context) |= 1;
		//*((volatile int*)context) |= 3;
	}
	else
	{
		alt_u32 vinfo = IORD_M2VDEC_VIDEO(M2VDEC_0_BASE);
		alt_u32 wd = ((vinfo & M2VDEC_VIDEO_WIDTH_MSK) >> M2VDEC_VIDEO_WIDTH_OFST) - 1;
		alt_u32 ht = ((vinfo & M2VDEC_VIDEO_HEIGHT_MSK) >> M2VDEC_VIDEO_HEIGHT_OFST) - 1;
		IOWR_M2VDD_HX8347A_CONTROL(M2VDD_HX8347A_0_BASE, M2VDD_HX8347A_CONTROL_VIDEOWD_MSK | wd);
		IOWR_M2VDD_HX8347A_CONTROL(M2VDD_HX8347A_0_BASE, M2VDD_HX8347A_CONTROL_VIDEOHT_MSK | ht);
	}
	IOWR_M2VDEC_STATUS(M2VDEC_0_BASE, M2VDEC_STATUS_IRQ_SEQ_MSK | M2VDEC_STATUS_IRQ_PIC_MSK);
}

static alt_u32 frame_rate_handler(void* context)
{
	*((volatile int*)context) |= 2;
	//return 33;
#ifdef SIM
	return 0;
#else
	return (IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE) & (1 << 8)) ? 1000 : 33;
#endif
}


