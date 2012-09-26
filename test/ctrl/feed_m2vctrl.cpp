//================================================================================
// Feeder for test_m2vmc
//================================================================================

#include <dpic_helper.hpp>
#include <tb_common.hpp>
#include "test_m2vctrl.h"
#include <string>
#include <fstream>
#include <stdlib.h>
using namespace std;

static ifstream input_bin;
static bool feed_finished;

#define ADDR_INVALID		0xffffffffu

DPI_LINK_DECL int init_feed(const char* ref_dir)
{
	if(!open_refdata(input_bin, ref_dir, "input.bin"))
		return 1;

	wait_reset_done();

	for(int busy = 0; busy < 50; ++busy) posedge_clk();

	set_ready(sv_1, sv_1, sv_1);

	feed_finished = false;
	return 0;
}

static int feed_stream(svUnsigned<1>& finished)
{
	uint32_t buf;

	svUnsigned<32> data;
	svInt cycles;

	finished = 0;

	while(!input_bin.eof())
	{
		buf = 0xffffffff;
		input_bin.read((char*)&buf, sizeof(buf));

		data = buf;
		stream_write(data.logic(), cycles.plogic());

		// TODO: stop if too many cycle required
	}

	finished = 1;
	return 0;
}

DPI_LINK_DECL int feed_stream(svLogic* finished)
{
	return feed_stream(svUnsigned<1>::cast(finished));
}

