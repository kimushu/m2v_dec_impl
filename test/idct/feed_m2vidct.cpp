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

ifstream side, rl;

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

	return 0;
}

int feed_block(svLogic* finished)
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
	svUnsigned<1>& _finished = *(svUnsigned<1>*)finished;

	*_finished = 0;
	while(1)
	{
		if(side.eof())
		{
			*_finished = 1;
			return 0;
		}

		// get next block's side information
		setnewline(ss, side) >> name >> blk;
		if(name != "blk") break;
		if(blk == 0)
		{
			setnewline(ss, side) >> name >> sa_dcprec;
			if(name != "idp") break;
			setnewline(ss, side) >> name >> sa_qstype;
			if(name != "qst") break;
			setnewline(ss, side);	// if
			setnewline(ss, side);	// mbx
			setnewline(ss, side);	// mby
			setnewline(ss, side);	// mvh
			setnewline(ss, side);	// mvv
			setnewline(ss, side) >> name >> s1_mb_qscode;
			if(name != "mbqsc") break;
			setnewline(ss, side) >> name >> s1_mb_intra;
			if(name != "intra") break;
		}
		setnewline(ss, side) >> name >> s1_coded;
		if(name != "coded") break;

		set_sideinfo(sv_1, s1_coded, s1_mb_intra, s1_mb_qscode,
						sa_qstype, sa_dcprec);
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

		extern bool verifying;
		while(verifying) posedge_clk();

		wait = (rand() % 10);
		for(; wait >= 0; --wait) posedge_clk();
	}

	printf("# Error: Invalid reference data syntax\n");
	return 1;
}

