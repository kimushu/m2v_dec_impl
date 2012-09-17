//================================================================================
// Verifier for test_m2vdd_hx8347a
//================================================================================

#include <dpic_helper.hpp>
#include <tb_common.hpp>
#include "test_m2vdd_hx8347a.h"
#include <string>
#include <fstream>
#include <stdlib.h>
#include <iomanip>
#include "params_m2vdd.h"
using namespace std;

#define R_SCU		0x02	// Column address Start (Upper byte)
#define R_SCL		0x03	// Column address Start (Lower byte)
#define R_ECU		0x04	// Column address End (Upper byte)
#define R_ECL		0x05	// Column address End (Lower byte)
#define R_SPU		0x06	// Row address Start (Upper byte)
#define R_SPL		0x07	// Row address Start (Lower byte)
#define R_EPU		0x08	// Row address End (Upper byte)
#define R_EPL		0x09	// Row address End (Lower byte)
#define R_WD		0x22	// Write Data (the same address as RD)

extern int video_wd, video_ht;
extern uint8_t fptr_data[1 << MBY_WIDTH][1 << MBY_WIDTH];

static ifstream rgb;
static uint16_t pixel_data[1 << (MBY_WIDTH + 4)][1 << (MBX_WIDTH + 4)];

DPI_LINK_DECL int init_verify(const char* ref_dir)
{
	if(!open_refdata(rgb, ref_dir, "rgb.txt"))
		return 1;

	return 0;
}

DPI_LINK_DECL int verify_picture()
{
	while(rgb.peek() == '#')
	{
		string line;
		getline(rgb, line);
		cout << "# Info: [verify] " << line << endl;
	}

	stringstream ss;
	int vwd, vht;

	setnewline(rgb, ss) >> vwd >> vht;
	if(vwd != video_wd || vht != video_ht)
	{
		cout << "# Error: [verify] Reference data size mismatch" << endl;
		return 1;
	}

	if(vwd > (1 << (MBX_WIDTH + 4)) ||
		vht > (1 << (MBY_WIDTH + 4)))
	{
		cout << "# Error: [verify] Reference video size is too large" << endl;
		return 1;
	}

	for(int y = 0; y < vht; ++y)
	{
		setnewline(rgb, ss);
		for(int x = 0; x < vwd; ++x) ss >> hex >> pixel_data[y][x];
	}

	int max_mbx, max_mby;
	int mbx, mby;
	uint8_t lcdindex;
	uint16_t lcdregs[R_EPL+1];	// only [R_SCU] to [R_EPL] are used
	svInt max_cycles;
	svUnsigned<1> lcd_rs;
	svUnsigned<16> lcd_data;

	mbx = max_mbx = (vwd - 1) >> 4;
	mby = max_mby = (vht - 1) >> 4;
	lcdindex = 0;
	memset(lcdregs, 0, sizeof(lcdregs));
	max_cycles = 300;

	for(mby = max_mby; mby >= 0; --mby)
	{
		for(mbx = max_mbx; mbx >= 0; --mbx)
		{
			if(!(fptr_data[mby][mbx] & 2)) continue;

			// register write
			while(1)
			{
				get_lcd_write(max_cycles.logic(), lcd_rs.plogic(), lcd_data.plogic());
				if(lcd_rs.has_zx())
				{
					cout << "# Error: [verify] No LCD write detected!" << endl;
					return 1;
				}
				if(lcd_data.has_zx())
				{
					cout << "# Error: [verify] lcd_data has z/x" << endl;
					return 1;
				}
				max_cycles = 10;

				if(lcd_rs.val())
					lcdregs[lcdindex] = lcd_data.val() & 0xff;
				else
				{
					lcdindex = lcd_data.val() & 0xff;
					if(lcdindex == R_WD) break;
					if(lcdindex < R_SCU || lcdindex > R_EPL)
					{
						cout << "# Error: [verify] invalid LCD register index" << endl;
						return 1;
					}
				}
			}

			// range check
			uint16_t sc, ec, sp, ep;
			sc = (lcdregs[R_SCU] << 8) | lcdregs[R_SCL];
			ec = (lcdregs[R_ECU] << 8) | lcdregs[R_ECL];
			sp = (lcdregs[R_SPU] << 8) | lcdregs[R_SPL];
			ep = (lcdregs[R_EPU] << 8) | lcdregs[R_EPL];
			if(sc != (mbx << 4) || (ec - sc) != 15 ||
				sp != (mby << 4) || (ep - sp) != 15)
			{
				cout << "# Error: [verify] GRAM range mismatch" << endl;
				return 1;
			}

			// pixel data check
			uint16_t c, p;
			for(p = sp; p <= ep; ++p) for(c = sc; c <= ec; ++c)
			{
				get_lcd_write(max_cycles.logic(), lcd_rs.plogic(), lcd_data.plogic());
				if(lcd_rs.has_zx())
				{
					cout << "# Error: [verify] No LCD write detected!" << endl;
					return 1;
				}
				if(lcd_data.has_zx())
				{
					cout << "# Error: [verify] lcd_data has z/x" << endl;
					return 1;
				}
				if(!lcd_rs.val())
				{
					cout << "# Error: [verify] invalid register write" << endl;
					return 1;
				}
				if(c >= vwd || p >= vht) continue;
				if(lcd_data.val() != pixel_data[p][c])
				{
					cout << "# Error: [verify] Pixel data mismatch (Read: " <<
							setw(4) << setfill('0') << hex << lcd_data.val() <<
							", Expected: " << pixel_data[p][c] << ")" << endl;
					return 1;
				}
			}
		}
	}

	return 0;
}

