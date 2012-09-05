//================================================================================
// Feeder for test_m2vmc
//================================================================================

#include <dpic_helper.hpp>
#include <tb_common.hpp>
#include "test_m2vmc.h"
#include <string>
#include <fstream>
#include <stdlib.h>
using namespace std;

#define MEM_WIDTH	21
#define MVH_WIDTH	16
#define MVV_WIDTH	15
#define MBX_WIDTH	6
#define MBY_WIDTH	5

extern bool verifying;

static ifstream side, idct_out;
static int feed_stall;

DPI_LINK_DECL int start_feeding(const char* ref_dir)
{
	svUnsigned<1> ready_mc;
	svUnsigned<3> s3_block;

	if(!open_refdata(side, ref_dir, "side.txt") ||
		!open_refdata(idct_out, ref_dir, "idct_out.txt"))
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
	feed_stall = 0;
	return 0;
}

static int feed_block(svUnsigned<1>& finished)
{
	static int coefs[64];

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

	svUnsigned<1> s4_enable;
	svUnsigned<1> s4_coded;

	finished = 0;

	if(feed_stall > 0)
	{
		pre_block_start();
		set_sideinfo_blk(sv_0, sv_0, s3_block.set_x().logic());
		block_start();
		--feed_stall;
	}
	else
	{
		if(side.eof())
		{
			finished = 1;
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
				cout << "# Info: [feed] " << line << endl;
			}

			setnewline(side, ss) >> name >> num;
			if(name == "BLK")
			{
				s3_block = num;
				break;
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
			}
			else if(name == "PICE")
			{
				feed_stall = 3;
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
		get_s4_coded(s4_enable.plogic(), s4_coded.plogic());

		if(s4_enable.val())
		{
			unsigned int next_addr;
			svUnsigned<1> pixel_coded;
			svUnsigned<5> pixel_addr;
			svSigned<9> pixel_data0;
			svSigned<9> pixel_data1;
			pixel_data0 = 0;
			pixel_data1 = 0;

			for(next_addr = 0; next_addr < 32; ++next_addr)
			{
				wait = (next_addr > 0) ? 1 : 200;
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

			posedge_clk();
			set_pixel_data(pixel_data0.set_x().logic(), pixel_data1.set_x().logic());
		}

		if(s3_coded.val())
		{
			int i;
			while(idct_out.peek() == '#') skipline(idct_out);
			for(i = 0; i < 64; ++i)
			{
				if((i % 8) == 0) setnewline(idct_out, ss);
				ss >> coefs[i];
			}
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

DPI_LINK_DECL int feed_block(svLogic* finished)
{
	return feed_block(*((svUnsigned<1>*)finished));
}

