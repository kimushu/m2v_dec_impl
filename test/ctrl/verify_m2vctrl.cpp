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
using namespace std;

static ifstream ref_rl;

DPI_LINK_DECL int init_verify(const char* ref_dir)
{
	if(!open_refdata(ref_rl, ref_dir, "rl.txt"))
		return 1;

	return 0;
}

static int verify_video(svUnsigned<1>& finished)
{
	finished = 0;
}

DPI_LINK_DECL int verify_video(svLogic* finished)
{
	return verify_video(svUnsigned<1>::cast(finished));
}

