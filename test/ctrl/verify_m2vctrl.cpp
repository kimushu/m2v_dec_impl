//================================================================================
// Verifier for test_m2vctrl
//================================================================================

#include <dpic_helper.hpp>
#include <tb_common.hpp>
#include "test_m2vctrl.h"
#include <string>
#include <fstream>
#include <stdlib.h>
#include <iomanip>
#include <m2vdec_regs.h>
using namespace std;

static ifstream ref_side, ref_rl;

DPI_LINK_DECL int init_verify(const char* ref_dir)
{
	if(!open_refdata(ref_side, ref_dir, "side.txt") ||
		!open_refdata(ref_rl, ref_dir, "rl.txt"))
		return 1;

	return 0;
}

static int verify_video(svUnsigned<1>& finished)
{
	string name;
	stringstream ss;

	svUnsigned<1> irq_change;
	svUnsigned<1> irq_value;
	svUnsigned<1> pict_valid;
	svUnsigned<1> mvec_h_valid;
	svUnsigned<1> mvec_v_valid;
	svUnsigned<1> s0_valid;
	svUnsigned<1> rl_valid;
	svUnsigned<1> qm_valid;
	svUnsigned<1> pre_block_start;
	svUnsigned<1> block_start;
	svUnsigned<1> block_end;
	svUnsigned<1> picture_complete;
#define wait_events()	wait_event( \
	irq_change.plogic(), irq_value.plogic(), pict_valid.plogic(), \
	mvec_h_valid.plogic(), mvec_v_valid.plogic(), \
	s0_valid.plogic(), rl_valid.plogic(), qm_valid.plogic(), \
	pre_block_start.plogic(), block_start.plogic(), block_end.plogic(), \
	picture_complete.plogic())

	finished = 0;
	while(!ref_side.eof())
	{
		while(ref_side.peek() == '#')
		{
			string line;
			getline(ref_side, line);
			cout << "# Info: [verify] " << line << endl;
		}

		setnewline(ref_side, ss) >> name;
		if(name == "SEQ")
		{
			int vw, vh, frc, iqm, nqm;
			setnewline(ref_side, ss) >> vw;
			setnewline(ref_side, ss) >> vh;
			setnewline(ref_side, ss) >> frc;
			setnewline(ref_side, ss) >> iqm;
			if(iqm)
			{
				// not implemented
				cout << "# Error: [verify] This test is not support custom quant matrix" << endl;
				return 1;
			}
			setnewline(ref_side, ss) >> nqm;
			if(nqm)
			{
				// not implemented
				cout << "# Error: [verify] This test is not support custom quant matrix" << endl;
				return 1;
			}

			wait_events();
			if(!qm_valid.val())
			{
				cout << "# Error: [verify] qm_valid (for intra) expected!" << endl;
				return 1;
			}

			wait_events();
			if(!qm_valid.val())
			{
				cout << "# Error: [verify] qm_valid (for non-intra) expected!" << endl;
				return 1;
			}

			wait_events();
			if(!irq_change.val() || !irq_value.val())
			{
				cout << "# Error: [verify] irq expected!" << endl;
				return 1;
			}

			for(int wait = 20; wait > 0; --wait) posedge_clk();
			control_read();
			control_write(M2VDEC_STATUS_REG, M1VDEC_STATUS_IRQ_SEQ_MSK);
		}
	}

	return 0;
}

DPI_LINK_DECL int verify_video(svLogic* finished)
{
	return verify_video(svUnsigned<1>::cast(finished));
}

