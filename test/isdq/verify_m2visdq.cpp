//================================================================================
// Verifier for test_m2visdq
//================================================================================

#include <dpic_helper.hpp>
#include <tb_common.hpp>
#include "test_m2visdq.h"
#include <string>
#include <fstream>
#include <stdlib.h>
using namespace std;

static ifstream isdq_out;
bool verifying;

DPI_LINK_DECL int start_verifying(const char* ref_dir)
{
	int wait;
	svUnsigned<1> ready_isdq;

	if(!open_refdata(isdq_out, ref_dir, "isdq_out.txt"))
		return 1;

	wait_reset_done();
	set_coef_next(sv_0);
	for(wait = 0; wait < 130; ++wait)
	{
		read_ready_isdq(ready_isdq.plogic());
		posedge_clk();
		if(ready_isdq.val()) break;
	}

	if(!ready_isdq.val())
	{
		cout << "# Error: Software reset time is too long!" << endl;
		return 1;
	}

	verifying = false;
	return 0;
}

static int verify_block(svUnsigned<1> s2_enable, svUnsigned<1> s2_coded)
{
	int i;
	int wait;

	if(!isdq_out) return 0;

	if(!(s2_enable.val() & s2_coded.val())) return 0;

	svUnsigned<1> coef_sign;
	svUnsigned<12> coef_data;
	stringstream ss;
	int read;
	int expected[64];

	while(isdq_out.peek() == '#')
	{
		string line;
		getline(isdq_out, line);
		cout << "# Info: [verify] " << line << endl;
	}

	// load '64 expected values' with transpositioning
	for(i = 0; i < 64; ++i)
	{
		if((i % 8) == 0)
		{
			if(isdq_out.eof())
			{
				cout << "# Error: cannot read expected value data!" << endl;
				return 1;
			}
			setnewline(isdq_out, ss);
		}
		ss >> expected[(i % 8) * 8 + (i / 8)];
	}

	// verify
	verifying = true;
	for(i = 0; i < 128; ++i)
	{
		set_coef_next((i & 1) ? sv_0 : sv_1);
		posedge_clk();
		get_coef_values(coef_sign.plogic(), coef_data.plogic());

		if(coef_sign.has_zx())
		{
			cout << "# Error: coef_sign is X or Z!" << endl;
			posedge_clk();
			return 1;
		}
		if(coef_data.has_zx())
		{
			cout << "# Error: coef_data contains X or Z!" << endl;
			posedge_clk();
			return 1;
		}

		read = coef_data.val();
		if(coef_sign.val()) read = -read;

		if(read != expected[i / 2])
		{
			cout << "# Error: Verify failed! (Index: " << i << ", Read: " << read <<
					", Expected: " << expected[i / 2] << ")" << endl;
			posedge_clk();
			return 1;
		}
	}
	verifying = false;

	return 0;
}

DPI_LINK_DECL int verify_block(svLogic s2_enable, svLogic s2_coded)
{
	return verify_block(svUnsigned<1>(s2_enable), svUnsigned<1>(s2_coded));
}

