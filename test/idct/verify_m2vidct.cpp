//================================================================================
// Verifier for test_m2visdq
//================================================================================

#include <dpic_helper.hpp>
#include "test_m2visdq.h"
#include <string>
#include <fstream>
#include <stdlib.h>
using namespace std;

static ifstream isdq_out;
bool verifying = false;

int start_verifying(const char* ref_dir)
{
	int wait;
	svUnsigned<1> ready_isdq;

	if(!open_refdata(isdq_out, ref_dir, "isdq_out.txt"))
		return 1;

	wait_reset_done();
	set_coef_next(sv_0);
	for(wait = 0; wait < 130; ++wait)
	{
		read_ready_isdq(ready_isdq);
		posedge_clk();
		if(ready_isdq.aval()) break;
	}

	if(!ready_isdq.aval())
	{
		printf("# Error: Software reset time is too long!\n");
		return 1;
	}

	return 0;
}

int verify_block()
{
	int i;

	if(!isdq_out) return 0;

	svUnsigned<1> coef_sign;
	svUnsigned<12> coef_data;
	stringstream ss;
	int read;
	int expected[64];

	// load '64 expected values' with transpositioning
	for(i = 0; i < 64; ++i)
	{
		if((i % 8) == 0)
		{
			if(isdq_out.eof())
			{
				printf("# Error: cannot read expected value data!\n");
				return 1;
			}
			setnewline(ss, isdq_out);
		}
		ss >> expected[(i % 8) * 8 + (i / 8)];
	}

	// verify
	verifying = true;
	for(i = 0; i < 128; ++i)
	{
		set_coef_next((i & 1) ? sv_0 : sv_1);
		posedge_clk();
		get_coef_values(coef_sign, coef_data);

		if(coef_sign.has_zx())
		{
			printf("# Error: coef_sign is X or Z!\n");
			return 1;
		}
		if(coef_data.has_zx())
		{
			printf("# Error: coef_data contains X or Z!\n");
			return 1;
		}

		read = (int)coef_data.aval();
		if(coef_sign.aval()) read = -read;

		if(read != expected[i / 2])
		{
			printf("# Error: Verify failed! (Index: %d, Read: %d, Expected: %d)\n",
					i, read, expected[i / 2]);
			return 1;
		}
	}
	verifying = false;

	return 0;
}

