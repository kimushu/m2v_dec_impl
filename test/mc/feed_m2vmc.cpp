//================================================================================
// Feeder for test_m2vmc
//================================================================================

#include <dpic_helper.hpp>
#include <tb_common.hpp>
#include "test_m2vmc.h"
#include <string>
#include <fstream>
#include <stdlib.h>
#include <params_m2vdec.h>
using namespace std;

extern bool verifying;

int video_wd, video_ht;
static ifstream side, idct_out, mc_fetch;
static bool feed_finished_s3;
static int feed_stall_s3;
static int fetch_pos;
static uint32_t fetch_addr[45];
static uint16_t fetch_data[45];
static int coefs[64];

#define ADDR_INVALID		0xffffffffu

DPI_LINK_DECL int init_feed(const char* ref_dir)
{
	svUnsigned<1> ready_mc;
	svUnsigned<3> s3_block;

	if(!open_refdata(side, ref_dir, "side.txt") ||
		!open_refdata(idct_out, ref_dir, "idct_out.txt") ||
		!open_refdata(mc_fetch, ref_dir, "mc_fetch.out"))
		return 1;

	wait_reset_done();
	while(1)
	{
		posedge_clk();
		read_ready_mc(ready_mc.plogic());
		if(ready_mc.val()) break;
	}

	set_sideinfo_blk(sv_0, sv_0, s3_block.set_x().logic());
	posedge_clk();
	feed_stall_s3 = 0;
	feed_finished_s3 = false;
	fetch_pos = -1;
	return 0;
}

static int feed_block_s3(svUnsigned<1>& finished)
{
	string name;
	stringstream ss;

	int num;
	int wait;
	svUnsigned<1> ready_mc;
	svUnsigned<1> sa_iframe;
	svUnsigned<MBX_WIDTH> s3_mb_x;
	svUnsigned<MBY_WIDTH> s3_mb_y;
	svSigned<MVH_WIDTH> s3_mv_h;
	svSigned<MVV_WIDTH> s3_mv_v;
	svUnsigned<1> s3_mb_intra;
	svUnsigned<1> s3_coded;
	svUnsigned<3> s3_block;

	finished = 0;

	if(feed_stall_s3 > 0)
	{
		pre_block_start();
		set_sideinfo_blk(sv_0, sv_0, s3_block.set_x().logic());
		block_start();
		--feed_stall_s3;
		cout << "# Info: [feed(s3)] stall" << endl;
		if(feed_stall_s3 == 0)
		{
			cout << "# Info: [feed(s3)] picture_complete" << endl;
			svUnsigned<1> ready_mc;
			picture_complete();
			for(wait = 500; wait > 0; --wait)
			{
				posedge_clk();
				read_ready_mc(ready_mc.plogic());
				if(ready_mc.val()) break;
			}
			if(!ready_mc.val())
			{
				cout << "# Error: picture_complete process is too long!" << endl;
				return 1;
			}
		}
	}
	else
	{
		if(side.eof())
		{
			finished = 1;
			feed_finished_s3 = true;
			return 0;
		}

		pre_block_start();

		// get side information
		while(1)
		{
			while(side.peek() == '#')
			{
				string line;
				getline(side, line);
				cout << "# Info: [feed(s3)] " << line << endl;
			}

			setnewline(side, ss) >> name >> num;
			if(name == "BLK")
			{
				s3_block = num;
				break;
			}
			else if(name == "SEQ")
			{
				int cqmat;
				setnewline(side, ss) >> name >> video_wd;
				if(name != "vw") goto syntax_error;
				setnewline(side, ss) >> name >> video_ht;
				if(name != "vh") goto syntax_error;
				setnewline(side, ss);	// frc
				setnewline(side, ss) >> cqmat;	// iqm?
				if(cqmat) for(int i = 0; i < 8; ++i) skipline(side);
				setnewline(side, ss) >> cqmat;	// nqm?
				if(cqmat) for(int i = 0; i < 8; ++i) skipline(side);
			}
			else if(name == "PIC")
			{
				setnewline(side, ss);	// qst
				setnewline(side, ss);	// idp
				setnewline(side, ss) >> name >> sa_iframe;
				if(name != "if") goto syntax_error;
				set_sideinfo_pic(sa_iframe.logic());
			}
			else if(name == "MB")
			{
				setnewline(side, ss) >> name >> s3_mb_x;
				if(name != "mbx") goto syntax_error;
				setnewline(side, ss) >> name >> s3_mb_y;
				if(name != "mby") goto syntax_error;
				setnewline(side, ss) >> name >> s3_mv_h;
				if(name != "mvh") goto syntax_error;
				setnewline(side, ss) >> name >> s3_mv_v;
				if(name != "mvv") goto syntax_error;
				setnewline(side, ss);	// mbqsc
				setnewline(side, ss) >> name >> s3_mb_intra;
				if(name != "intra") goto syntax_error;
				set_sideinfo_mb(s3_mv_h.logic(), s3_mv_v.logic(),
								s3_mb_x.logic(), s3_mb_y.logic(),
								s3_mb_intra.logic());

				fetch_pos = s3_mb_intra.val() ? -1 : 45;
			}
			else if(name == "PICE")
			{
				feed_stall_s3 = 3;
				return 0;
			}
			else
			{
				goto syntax_error;
			}
		}

		setnewline(side, ss) >> name >> s3_coded;
		if(name != "coded") goto syntax_error;

		set_sideinfo_blk(sv_1, s3_coded.logic(), s3_block.logic());

		block_start();

		if(fetch_pos >= 0)
		{
			cout << "# Info: [feed(s3)] reading reference fetch data" << endl;
			if(fetch_pos != 45)
			{
				cout << "# Error: Number of fetch reads mismatch!" << endl;
				return 1;
			}

			for(int i = 0; i < 45; ++i)
			{
				while(mc_fetch.peek() == '#') skipline(mc_fetch);
				setnewline(mc_fetch, ss);
				ss >> hex >> fetch_addr[i] >> fetch_data[i];
				// cout << "# Info (" << fetch_addr[i] << ":" << fetch_data[i] << ")" << endl;
			}
			fetch_pos = 0;
		}
	}

	do
	{
		posedge_clk();
		read_ready_mc(ready_mc.plogic());
	}
	while(verifying || !ready_mc.val());

	wait = (rand() % 10);
	for(; wait >= 0; --wait) posedge_clk();
	return 0;

syntax_error:
	cout << "# Error: Invalid reference data syntax" << endl;
	return 1;
}

static int feed_block_s4(svUnsigned<1>& finished)
{
	int wait;
	unsigned int next_addr;
	svUnsigned<1> pixel_coded;
	svUnsigned<5> pixel_addr;
	svSigned<9> pixel_data0;
	svSigned<9> pixel_data1;
	svUnsigned<1> s4_enable;
	svUnsigned<1> s4_coded;

	pixel_data0 = 0;
	pixel_data1 = 0;

	finished = feed_finished_s3 ? 1 : 0;

	get_s4_coded(s4_enable.plogic(), s4_coded.plogic());

	if(!s4_enable.val())
	{
		posedge_clk();
		return 0;
	}

	if(s4_coded.val())
	{
		stringstream ss;
		int i;
		while(idct_out.peek() == '#') skipline(idct_out);
		for(i = 0; i < 64; ++i)
		{
			if((i % 8) == 0) setnewline(idct_out, ss);
			ss >> coefs[i];
		}
	}
	else
	{
		memset(coefs, 0, sizeof(coefs));
	}

	for(next_addr = 0; next_addr < 32; ++next_addr)
	{
		wait = (next_addr > 0) ? 10 : 200;
		for(; wait > 0; --wait)
		{
			posedge_clk();
			get_pixel_addr(pixel_coded.plogic(), pixel_addr.plogic());
			if(pixel_addr.val() == next_addr) break;
		}
		if(wait == 0)
		{
			cout << "# Error: pixel_addr mismatch (Read: " << pixel_addr <<
					", Expected: " << next_addr << ")" << endl;
			return 1;
		}
		if(pixel_coded.val() != s4_coded.val())
		{
			cout << "# Error: pixel_coded mismatch (Read: " << pixel_coded <<
					", Expected: " << s4_coded << ")" << endl;
			return 1;
		}

		if(pixel_coded.val())
		{
			pixel_data0 = coefs[next_addr * 2 + 0];
			pixel_data1 = coefs[next_addr * 2 + 1];
		}
		set_pixel_data(pixel_data0.logic(), pixel_data1.logic());
	}

	for(wait = 10; wait > 0; --wait)
	{
		posedge_clk();
		get_pixel_addr(pixel_coded.plogic(), pixel_addr.plogic());
		if(pixel_addr.val() != 31) break;
	}
	set_pixel_data(pixel_data0.set_x().logic(), pixel_data1.set_x().logic());

	return 0;
}

static int mc_fbuf_read(
	const svUnsigned<MEM_WIDTH> address,
	svUnsigned<16>& data,
	svInt& waitcycles)
{
	if(fetch_pos < 0 || fetch_pos >= 45)
	{
		cout << "# Error: Number of fetch reads mismatch!" << endl;
		return 1;
	}

	if(address.has_zx() || address.val() != fetch_addr[fetch_pos])
	{
		cout << "# Error: Fetch address mismatch! (Read: " << address <<
				", Expected: " << fetch_addr[fetch_pos] << ")" << endl;
		return 1;
	}

	data = fetch_data[fetch_pos];
	++fetch_pos;
	waitcycles = rand() % 10;
	return 0;
}

DPI_LINK_DECL int feed_block_s3(svLogic* finished)
{
	return feed_block_s3(svUnsigned<1>::cast(finished));
}

DPI_LINK_DECL int feed_block_s4(svLogic* finished)
{
	return feed_block_s4(svUnsigned<1>::cast(finished));
}

DPI_LINK_DECL int mc_fbuf_read(
	const svLogicVecVal* address,
	svLogicVecVal* data,
	svLogicVecVal* waitcycles)
{
	return mc_fbuf_read(svUnsigned<MEM_WIDTH>::cast(address),
						svUnsigned<16>::cast(data),
						svInt::cast(waitcycles));
}

