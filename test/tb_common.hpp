//================================================================================
// Common definitions for testbench
//================================================================================

#ifndef _TB_COMMON_HPP_
#define _TB_COMMON_HPP_

#include <iostream>
#include <fstream>
#include <sstream>

inline std::stringstream& setnewline(std::stringstream& ss, std::istream& is)
{
	std::string line;
	do { std::getline(is, line); } while(line[0] == '#');
	ss.str(line);
	ss.clear();
	return ss;
}

inline bool open_refdata(std::ifstream& is, const char* ref_dir, const char* file_name)
{
	using namespace std;
	string path(string(ref_dir) + "/" + file_name);
	is.open(path.c_str());
	if(!is)
	{
		cout << "# Error: Cannot open `" << path << "' for reading!" << endl;
		return false;
	}

	return true;
}

#endif	/* !_TB_COMMON_HPP_ */

