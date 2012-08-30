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

static ifstream side, isdq_out;
static int feed_stall;

int start_feeding(const char* ref_dir)
{
	svUnsigned<1> ready_idct;

	if(!open_refdata(side, ref_dir, "side.txt") ||
		!open_refdata(isdq_out, ref_dir, "isdq_out.txt"))
		return 1;

	wait_reset_done();
	while(1)
	{
		posedge_clk();
		read_ready_idct(ready_idct);
		if(ready_idct.aval()) break;
	}

	feed_stall = 0;
	return 0;
}

static int feed_block(svUnsigned<1>& finished)
{
	string name;
	stringstream ss;

	int blk;
	int wait;
	svUnsigned<1> s2_coded;
	svUnsigned<1> s3_coded;
	finished = 0;

	if(feed_stall > 0)
	{
		set_sideinfo(sv_0, sv_0);
		block_start();
		--feed_stall;
		return 0;
	}

	if(side.eof())
	{
		finished = 1;
		return 0;
	}

	// get next block's side information
	setnewline(ss, side) >> name >> blk;

	if(name == "pic")
	{
		feed_stall = 4;
		return 0;
	}

	if(name != "blk") goto syntax_error;
	if(blk == 0)
	{
		setnewline(ss, side);	// idp
		setnewline(ss, side);	// qst
		setnewline(ss, side);	// if
		setnewline(ss, side);	// mbx
		setnewline(ss, side);	// mby
		setnewline(ss, side);	// mvh
		setnewline(ss, side);	// mvv
		setnewline(ss, side);	// mbqsc
		setnewline(ss, side);	// intra
	}
	setnewline(ss, side) >> name >> s2_coded;
	if(name != "coded") goto syntax_error;

	set_sideinfo(sv_1, s2_coded);
	block_start();

	if(s2_coded.aval())
	{
	}

	extern bool verifying;
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
	return feed_block(*(svUnsigned<1>*)finished);
}

