//================================================================================
// Verifier for test_m2vidct
//================================================================================

#include <dpic_helper.hpp>
#include <tb_common.hpp>
#include "test_m2vidct.h"
#include <string>
#include <fstream>
#include <stdlib.h>
using namespace std;

static ifstream idct_out;
bool verifying;

DPI_LINK_DECL int init_verify(const char* ref_dir)
{
	int wait;
	svUnsigned<1> ready_idct;

	if(!open_refdata(idct_out, ref_dir, "idct_out.txt"))
		return 1;

	wait_reset_done();
	for(wait = 0; wait < 10; ++wait)
	{
		read_ready_idct(ready_idct.plogic());
		posedge_clk();
		if(ready_idct.val()) break;
	}

	if(!ready_idct.val())
	{
		cout << "# Error: Software reset time is too long!" << endl;
		return 1;
	}

	verifying = false;
	return 0;
}

static int verify_block(svUnsigned<1> s4_enable, svUnsigned<1> s4_coded)
{
	if(!idct_out) return 0;

	if(!s4_enable.val()) return 0;

	svUnsigned<5> pixel_addr;
	svSigned<9> pixel_data0;
	svSigned<9> pixel_data1;
	stringstream ss;
	int i;
	int expected[64];

	verifying = true;

	if(!s4_coded.val())
	{
		// 64 zeros
		for(i = 0; i < 64; ++i) expected[i] = 0;
	}
	else
	{
		while(idct_out.peek() == '#')
		{
			string line;
			getline(idct_out, line);
			cout << "# Info: [verify] " << line << endl;
		}

		// load 64 expected values
		for(i = 0; i < 64; ++i)
		{
			if((i % 8) == 0)
			{
				if(idct_out.eof())
				{
					cout << "# Error: cannot read expected value data!" << endl;
					return 1;
				}
				setnewline(idct_out, ss);
			}
			ss >> expected[i];
		}
	}

	verifying = true;

	for(i = 0; i < 33; ++i)
	{
		if(i < 32)
			pixel_addr = i;
		else
			pixel_addr.set_x();

		set_pixel_addr(s4_coded.logic(), pixel_addr.logic());
		posedge_clk();

		if(i > 0)
		{
			get_pixel_data(pixel_data0.plogic(), pixel_data1.plogic());
			if(pixel_data0.val() != expected[i*2-2] || pixel_data1.val() != expected[i*2-1])
			{
				cout << "# Error: Verify failed! (Index: " << i <<
						", Read: (" << pixel_data0 << ", " << pixel_data1 <<
						"), Expected: (" << expected[i*2] << ", " << expected[i*2+1] << "))" << endl;
				posedge_clk();
				return 1;
			}
		}
	}

	verifying = false;

	return 0;
}

DPI_LINK_DECL int verify_block(svLogic s4_enable, svLogic s4_coded)
{
	return verify_block(svUnsigned<1>(s4_enable), svUnsigned<1>(s4_coded));
}

