//================================================================================
// C++ helper for DPI-C
//================================================================================

#ifndef _DPIC_HELPER_HPP_
#define _DPIC_HELPER_HPP_

#include <svdpi.h>
#include <iostream>

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
	T aval() const { return _svSignExtender<W, T>::extend(_v.aval & mask()); }
	U bval() const { return _v.bval & mask(); }
	bool has_z() const { return (~aval() & bval()) != 0; }
	bool has_x() const { return (aval() & bval()) != 0; }
	bool has_zx() const { return bval() != 0; }
	operator T() const { return aval() & ~bval(); }
	operator const L*() const { return &_v; }
	operator L*() { return &_v; }
	const L& logic() const { return &_v; }
	L& logic() { return &_v; }
	S& set_z() { _v.aval = 0; _v.bval = mask(); return *this; }
	S& set_x() { _v.aval = _v.bval = mask(); return *this; }
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
	T aval() const { return _svSignExtender<1, T>::extend(_v & 1); }
	U bval() const { return (_v >> 1) & 1; }
	bool has_z() const { return (~aval() & bval()) != 0; }
	bool has_x() const { return (aval() & bval()) != 0; }
	bool has_zx() const { return bval() != 0; }
	operator T() const { return aval() & ~bval(); }
	operator const L*() const { return &_v; }
	operator L*() { return &_v; }
	const L& logic() const { return _v; }
	S& set_z() { _v = sv_z; return *this; }
	S& set_x() { _v = sv_x; return *this; }
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
		{ return (os << (word_t)self); }
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
		{ return (os << (word_t)self); }
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
		{ return (os << (word_t)self); }
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
		{ return (os << (word_t)self); }
	explicit svSigned(const typename super_t::L& v) : super_t(v) {}
	svSigned() {}
};

typedef svSigned<32> svInt;

#endif	/* !_DPIC_HELPER_HPP_ */

