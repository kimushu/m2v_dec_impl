
#include "io.h"
#include "system.h"
#include "sys/alt_irq.h"
#include "sys/alt_alarm.h"
#include "altera_avalon_fifo_util.h"
#include "altera_avalon_fifo_regs.h"
#include "m2vdd_hx8347a.h"
#include "m2vdec_regs.h"
#include "m2vdd_hx8347a_regs.h"
#include "pff/pff.h"
#include "altera_avalon_pio_regs.h"

/*
 * Switches
 *
 * [SW9] [SW8] [SW7] [SW6] [SW5] [SW4] [SW3] [SW2] [SW1] [SW0]  [BT2] [BT1] [BT0]
 * Auto  Slow  <---------------- frame number --------------->  Reset       Next
 *
 */

const alt_u32 test_1mb_m2v = 0x500000;

volatile int fr_flags;
alt_alarm al_frate;
extern void disk_inittimer();	// in mmc.c
static void m2vdec_irq_handler(void* context, alt_u32 id) __attribute__((section(".exceptions")));
static alt_u32 frame_rate_handler(void* context) __attribute__((section(".exceptions")));

static void delay(int ms)
{
	int end = alt_nticks() + ms + 1;
	while(alt_nticks() < end);
}

int main()
{ 
	FATFS fs;
	FRESULT res;
	alt_u32 buf[512/4];

	IOWR_32DIRECT(HEXDISP_0_BASE, 0, 0x00E0);
	disk_inittimer();

	if((res = pf_mount(&fs)) != FR_OK) while(1);
	IOWR_32DIRECT(HEXDISP_0_BASE, 0, 0x00E1);

	if((res = pf_open("test.m2v")) != FR_OK) while(1);
	IOWR_32DIRECT(HEXDISP_0_BASE, 0, 0x00E2);

	IOWR_M2VDEC_STATUS(M2VDEC_0_BASE, M2VDEC_STATUS_SRST_MSK);

	{
		// Clear display with black (0x0000)
		int pixels;
		IOWR_M2VDD_HX8347A_CONTROL(M2VDD_HX8347A_0_BASE, 0x22 |
			M2VDD_HX8347A_CONTROL_WRITE_MSK |
			M2VDD_HX8347A_CONTROL_RESET_MSK);
		for(pixels = 0; pixels < 320*240; pixels++)
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
	alt_u32* p = buf;
//	alt_u32* p = (alt_u32*)0x500000;
	WORD left = 0;
	while(1)
	{
		if(left == 0)
		{
			if((res = pf_read(buf, 512, &left)) != 0)
			{
				IOWR_32DIRECT(HEXDISP_0_BASE, 0, 0xE100);
				while(1);
			}
			p = buf;
		}//-*/
		while(IORD_ALTERA_AVALON_FIFO_STATUS(FIFO_0_IN_CSR_BASE) & ALTERA_AVALON_FIFO_STATUS_F_MSK)
		{
			if(fr_flags == 3)
			{
				// Refresh display
				IOWR_M2VDD_HX8347A_CONTROL(M2VDD_HX8347A_0_BASE, M2VDD_HX8347A_CONTROL_START_MSK);
				while(IORD_M2VDD_HX8347A_CONTROL(M2VDD_HX8347A_0_BASE) & 1);

				if((alt_u16)stop == (IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE) & 0x2ff))
				{
					while( (IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE) & (1 << 10)));
					delay(30);
					while(!(IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE) & (1 << 10)));
					delay(30);
					stop = 0;
				}
				else
				{
					++stop;
				}

				fr_flags = 0;
				IOWR_32DIRECT(HEXDISP_0_BASE, 0, ++frames);

				// Resume decoding
				IOWR_M2VDEC_STATUS(M2VDEC_0_BASE, M2VDEC_STATUS_PAUSE_MSK);
			}
		}
		IOWR_ALTERA_AVALON_FIFO_DATA(FIFO_0_IN_BASE, *p++);
		left -= 4;
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
	return (IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE) & (1 << 8)) ? 1000 : 33;
}


