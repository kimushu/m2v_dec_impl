//================================================================================
// Feeder for test_m2visdq
//================================================================================

#include <dpic_helper.hpp>
#include <tb_common.hpp>
#include "test_m2visdq.h"
#include <string>
#include <fstream>
#include <stdlib.h>
using namespace std;

extern bool verifying;

static ifstream side, rl;
static int feed_stall;

int start_feeding(const char* ref_dir)
{
	svUnsigned<1> ready_isdq;

	if(!open_refdata(side, ref_dir, "side.txt") ||
		!open_refdata(rl, ref_dir, "rl.txt"))
		return 1;

	wait_reset_done();
	while(1)
	{
		posedge_clk();
		read_ready_isdq(ready_isdq);
		if(ready_isdq.aval()) break;
	}

	feed_stall = 0;
	return 0;
}

static int feed_block(svUnsigned<1>& finished)
{
	string name;
	stringstream ss;

	int wait;
	int blk;
	int level;
	svUnsigned<1> s1_coded;
	svUnsigned<1> s1_mb_intra;
	svUnsigned<5> s1_mb_qscode;
	svUnsigned<1> sa_qstype;
	svUnsigned<2> sa_dcprec;
	svUnsigned<6> run;
	svUnsigned<1> level_sign;
	svUnsigned<11> level_data;

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

		// get next block's side information
		setnewline(ss, side) >> name >> blk;
		if(name != "blk") goto syntax_error;
		if(blk == 0)
		{
			setnewline(ss, side) >> name >> sa_dcprec;
			if(name != "idp") goto syntax_error;
			setnewline(ss, side) >> name >> sa_qstype;
			if(name != "qst") goto syntax_error;
			setnewline(ss, side);	// if
			setnewline(ss, side);	// mbx
			setnewline(ss, side);	// mby
			setnewline(ss, side);	// mvh
			setnewline(ss, side);	// mvv
			setnewline(ss, side) >> name >> s1_mb_qscode;
			if(name != "mbqsc") goto syntax_error;
			setnewline(ss, side) >> name >> s1_mb_intra;
			if(name != "intra") goto syntax_error;

			set_sideinfo_mb(s1_mb_intra, s1_mb_qscode, sa_qstype, sa_dcprec);
		}
		setnewline(ss, side) >> name >> s1_coded;
		if(name != "coded") goto syntax_error;

		set_sideinfo_blk(sv_1, s1_coded);

		block_start();

		if(s1_coded.aval())
		{
			// feed rl-pairs
			while(1)
			{
				wait = rand() % 10;
				for(; wait >= 0; --wait) posedge_clk();
				setnewline(ss, rl) >> run >> level;
				if(level == 0) break;
				level_sign = (level < 0) ? 1 : 0;
				level_data = (level < 0) ? -level : level;
				feed_rlpair(run, level_sign, level_data);
			}

			block_end();
		}
	}

	while(verifying) posedge_clk();
	wait = (rand() % 10);
	for(; wait >= 0; --wait) posedge_clk();
	return 0;

syntax_error:
	printf("# Error: Invalid reference data syntax\n");
	return 1;
}

int feed_block(svLogic* finished)
{
	return feed_block(*((svUnsigned<1>*)finished));
}

