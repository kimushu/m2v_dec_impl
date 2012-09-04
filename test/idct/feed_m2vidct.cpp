//================================================================================
// Feeder for test_m2vidct
//================================================================================

#include <dpic_helper.hpp>
#include <tb_common.hpp>
#include "test_m2vidct.h"
#include <string>
#include <fstream>
#include <stdlib.h>
using namespace std;

extern bool verifying;

static ifstream side, isdq_out;
static int feed_stall;

DPI_LINK_DECL int start_feeding(const char* ref_dir)
{
	svUnsigned<1> ready_idct;

	if(!open_refdata(side, ref_dir, "side.txt") ||
		!open_refdata(isdq_out, ref_dir, "isdq_out.txt"))
		return 1;

	wait_reset_done();
	while(1)
	{
		posedge_clk();
		read_ready_idct(ready_idct.plogic());
		if(ready_idct.val()) break;
	}

	set_sideinfo_blk(sv_0, sv_0);
	posedge_clk();
	feed_stall = 0;
	return 0;
}

static int feed_block(svUnsigned<1>& finished)
{
	string name;
	stringstream ss;

	int num;
	int wait;
	int i;
	int coefs[64];
	svUnsigned<1> s2_coded;
	svUnsigned<1> coef_next;
	svUnsigned<1> coef_sign;
	svUnsigned<12> coef_data;
	svUnsigned<1> ready_idct;

	finished = 0;

	if(feed_stall > 0)
	{
		pre_block_start();
		set_sideinfo_blk(sv_0, sv_0);
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
				break;
			}
			else if(name == "PIC")
			{
				setnewline(side, ss);	// idp
				setnewline(side, ss);	// qst
				setnewline(side, ss);	// if
			}
			else if(name == "MB")
			{
				setnewline(side, ss);	// mbx
				setnewline(side, ss);	// mby
				setnewline(side, ss);	// mvh
				setnewline(side, ss);	// mvv
				setnewline(side, ss);	// mbqsc
				setnewline(side, ss);	// intra
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

		setnewline(side, ss) >> name >> s2_coded;
		if(name != "coded") goto syntax_error;

		set_sideinfo_blk(sv_1, s2_coded.logic());

		block_start();

		if(s2_coded.val())
		{
			while(isdq_out.peek() == '#') skipline(isdq_out);
			for(i = 0; i < 64; ++i)
			{
				if((i % 8) == 0) setnewline(isdq_out, ss);
				ss >> coefs[i];
			}

			// feed by transpositioned order
			for(i = 0; i < 64; ++i)
			{
				int value = coefs[(i % 8) * 8 + (i / 8)];
				coef_sign = (value < 0) ? 1 : 0;
				coef_data = (value < 0) ? -value : value;
				set_coef_data(coef_sign.logic(), coef_data.logic());
				for(wait = 10; wait > 0; --wait)
				{
					posedge_clk();
					get_coef_next(coef_next.plogic());
					if(coef_next.val()) break;
				}
				if(!coef_next.val())
				{
					cout << "# Error: coef_next must be asserted!" << endl;
					return 1;
				}
				for(wait = 1; wait > 0; --wait)
				{
					posedge_clk();
					get_coef_next(coef_next.plogic());
					if(!coef_next.val()) break;
				}
				if(coef_next.val())
				{
					cout << "# Error: coef_next must be negated!" << endl;
					return 1;
				}
			}
		}
	}

	do
	{
		posedge_clk();
		read_ready_idct(ready_idct.plogic());
	}
	while(verifying || !ready_idct.val());

	wait = (rand() % 10);
	for(; wait >= 0; --wait) posedge_clk();
	return 0;

syntax_error:
	cout << "# Error: Invalid reference data syntax" << endl;
	return 1;
}

DPI_LINK_DECL int feed_block(svLogic* finished)
{
	return feed_block(*(svUnsigned<1>*)finished);
}

