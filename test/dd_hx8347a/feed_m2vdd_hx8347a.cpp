//================================================================================
// Feeder for test_m2vdd_hx8347a
//================================================================================

#include <dpic_helper.hpp>
#include <tb_common.hpp>
#include "test_m2vdd_hx8347a.h"
#include <string>
#include <fstream>
#include <stdlib.h>
#include "params_m2vdd.h"
using namespace std;

#define M2VDD_HX8347A_CONTROL_START_MSK		(0x80000000)
#define M2VDD_HX8347A_CONTROL_START_OFST	(31)
#define M2VDD_HX8347A_CONTROL_WRITE_MSK		(0x40000000)
#define M2VDD_HX8347A_CONTROL_WRITE_OFST	(30)
#define M2VDD_HX8347A_CONTROL_RESET_MSK		(0x020000)
#define M2VDD_HX8347A_CONTROL_RESET_OFST	(17)
#define M2VDD_HX8347A_CONTROL_RS_MSK		(0x010000)
#define M2VDD_HX8347A_CONTROL_RS_OFST		(16)
#define M2VDD_HX8347A_CONTROL_VIDEOWD_MSK	(0x20000000)
#define M2VDD_HX8347A_CONTROL_VIDEOWD_OFST	(29)
#define M2VDD_HX8347A_CONTROL_VIDEOHT_MSK	(0x10000000)
#define M2VDD_HX8347A_CONTROL_VIDEOHT_OFST	(28)
#define M2VDD_HX8347A_CONTROL_SRESET_MSK	(0x08000000)
#define M2VDD_HX8347A_CONTROL_SRESET_OFST	(27)

extern bool verifying;

static ifstream fptr, mc_mix;
int video_wd, video_ht;
static uint8_t fbuf_data[1 << MEM_WIDTH];
uint8_t fptr_data[1 << MBY_WIDTH][1 << MBY_WIDTH];

#define ADDR_INVALID		0xffffffffu

#define FBAGEN(b, f, mbx, x2, mby, y)>  ( \
	( ((f) & 1) << (MBX_WIDTH + MBY_WIDTH + 9) ) | \
	( ((b) & 4) << (MBX_WIDTH + MBY_WIDTH + 6) ) | \
	( ((mby) & MBY_MASK) << (MBX_WIDTH + 8) ) | \
	( ((mbx) & MBX_MASK) << 8 ) | \
	( ((y) & 14) << 4 ) | \
	( (((b) & 4) ? 0 : ((y) & 1)) << 4 ) | \
	( ((x2) & 6) << 1 ) | \
	( (((b) & 4) ? ((b) & 1) : ((x2) & 1)) << 1 ) \
	)

DPI_LINK_DECL int init_feed(const char* ref_dir)
{
	if(!open_refdata(fptr, ref_dir, "fptr.out") ||
		!open_refdata(mc_mix, ref_dir, "mc_mix.out"))
		return 1;

	wait_reset_done();
	for(int wait = 0; wait < 100; ++wait)
	{
		posedge_clk();
	}

	svUnsigned<32> writedata;
	svInt cycles;

	writedata = 0;
	ctrl_write(writedata.logic(), cycles.plogic());
	if(cycles.val() > 10)
	{
		cout << "# Error: write latency is too long" << endl;
		return 1;
	}

	return 0;
}

static int feed_picture(svUnsigned<1>& finished)
{
	int wait;
	string line;
	stringstream ss;
	int mbxw;
	int mbyw;
	svUnsigned<32> writedata;
	svInt cycles;
	int total_cycles;

	while(fptr.peek() == '#') skipline(fptr);
	setnewline(fptr, ss) >> video_wd >> video_ht >> mbxw >> mbyw;
	if(mbxw != MBX_WIDTH || mbyw != MBY_WIDTH)
	{
		cout << "# Error: MBX_WIDTH/MBY_WIDTH mismatch!" << endl;
		return 1;
	}

	// set size
	writedata = M2VDD_HX8347A_CONTROL_VIDEOWD_MSK | (video_wd - 1);
	ctrl_write(writedata.logic(), cycles.plogic());
	if(cycles.val() > 10)
	{
		cout << "# Error: write latency is too long" << endl;
		return 1;
	}
	writedata = M2VDD_HX8347A_CONTROL_VIDEOHT_MSK | (video_ht - 1);
	ctrl_write(writedata.logic(), cycles.plogic());
	if(cycles.val() > 10)
	{
		cout << "# Error: write latency is too long" << endl;
		return 1;
	}

	// read fbuf data
	line = "";
	do
	{
		if(mc_mix.eof())
		{
			finished = 1;
			return 0;
		}

		if(mc_mix.peek() != '#')
		{
			uint32_t addr;
			uint16_t value;
			setnewline(mc_mix, ss) >> hex >> addr >> value;
			addr &= ((1 << MEM_WIDTH) - 1 - 1);
			fbuf_data[addr + 0] = value;
			fbuf_data[addr + 1] = value >> 8;
		}
		else
		{
			getline(mc_mix, line);
		}
	}
	while(line != "# EOP");

	// read fptr data
	svUnsigned<MBX_WIDTH+MBY_WIDTH> fptr_addr;
	fptr_addr = 0;
	for(int y = 0; y < (1 << mbyw); ++y)
	{
		while(fptr.peek() == '#')
		{
			getline(fptr, line);
			cout << line << endl;
		}
		getline(fptr, line);
		for(int x = 0; x < (1 << mbxw); ++x)
		{
			svUnsigned<2> fptr_data_temp;
			fptr_data[y][x] = line[x] - '0';
			fptr_data_temp = fptr_data[y][x];
			set_fptr_data(fptr_addr.logic(), fptr_data_temp.logic());
			fptr_addr = fptr_addr.val() + 1;
		}
	}

	// make pixel data

	finished = 0;

	writedata = M2VDD_HX8347A_CONTROL_START_MSK;
	ctrl_write(writedata.logic(), cycles.plogic());
	if(cycles.val() > 10)
	{
		cout << "# Error: write latency is too long" << endl;
		return 1;
	}
	total_cycles = cycles.val();

	picture_start();

	while(1)
	{
		svUnsigned<32> readdata;
		ctrl_read(readdata.plogic(), cycles.plogic());
		total_cycles += cycles.val();
		if(!(readdata.val() & 1)) break;
	}

	wait = (rand() % 10);
	for(; wait >= 0; --wait) posedge_clk();
	return 0;
}

static int dd_fbuf_read(
	const svUnsigned<MEM_WIDTH> address,
	svUnsigned<16>& data,
	svInt& waitcycles)
{
	if(address.has_zx() || (address.val() & 1))
	{
		cout << "# Error: invalid read address (" << address << ")" << endl;
		return 1;
	}

	data = fbuf_data[address.val()] | (((uint16_t)fbuf_data[address.val() + 1]) << 8);

	waitcycles = rand() % 10;
	return 0;
}

static int dd_fbuf_write(
	const svUnsigned<MEM_WIDTH> address,
	const svUnsigned<16> data,
	svInt& waitcycles)
{
	cout << "# Error: illegal write access to frame buffer!" << endl;
	return 1;
}

DPI_LINK_DECL int feed_picture(svLogic* finished)
{
	return feed_picture(svUnsigned<1>::cast(finished));
}

DPI_LINK_DECL int dd_fbuf_read(
	const svLogicVecVal* address,
	svLogicVecVal* data,
	svLogicVecVal* waitcycles)
{
	return dd_fbuf_read(svUnsigned<MEM_WIDTH>::cast(address),
						svUnsigned<16>::cast(data),
						svInt::cast(waitcycles));
}

DPI_LINK_DECL int dd_fbuf_write(
	const svLogicVecVal* address,
	const svLogicVecVal* data,
	svLogicVecVal* waitcycles)
{
	return dd_fbuf_write(svUnsigned<MEM_WIDTH>::cast(address),
						 svUnsigned<16>::cast(data),
						 svInt::cast(waitcycles));
}


