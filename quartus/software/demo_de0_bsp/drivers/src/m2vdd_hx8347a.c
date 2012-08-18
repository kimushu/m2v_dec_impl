//================================================================================
// HAL driver source for m2vdec
// written by @kimu_shu
//================================================================================

#include "m2vdd_hx8347a.h"
#include "m2vdd_hx8347a_regs.h"
#include "sys/alt_alarm.h"

static void delay(int ms)
{
	int end = alt_nticks() + ms + 1;
	while(alt_nticks() < end);
}

//--------------------------------------------------------------------------------
// Initialize LCD
//
void m2vdd_hx8347a_init(m2vdd_hx8347a_state* sp)
{
	void* base = sp->base;

	// Soft reset
	IOWR_M2VDD_HX8347A_CONTROL(base, M2VDD_HX8347A_CONTROL_SRESET_MSK);
	delay(1);
	IOWR_M2VDD_HX8347A_CONTROL(base, 0);
	delay(1);

	// Assert LCD's reset
	IOWR_M2VDD_HX8347A_CONTROL(base, M2VDD_HX8347A_CONTROL_WRITE_MSK);

	static const unsigned char codes[] = {
	0xff,  10, // delay(10)
	0x46,0xA4,
	0x47,0x53,
	0x48,0x00,
	0x49,0x44,
	0x4a,0x04,
	0x4b,0x67,
	0x4c,0x33,
	0x4d,0x77,
	0x4e,0x12,
	0x4f,0x4C,
	0x50,0x46,
	0x51,0x44,
	//240x320 window setting
	0x02,0x00, // Column address start2
	0x03,0x00, // Column address start1
	0x04,0x00, // Column address end2
	0x05,0xef, // Column address end1
	0x06,0x00, // Row address start2
	0x07,0x00, // Row address start1
	0x08,0x01, // Row address end2
	0x09,0x3f, // Row address end1
	// Display Setting
	0x01,0x06, // IDMON=0, INVON=1, NORON=1, PTLON=0
	0x16,0xC8, // MY=0, MX=0, MV=0, ML=1, BGR=0, TEON=0   0048
	0x23,0x95, // N_DC=1001 0101
	0x24,0x95, // PI_DC=1001 0101
	0x25,0xFF, // I_DC=1111 1111

	0x27,0x02, // N_BP=0000 0010
	0x28,0x02, // N_FP=0000 0010
	0x29,0x02, // PI_BP=0000 0010
	0x2a,0x02, // PI_FP=0000 0010
	0x2C,0x02, // I_BP=0000 0010
	0x2d,0x02, // I_FP=0000 0010

	0x3a,0x01, // N_RTN=0000, N_NW=001    0001
	0x3b,0x00, // P_RTN=0000, P_NW=001
	0x3c,0xf0, // I_RTN=1111, I_NW=000
	0x3d,0x00, // DIV=00
	0xff,   1, // delay(1)
	0x35,0x38, // EQS=38h
	0x36,0x78, // EQP=78h
	0x3E,0x38, // SON=38h
	0x40,0x0F, // GDON=0Fh
	0x41,0xF0, // GDOFF

	// Power Supply Setting
	0x19,0x49, // CADJ=0100, CUADJ=100, OSD_EN=1 ,60Hz
	0x93,0x0F, // RADJ=1111, 100%
	0xff,   1, // delay(1)
	0x20,0x40, // BT=0100
	0x1D,0x07, // VC1=111   0007
	0x1E,0x00, // VC3=000
	0x1F,0x04, // VRH=0011

	// VCOM SETTING
	0x44,0x4D, // VCM=101 0000  4D
	0x45,0x0E, // VDV=1 0001   0011
	0xff,   1, // delay(1)
	0x1C,0x04, // AP=100
	0xff,   2, // delay(2)

	0x1B,0x18, // GASENB=0, PON=0, DK=1, XDK=0, VLCD_TRI=0, STB=0
	0xff,   1, // delay(1)
	0x1B,0x10, // GASENB=0, PON=1, DK=0, XDK=0, VLCD_TRI=0, STB=0
	0xff,   1, // delay(1)
	0x43,0x80, // set VCOMG=1
	0xff,   2, // delay(2)

	// Display ON Setting
	0x90,0x7F, // SAP=0111 1111
	0x26,0x04, // GON=0, DTE=0, D=01
	0xff,   1, // delay(1)
	0x26,0x24, // GON=1, DTE=0, D=01
	0x26,0x2C, // GON=1, DTE=0, D=11
	0xff,   1, // delay(1)
	0x26,0x3C, // GON=1, DTE=1, D=11

	// INTERNAL REGISTER SETTING
	0x57,0x02, // TEST_Mode=1: into TEST mode
	0x95,0x01, // SET DISPLAY CLOCK AND PUMPING CLOCK TO SYNCHRONIZE
	0x57,0x00, // TEST_Mode=0: exit TEST mode

	// Reconfigure
	0x02,0x00, // Column address start2
	0x03,0x00, // Column address start1
	0x04,0x01, // Column address end2
	0x05,0x3f, // Column address end1
	0x06,0x00, // Row address start2
	0x07,0x00, // Row address start1
	0x08,0x00, // Row address end2
	0x09,0xef, // Row address end1
	0x01,0x06, //
	0x16,0x60, //

	0xff,   0, // END
	};

	const unsigned char* p = codes;
	for(;; p += 2)
	{
		if(p[0] == 0xff)
		{
			if(p[1] == 0) break;
			delay(p[1]);
		}
		else
		{
			IOWR_M2VDD_HX8347A_CONTROL(base, p[0] |
				M2VDD_HX8347A_CONTROL_WRITE_MSK |
				M2VDD_HX8347A_CONTROL_RESET_MSK);
			IOWR_M2VDD_HX8347A_CONTROL(base, p[1] |
				M2VDD_HX8347A_CONTROL_WRITE_MSK |
				M2VDD_HX8347A_CONTROL_RESET_MSK |
				M2VDD_HX8347A_CONTROL_RS_MSK);
		}
	}
}

void m2vdd_hx8347a_write_reg(alt_u32 base, alt_u8 index, alt_u16 value)
{
	while(IORD_M2VDD_HX8347A_CONTROL(base) & 2);
	IOWR_M2VDD_HX8347A_CONTROL(base, index |
		M2VDD_HX8347A_CONTROL_WRITE_MSK |
		M2VDD_HX8347A_CONTROL_RESET_MSK);
	IOWR_M2VDD_HX8347A_CONTROL(base, value |
		M2VDD_HX8347A_CONTROL_WRITE_MSK |
		M2VDD_HX8347A_CONTROL_RESET_MSK |
		M2VDD_HX8347A_CONTROL_RS_MSK);
}

