//================================================================================
// C++ helper for DPI-C
//================================================================================

#ifndef _DPIC_HELPER_HPP_
#define _DPIC_HELPER_HPP_

#include <svdpi.h>
#include <iostream>
#include <string>
#include <sstream>

//--------------------------------------------------------------------------------
// Sign bit extender
//
template <int W, typename T>
struct _svSignExtender
{
	static T extend(uint32_t v) { return v; }
};

template <int W>
struct _svSignExtender<W, int32_t>
{
	static int32_t extend(uint32_t v) { return (0 - (v & (1 << (W - 1)))) | v; }
};

//--------------------------------------------------------------------------------
// svLogicVecVal(bus signals) wrapeer
//
template <int W, typename T>
struct _svLogicVecValWrapper
{
	typedef uint32_t U;
	typedef _svLogicVecValWrapper<W, T> S;
	typedef svLogicVecVal L;
	U mask() const { return (W == 32) ? ~0 : ((1 << (W & 31)) - 1); }
	U aval() const { return _v.aval & mask(); }
	U bval() const { return _v.bval & mask(); }
	T val() const { return _svSignExtender<W, T>::extend(aval()); }
	bool has_z() const { return (~aval() & bval()) != 0; }
	bool has_x() const { return (aval() & bval()) != 0; }
	bool has_zx() const { return bval() != 0; }
	const L* logic() const { return &_v; }
	L* plogic() { return &_v; }
	S& set_z() { _v.aval = 0; _v.bval = mask(); return *this; }
	S& set_x() { _v.aval = _v.bval = mask(); return *this; }
	std::string bin() const
	{
		std::stringstream ss;
		ss << W << "'b";
		for(int i = (W - 1); i >= 0; --i)
			ss << ((_v.bval & (1U << i)) ?
				("z\000x" + (((_v.aval >> i) & 1)) * 2) :
				("0\0001" + (((_v.aval >> i) & 1)) * 2));
		return ss.str();
	}
protected:
	void let(T v) { _v.aval = v & mask(); _v.bval = 0; }
	_svLogicVecValWrapper() { _v.aval = 0; _v.bval = mask(); }
	_svLogicVecValWrapper(const L& v) : _v(v) {}
	L _v;
};

//--------------------------------------------------------------------------------
// svLogic(single signal) wrapeer
//
template <typename T>
struct _svLogicWrapper
{
	typedef uint32_t U;
	typedef _svLogicWrapper<T> S;
	typedef svLogic L;
	U mask() const { return 1; }
	U aval() const { return _v & mask(); }
	U bval() const { return (_v >> 1) & mask(); }
	T val() const { return _svSignExtender<1, T>::extend(aval()); }
	bool has_z() const { return (~aval() & bval()) != 0; }
	bool has_x() const { return (aval() & bval()) != 0; }
	bool has_zx() const { return bval() != 0; }
	const L logic() const { return _v; }
	L* plogic() { return &_v; }
	S& set_z() { _v = sv_z; return *this; }
	S& set_x() { _v = sv_x; return *this; }
	std::string bin() const { return "1'b0\0001'b1\0001'bz\0001'bx" + (5 * _v); }
protected:
	void let(T v) { _v = v & 1; }
	_svLogicWrapper() { _v = sv_z; }
	_svLogicWrapper(const L& v) : _v(v) {}
	L _v;
};

//--------------------------------------------------------------------------------
// Wrapped logic value classes
//
template <int W>
struct svUnsigned : _svLogicVecValWrapper<W, uint32_t>
{
	typedef uint32_t word_t;
	typedef _svLogicVecValWrapper<W, word_t> super_t;
	typedef svUnsigned<W> self_t;
	self_t& operator =(word_t v)
		{ super_t::let(v); return *this; }
	friend std::istream& operator >>(std::istream& is, self_t& self)
		{ word_t v; is >> v; self.let(v); return is; }
	friend std::ostream& operator <<(std::ostream& os, const self_t& self)
		{ return (os << self.val()); }
	explicit svUnsigned(const typename super_t::L& v) : super_t(v) {}
	svUnsigned() {}
};

template <>
struct svUnsigned<1> : _svLogicWrapper<uint32_t>
{
	typedef uint32_t word_t;
	typedef _svLogicWrapper<word_t> super_t;
	typedef svUnsigned<1> self_t;
	self_t& operator =(word_t v) { let(v); return *this; }
	friend std::istream& operator >>(std::istream& is, self_t& self)
		{ word_t v; is >> v; self.let(v); return is; }
	friend std::ostream& operator <<(std::ostream& os, const self_t& self)
		{ return (os << self.val()); }
	explicit svUnsigned(const typename super_t::L& v) : super_t(v) {}
	svUnsigned() {}
};

typedef svUnsigned<32> svUInt;

template <int W>
struct svSigned : _svLogicVecValWrapper<W, int32_t>
{
	typedef int32_t word_t;
	typedef _svLogicVecValWrapper<W, word_t> super_t;
	typedef svSigned<W> self_t;
	self_t& operator =(word_t v)
		{ super_t::let(v); return *this; }
	friend std::istream& operator >>(std::istream& is, self_t& self)
		{ word_t v; is >> v; self.let(v); return is; }
	friend std::ostream& operator <<(std::ostream& os, const self_t& self)
		{ return self.has_zx() ? (os << self.bin()) : (os << self.val()); }
	explicit svSigned(const typename super_t::L& v) : super_t(v) {}
	svSigned() {}
};

template <>
struct svSigned<1> : _svLogicWrapper<int32_t>
{
	typedef int32_t word_t;
	typedef _svLogicWrapper<word_t> super_t;
	typedef svSigned<1> self_t;
	self_t& operator =(word_t v) { let(v); return *this; }
	friend std::istream& operator >>(std::istream& is, self_t& self)
		{ word_t v; is >> v; self.let(v); return is; }
	friend std::ostream& operator <<(std::ostream& os, const self_t& self)
		{ return self.has_zx() ? (os << self.bin()) : (os << self.val()); }
	explicit svSigned(const typename super_t::L& v) : super_t(v) {}
	svSigned() {}
};

typedef svSigned<32> svInt;

#endif	/* !_DPIC_HELPER_HPP_ */

