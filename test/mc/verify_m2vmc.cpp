//================================================================================
// Verifier for test_m2visdq
//================================================================================

#include <dpic_helper.hpp>
#include <tb_common.hpp>
#include "test_m2vmc.h"
#include <string>
#include <fstream>
#include <stdlib.h>
#include <iomanip>
#include "params_m2vmc.h"
using namespace std;

static ifstream mc_mix;
static int mix_pos;
static uint32_t mix_addr[32];
static uint16_t mix_data[32];
bool verifying;

DPI_LINK_DECL int start_verifying(const char* ref_dir)
{
	int wait;
	svUnsigned<1> ready_mc;

	if(!open_refdata(mc_mix, ref_dir, "mc_mix.out"))
		return 1;

	wait_reset_done();
	for(wait = 0; wait < 130; ++wait)
	{
		read_ready_mc(ready_mc.plogic());
		posedge_clk();
		if(ready_mc.val()) break;
	}

	if(!ready_mc.val())
	{
		cout << "# Error: Software reset time is too long!" << endl;
		return 1;
	}

	verifying = false;
	mix_pos = 32;
	return 0;
}

static int verify_block(svUnsigned<1> s4_enable, svUnsigned<1> s4_coded)
{
	int i;
	// int wait;

	if(!mc_mix) return 0;

	if(!s4_enable.val()) return 0;

	if(mix_pos != 32)
	{
		cout << "# Error: Number of mix writes mismatch!" << endl;
		return 1;
	}

	stringstream ss;

	while(mc_mix.peek() == '#')
	{
		string line;
		getline(mc_mix, line);
		cout << "# Info: [verify] " << line << endl;
	}

	// load 32 expected values
	for(i = 0; i < 32; ++i)
	{
		setnewline(mc_mix, ss) >> hex >> mix_addr[i] >> mix_data[i];
	}

	mix_pos = 0;
	verifying = true;
	return 0;
}

static int mc_fbuf_write(
	const svUnsigned<MEM_WIDTH> address,
	const svUnsigned<16> data,
	svInt& waitcycles)
{
	if(!verifying || mix_pos >= 32)
	{
		cout << "# Error: Number of mix writes mismatch!" << endl;
		return 1;
	}

	if(address.has_zx() || address.val() != mix_addr[mix_pos])
	{
		cout << "# Error: Mix address mismatch! (Read: " << hex <<
				setw(6) << setfill('0') << address <<
				", Expected: " << setw(6) << mix_addr[mix_pos] << ")" << endl;
		posedge_clk();
		return 1;
	}

	if(data.has_zx() || data.val() != mix_data[mix_pos])
	{
		cout << "# Error: Mix data mismatch! @address=" <<
				hex << setw(6) << setfill('0') << address <<
				" (Read: " << hex << setw(4) << setfill('0') << data <<
				", Expected: " << setw(4) << mix_data[mix_pos] << ")" << endl;
		posedge_clk();
		return 1;
	}

	if(++mix_pos == 32)
	{
		verifying = false;
	}

	waitcycles = rand() % 5;
	return 0;
}

DPI_LINK_DECL int verify_block(svLogic s2_enable, svLogic s2_coded)
{
	return verify_block(svUnsigned<1>(s2_enable), svUnsigned<1>(s2_coded));
}

DPI_LINK_DECL int mc_fbuf_write(
	const svLogicVecVal* address,
	const svLogicVecVal* data,
	svLogicVecVal* waitcycles)
{
	return mc_fbuf_write(svUnsigned<MEM_WIDTH>::cast(address),
						 svUnsigned<16>::cast(data),
						 svInt::cast(waitcycles));
}

