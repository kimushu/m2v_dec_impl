#!/usr/bin/env ruby
#================================================================================
# デコードプロセッサテキスト(コード領域)生成スクリプト
# $Id$
#================================================================================

VERILOG_SOURCE = ["m2vsdp.v", "m2vctrl.v"]
module Assembler # {{{
	def self.load_verilog_constants(file)
		open(file).each_line {|line|
			next if !(line =~
				/^\s*([A-Z][A-Z0-9_]+)\s*=\s*([^,;]+)\s*[,;]?\s*$/)
			n,v = [$1, $2]
			v.gsub!(/\b(\d+)'b([01z_]+)\b/i) { "0b#{$2.gsub(/z/, '0')}" }
			v.gsub!(/\b(\d+)'d([0-9]+)\b/i) { $2 }
			v.gsub!(/\b(\d+)'h([0-9a-fz_]+)\b/i) { "0x#{$2.gsub(/z/, '0')}"}
			eval("#{n} = #{v}")
		}
	end

	#------------------------------------------------------------
	# Verilog ソースから定数を取得
	#
	VERILOG_SOURCE.each {|f| load_verilog_constants(f) }
	# INST_WIDTH = DATA_WIDTH + G_WIDTH
	REGISTERS = (0...(1<<RSEL_WIDTH)).map {|n| eval("R#{n} = :r#{n}") }

	#------------------------------------------------------------
	# 定数値チェック
	#
	raise "DATA_WIDTH is too small" if
		DATA_WIDTH < (CSEL_WIDTH + RSEL_WIDTH + 1 + IMED_WIDTH)

	#------------------------------------------------------------
	# 補助メソッド
	#
	def _reg2rn(r)
		f = REGISTERS.index(r)
		raise "`#{r}' is not a valid register" if !f
		f
	end

	def _ks2ku(v, b = IMED_WIDTH)
		b -= 1
		raise "`#{r}' is out of range" if v < -(1 << b) or v >= (2 << b)
		v += (2 << b) if v < 0
		v
	end

	def _line(level)
		r = 0
		c = caller(level + 1).map {|v| v.split(":") }
		c.each {|v|
			break if v[0] != c[0][0]
			break if v[2] and v[2] =~ /`(?:each|times)'/
			r = v[1].to_i
		}
		r
	end

	def _ins(c, sc, rd, rsk, mnemonic)
		rd = _reg2rn(rd)
		code = "%0*b%0*b" % [G_WIDTH, c, SC_WIDTH, sc]
		code += "%0*b" % [INST_WIDTH-G_WIDTH-SC_WIDTH-1-IMED_WIDTH, rd]
		disasm = "#{mnemonic}R#{rd}, "
		if(rsk.is_a?(Integer))
			code += "1%0*b" % [IMED_WIDTH, rsk]
			disasm += "0x%0*x" % [(IMED_WIDTH+3)/4, rsk]
		else
			rsk = _reg2rn(rsk)
			code += "0%0*b" % [IMED_WIDTH, rsk]
			disasm += "R#{rsk}"
		end
		$codes << [code, nil, disasm, _line(2)]
	end

	def _uni(c, sc, ssc, rd, mnemonic)
		rd = _reg2rn(rd)
		code = "%0*b%0*b" % [G_WIDTH, c, SC_WIDTH, sc]
		code += "%0*b" % [INST_WIDTH-G_WIDTH-SC_WIDTH-1-IMED_WIDTH, rd]
		code += "%0*b%0*b" % [SSC_WIDTH, ssc, (IMED_WIDTH+1-SSC_WIDTH), 0]
		disasm = "#{mnemonic}R#{rd}"
		$codes << [code, nil, disasm, _line(2)]
	end

	def _jmp(label, jc, m)
		if(label.is_a?(Integer) and label != 0)
			a = label.abs
			$nlabels[a] ||= 0
			label = "_nlabel_#{a}_#{$nlabels[a]-(label > 0 ? 0 : 1)}".intern
		end
		raise "`#{label}' is not a valid label" if !label.is_a?(Symbol)
		$codes << [
			"%0*b%0*b%%0%db" % [G_WIDTH, G_JUMPS, SC_WIDTH, jc,
				(INST_WIDTH-G_WIDTH-SC_WIDTH)],
			label,
			"#{m}:#{label}",
			_line(2)
		]
	end

	#------------------------------------------------------------
	# 命令定義
	#
	def mov(dest, src)
		if(dest == REGISTERS.first and src.is_a?(Integer))
			src = _ks2ku(src, DATA_WIDTH)
			$codes << [
				"%0*b%0*b" % [G_WIDTH, G_MOVR0, DATA_WIDTH, src],
				nil,
				"mov\tR0, 0x%0*x" % [(DATA_WIDTH + 3) / 4, src],
				_line(1)
			]
		else
			_ins(G_OTHERS, SC_MOV, dest, src, "mov\t")
		end
	end

	def nop()
		mov(REGISTERS.first, REGISTERS.first)
	end

	def add(dest, src)
		_ins(G_OTHERS, SC_ADD, dest, src, "add\t")
	end

	def cmp(dest, src)
		_ins(G_OTHERS, SC_CMP, dest, src, "cmp\t")
	end

	def sub(dest, src)
		_ins(G_OTHERS, SC_SUB, dest, src, "sub\t")
	end

	def tst(dest, src)
		_ins(G_OTHERS, SC_TST, dest, src, "tst\t")
	end

	def and_(dest, src)
		_ins(G_OTHERS, SC_AND, dest, src, "and_\t")
	end

	def or_(dest, src)
		_ins(G_OTHERS, SC_OR, dest, src, "or_\t")
	end

	def not_(dest)
		_uni(G_OTHERS, SC_UNI, SSC_NOT, dest, "not\t")
	end

	def lsr(dest)
		_uni(G_OTHERS, SC_UNI, SSC_LSR, dest, "lsr\t")
	end

	def lsl(dest)
		_uni(G_OTHERS, SC_UNI, SSC_LSL, dest, "lsl\t")
	end

	def ror(dest)
		_uni(G_OTHERS, SC_UNI, SSC_ROR, dest, "ror\t")
	end

	def rol(dest)
		_uni(G_OTHERS, SC_UNI, SSC_ROL, dest, "rol\t")
	end

	def custom(num, dest, src)
		raise "`#{num}' is out of range" if
			!num.is_a?(Integer) or num < 0 or num >= (1 << CSEL_WIDTH)
		_ins(G_CUSTOM, num, dest, src, "custom\t#{num}, ")
	end

	def jmp(label)
		_jmp(label, JC_JMP, "jmp\t")
	end

	def jz(label)
		_jmp(label, JC_JZ, "jz\t")
	end

	def jnz(label)
		_jmp(label, JC_JNZ, "jnz\t")
	end

	def je(label)
		_jmp(label, JC_JZ, "je\t")
	end

	def jne(label)
		_jmp(label, JC_JNZ, "jne\t")
	end

	def jc(label)
		_jmp(label, JC_JC, "jc\t")
	end

	def jnc(label)
		_jmp(label, JC_JNC, "jnc\t")
	end

	#------------------------------------------------------------
	# ディレクティブ定義
	#
	def label(label)
		if(label.is_a?(Integer) and label > 0)
			$nlabels[label] ||= 0
			$nlabels[label] += 1
			label = "_nlabel_#{label}_#{$nlabels[label]-1}".intern
		end
		raise "`#{label}' is not a valid label" if !label.is_a?(Symbol)
		raise "Multiple labels `:#{label}'" if $labels[label]
		caller.first =~ /^.+?:(\d+)/
		lineno = $1.to_i
		$labels[label] = {:addr => $codes.size, :used => 0, :lineno => lineno}
	end

	#------------------------------------------------------------
	# コード生成部
	#
	END {
		STDERR.puts(<<EOD)
#------------------------------------------------------------
# This file was generated by #$0
# #{Time.now}
# vim: ts=8:
#------------------------------------------------------------

EOD
		out = Array.new(1 << IADR_WIDTH) { "0"*INST_WIDTH }
		raise "code size (#{$codes.size} words) exceeds memory!" if $codes.size > out.size
		$codes.each_index {|i|
			s = $codes[i]
			if(s[1])
				l = $labels[s[1]]
				raise "label `#{s[1]}' is not found! (at 0x%0*x)" %
					[(IADR_WIDTH+3)/4, i] if !l
				l[:used] += 1
				s[0] = s[0] % l[:addr]
			end
			if(defined?(DEBUG_LINE_NUMBERS) and DEBUG_LINE_NUMBERS)
				out[i] = "%0*b" % [INST_WIDTH, s[3]]
			else
				out[i] = s[0].gsub(/_/, '').gsub(/x/, '0')
			end
			$labels.each {|k,v|
				next if v[:addr] != i
					STDERR.puts("%*slabel :#{k}\t# Line %d" % [(IADR_WIDTH+3)/4+5, "", v[:lineno]])
			}
			STDERR.puts("[0x%0*x] \t#{s[2]}" % [(IADR_WIDTH+3)/4, i])
		}
		$labels.each {|k,v|
			STDERR.puts("# Warning: label `#{k}' never used") if v[:used] == 0
		}

		puts(<<EOD)
DEPTH = #{out.size};
WIDTH = #{INST_WIDTH};
ADDRESS_RADIX = HEX;
DATA_RADIX = BIN;
CONTENT
BEGIN
EOD
		out.each_index {|i| puts("%0*X : %s;" % [(INST_WIDTH+3)/4, i, out[i]]) }
		puts("END;")
	}

	$labels = {}
	$nlabels = {}
	$codes = []
end
include Assembler
# }}}

#--------------------------------------------------------------------------------
# 定数 {{{
#
PICTURE_START_CODE = 0x00000100
UDATA_START_CODE   = 0x000001b2
SEQ_HEADER_CODE    = 0x000001b3
SEQ_ERROR_CODE     = 0x000001b4
EXT_START_CODE     = 0x000001b5
SEQ_END_CODE       = 0x000001b7
GROUP_START_CODE   = 0x000001b8

SEQ_EXT_ID      = 0b0001
PIC_CODE_EXT_ID = 0b1000

R_MVECTOR = {:H => R3, :V => R4}
R_DCPRED = {:Y => R5, :U => R6, :V => R7}

R_MBINFO  = R2
B_MBINTRA = 4
B_MBCODED = 5
B_MBMO_FW = 6
B_MBQUANT = 7
B_MBTEMP  = 8

R_PICT    = R5
B_IDCPREC = 11
B_IFRAME  = 13
B_CONMV   = 14
B_IVLCFMT = 15

R_FCODE   = {:H => R6, :V => R7}
B_FCODE   = 12

TABLE_B1  = 0
TABLE_B10 = 1
TABLE_B12 = 2
TABLE_B13 = 3
TABLE_B3  = 4
TABLE_B9  = 5
TABLE_B14 = 6
TABLE_B15 = 7
# }}}

#--------------------------------------------------------------------------------
# カスタム命令定義 {{{
#
def align(temp)
	custom	1, temp, (1 << 5)
end

def rdbuf(dest, bits)
	if(bits.is_a?(Integer))
		bits = (bits > 0) ? (bits | (1 << 4)) : bits.abs
	end
	or_		bits, (1 << 4)		if !bits.is_a?(Integer)
	custom	1, dest, bits
	and_	bits, 15			if !bits.is_a?(Integer)
end

def vld(dest, table)
	custom	2, dest, table | (1 << 5)
end

def vldtbl(dest, table)
	custom	2, dest, table
end

def inout(reg, select)
	custom	4, reg, select
end

def rlpair(run, level)
	custom	0, level, run
end
# }}}

#--------------------------------------------------------------------------------
# マクロ定義 {{{
#
def nhead(skip_1st = false, temp = R0)
	align	temp
	jmp		+20			if skip_1st
label 10
	rdbuf	temp, 8
	cmp		temp, 0x00
	jnz		-10
label 20				if skip_1st
	rdbuf	temp, 8
	cmp		temp, 0x00
	jnz		-10
label 30
	rdbuf	temp, 8
	cmp		temp, 0x01
	jc		-30
	jnz		-10
end

def skip(bits, temp = R0)
	while(bits > 0)
		len = [bits, 12].min
		rdbuf	temp, len
		bits -= len
	end
end

def marker(label, temp = R0)
	rdbuf	temp, 1
	cmp		temp, 1
	jnz		label
end

def rstdcp()
	mov		R0, 0b1111_1000_0000_0000
[:Y, :U, :V].each {|c|
	and_	R_DCPRED[c], R0
}
	mov		R0, (2 << B_IDCPREC)
	tst		R_PICT, R0
	jnz		+10
	lsr		R0
	tst		R_PICT, R0
	jnz		+20
	mov		R0, (1 << 7)	# intra_dc_precision=0
	jmp		+30
label 20
	mov		R0, (1 << 8)	# intra_dc_precision=1
	jmp		+30
label 10
	lsr		R0
	tst		R_PICT, 0
	jnz		+20
	mov		R0, (1 << 9)	# intra_dc_precision=2
	jmp		+30
label 20
	mov		R0, (1 << 10)	# intra_dc_precision=3
label 30
[:Y, :U, :V].each {|c|
	or_		R_DCPRED[c], R0
}
end

def rstpmv()
	mov		R_MVECTOR[:H], 0
	mov		R_MVECTOR[:V], 0
end
# }}}

#--------------------------------------------------------------------------------
# コード本体
#
label :RESET
label :FIND_SEQ_HEADER
	#------------------------------------------------------------
	# Sequence header
	#
	nhead
	rdbuf	R1, 8
label :SEQ_HEADER
	cmp		R1, (SEQ_HEADER_CODE & 0xff)
	jne		:FIND_SEQ_HEADER
	rdbuf	R1, 12			# {video_width}
	mov		R0, (1 << VI_WIDTH)
	or_		R0, R1
	inout	R0, IO_VIDEOINFO
	add		R1, 15
4.times {
	lsr		R1
}
	rdbuf	R2, 12			# {video_height}
	mov		R0, (1 << VI_HEIGHT)
	or_		R0, R2
	inout	R0, IO_VIDEOINFO
	add		R2, 15
	mov		R0, 0xfff0
	and_	R2, R0
(8-4).times {
	lsl		R2
}
	or_		R1, R2
	inout	R1, IO_MAX_MBXY
	rdbuf	R1, 8			# {aspect,frate}
	mov		R0, (1 << VI_FRATE)
	or_		R1, R0
	inout	R1, IO_VIDEOINFO
	skip	18				# {bitrate_value}
	marker	:FIND_SEQ_HEADER
	skip	10+1			# {vbv_buf_size, const_param_flag}
	rdbuf	R0, 1
	cmp		R0, 0
	je		:DEF_INTRA_QMAT
	mov		R0, (1 << QM_CUSTOM) | (1 << QM_INTRA)
	inout	R0, IO_QMATRIX
	mov		R1, 64
label :CUST_INTRA_QMAT
	rdbuf	R0, 8
	or_		R0, (1 << QM_INTRA)
	inout	R0, IO_QMATRIX	# 64*{value_of_custom_qmat_intra}
	sub		R1, 1
	jnz		:CUST_INTRA_QMAT
	jmp		:CHECK_NONINTRA_QMAT
label :DEF_INTRA_QMAT
	mov		R0, (0 << QM_CUSTOM) | (1 << QM_INTRA)
	inout	R0, IO_QMATRIX
label :CHECK_NONINTRA_QMAT
	rdbuf	R0, 1
	cmp		R0, 0
	je		:DEF_NONINTRA_QMAT
	mov		R0, (1 << QM_CUSTOM) | (0 << QM_INTRA)
	inout	R0, IO_QMATRIX
	mov		R1, 64
label :CUST_NONINTRA_QMAT
	rdbuf	R0, 8
	inout	R0, IO_QMATRIX	# 64*{value_of_custom_qmat_nonintra}
	sub		R1, 1
	jnz		:CUST_NONINTRA_QMAT
	jmp		:SEQ_HEADER_FINISH
label :DEF_NONINTRA_QMAT
	mov		R0, (0 << QM_CUSTOM) | (0 << QM_INTRA)
	inout	R0, IO_QMATRIX
label :SEQ_HEADER_FINISH
	mov		R0, (1 << CN_IRQ_SEQ)
	inout	R0, IO_CONTROL

	#------------------------------------------------------------
	# Sequence extension
	#
	nhead
	rdbuf	R1, 12
	mov		R0, ((EXT_START_CODE & 0xff) << 4) + SEQ_EXT_ID
	cmp		R1, R0
	jne		:ERROR
	skip	8				# {prof_and_level}
	rdbuf	R0, 7			# {prog_seq=1,chroma_format=01,
							#  video_wd_ext=00,video_ht_ext=00}
	cmp		R0, 0b1010000
	jne		:ERROR
	skip	12+8+1+7		# {bitrate_ext, vbv_buf_size_ext
							#  low_delay, frate_ext}

	#------------------------------------------------------------
	# Other extension / User data / GOP header (skips)
	#
label :SKIP_USER_DATA
	nhead
	rdbuf	R0, 8
	cmp		R0, (EXT_START_CODE & 0xff)
	je		:SKIP_USER_DATA
	cmp		R0, (UDATA_START_CODE & 0xff)
	je		:SKIP_USER_DATA
	cmp		R0, (GROUP_START_CODE & 0xff)
	je		:SKIP_USER_DATA

	#------------------------------------------------------------
	# Picture header
	#
	cmp		R0, (PICTURE_START_CODE & 0xff)
	jne		:ERROR
label :PICTURE_HEADER
	skip	10				# {temp_ref}
	rdbuf	R_PICT, 11		# {pic_coding_type,vbv_delay<15:8>}
	and_	R_PICT, (1 << 8)
(B_IFRAME-8).times {
	lsl		R_PICT
}
	rdbuf	R0, 8			# {vbv_delay<7:0>}
	mov		R0, (1 << B_IFRAME)
	tst		R_PICT, R0
	jnz		+1
	rdbuf	R0, 4
	cmp		R0, 0b0111
	jne		:ERROR
label 1
	rdbuf	R0, 1
	tst		R0, 1
	jz		+1
	rdbuf	R0, 8
	jmp		-1
label 1
	align	R0

	#------------------------------------------------------------
	# Picture coding extension
	#
	rdbuf	R0, 12
	cmp		R0, 0
	jne		:ERROR
	rdbuf	R0, 12
	cmp		R0, 1
	jne		:ERROR
	rdbuf	R1, 12
	mov		R0, ((EXT_START_CODE & 0xff) << 4) + PIC_CODE_EXT_ID
	cmp		R1, R0
	jne		:ERROR
	rdbuf	R_FCODE[:H], 12	# {f_code[0][0],f_code[0][1],f_code[1][0]}
4.times {
	lsl		R_FCODE[:H]
}
	mov		R_FCODE[:V], R_FCODE[:H]
4.times {
	lsl		R_FCODE[:V]
}
	skip	4				# {f_code[1][1]}
	rdbuf	R1, 2+2+1+1+1+1+1+1+1+1+1
							# {intra_dc_precision(12:11),picture_struct(10:9),
							#  top_field_first,frame_pred_frame_dct,
							#  conceal_mv(6),q_scale_type(5),
							#  intra_vlc_fmt(4),alt_scan,
							#  rep_first_field,chroma_420_type,prog_frame}
	mov		R2, R1
6.times {					# bring dcprec to lsb
	rol		R1
}
	tst		R2, (1 << 3)	# q_scale_type
	jz		+1
	or_		R1, (1 << 2)
label 1
	mov		R0, (1 << B_IFRAME)
	tst		R_PICT, R0
	jz		+1
	or_		R1, (1 << 3)
label 1
	inout	R1, IO_S0PICT
	mov		R1, R2
(B_IDCPREC-11).times {
	lsl		R1
}
(11-B_IDCPREC).times {
	lsr		R1
}
	mov		R0, (3 << B_IDCPREC)
	and_	R1, R0
	or_		R_PICT, R1
	tst		R2, (1 << 6)	# conceal_mv
	jz		+1
	mov		R0, (1 << B_CONMV)
	or_		R_PICT, R0
label 1
	tst		R2, (1 << 4)	# intra_vlc_fmt
	jz		+1
	mov		R0, (1 << B_IVLCFMT)
	or_		R_PICT, R0
label 1
	rdbuf	R0, 1
	cmp		R0, 0
	je		+1
	skip	1+3+1+7+8
label 1

	#------------------------------------------------------------
	# Other extension / User data (skips)
	#
label :SKIP_USER_DATA2
	nhead
	rdbuf	R0, 8
	cmp		R0, (EXT_START_CODE & 0xff)
	je		:SKIP_USER_DATA2
	cmp		R0, (UDATA_START_CODE & 0xff)
	je		:SKIP_USER_DATA2

	#------------------------------------------------------------
	# Picture data (Slices)
	#
label :SLICE_START
	# save next code (maybe one of GROUP_START_CODE, PICTURE_START_CODE or SEQ_HEADER_CODE)
	mov		R2, R0		# R2 can be used at this point
	sub		R0, 1
	jc		:PICTURE_END
	cmp		R0, 0xaf
	jnc		:PICTURE_END
	sub		R0, 1
	inout	R0, IO_SLICEVERT	# {slice_vert_position-1}
	rdbuf	R0, 5
	or_		R0, (1 << QC_SLICE)
	inout	R0, IO_QSCODE		# {q_scale_code}
	rdbuf	R0, 1
	cmp		R0, 1
	jne		+1
label 2
	rdbuf	R0, 9
	tst		R0, 1
	jnz		-2
label 1
	rstdcp
	rstpmv
	jmp		:MB_START

	#------------------------------------------------------------
	# Macroblock
	#
label :MB_ADDR
	inout	R0, IO_MB_ADDR
	tst		R0, 1
	jnz		:MB_ADDR
label :MB_START
	vld		R0, TABLE_B1
	mov		R1, R0
	inout	R0, IO_MB_ADDR
	tst		R1, 64
	jnz		:MB_ADDR	# escape
	tst		R1, 128
	jnz		:MB_END
	cmp		R1, 1
	je		+1
	rstdcp
	mov		R0, (1 << B_IFRAME)
	tst		R_PICT, R0
	jnz		:MB_I
	rstpmv
	jmp		:MB_P
label 1
	mov		R0, (1 << B_IFRAME)
	tst		R_PICT, R0
	jz		:MB_P
label :MB_I
	# I-frame (Table B2)
	#	        # QFPI
	#	[ "01", 0b10010000 ],
	#	[ "1",  0b00010000 ],
	mov		R_MBINFO, (1 << B_MBINTRA)
	rdbuf	R0, 1
	cmp		R0, 1
	je		+1
	rdbuf	R0, 1
	or_		R_MBINFO, (1 << B_MBQUANT)
	jmp		+1
label :MB_P
	# P-frame (Table B3)
	vld		R_MBINFO, TABLE_B3
label 1

	# Get qs_scale_code (if mb_quant)
	mov		R0, (1 << QC_COPY)
	tst		R_MBINFO, (1 << B_MBQUANT)
	jz		+1
	rdbuf	R0,	5		# {mb_q_scale_code}
label 1
	inout	R0, IO_QSCODE

	# Does MB have MVs?
	mov		R1, R_MBINFO
	mov		R0, (1 << B_CONMV)
	tst		R_PICT, R0
	jnz		+1
	and_	R1, (1 << B_MBMO_FW)	# !conceal_mv
label 1
	tst		R1, (1 << B_MBMO_FW) | (1 << B_MBINTRA)
	jz		:MB_NO_MV

	# MB has motion vectors
[:H, :V].each {|d|
	vld		R1, TABLE_B10
	cmp		R1, (1 << 5)
	je		+10		# code==0 && residual==0 (no mv change)
	mov		R0, R_FCODE[d]
5.times {
	rol		R0
}
	and_	R0, 15
	sub		R0, 1
	jc		:ERROR
	cmp		R0, 14
	je		+10		# (no mv change)
	or_		R_MBINFO, R0
	cmp		R0, 0
	je		+11		# code!=0 && (f_code-1)==0
	and_	R_MBINFO, (1 << B_MBTEMP) - 1
	tst		R1, (1 << 4)
	jz		+1
	or_		R_MBINFO, (1 << B_MBTEMP)
label 1
	and_	R1, 15
label 1
	lsl		R1		# code <<= 1
	sub		R0, 1
	jnz		-1
	mov		R0, R_MBINFO
	and_	R0, 15
	rdbuf	R0, R0	# residual
	add		R0, R1
	add		R0, 1
	tst		R_MBINFO, (1 << B_MBTEMP)
	jz		+1
	not_	R0
	add		R0, 1
	jmp		+1
label 11
	mov		R0, R1
	add		R0, 1
	tst		R0, (1 << 4)
	jz		+1
	and_	R0, 15
	not_	R0
	add		R0, 1
label 1
	add		R_MVECTOR[d], R0
	# MV range check
	mov		R1, 16
	mov		R0, R_MBINFO
	and_	R0, 15
	jz		+2
label 1
	lsl		R1
	sub		R0, 1
	jnz		-1
label 2
	# R1:high
	cmp		R_MVECTOR[d], R1
	jc		+1
	# MV >= high
2.times {
	sub		R_MVECTOR[d], R1
}
	jmp		+10
label 1
	mov		R0, 0x8000
	tst		R_MVECTOR[d], R0
	jz		+10
	# MV < 0
	mov		R0, R1
	not_	R0
	add		R0, 1
	cmp		R_MVECTOR[d], R0
	jnc		+10
	# MV < low
2.times {
	add		R_MVECTOR[d], R1
}
label 10
}
	jmp		:MB_PAT
label :MB_NO_MV
	tst		R_MBINFO, (1 << B_MBINTRA)
	jz		+1
	# if(mb_intra)
	mov		R0, (1 << B_CONMV)
	tst		R_PICT, R0
	jz		+2
	marker	:ERROR
	jmp		:MB_PAT
label 1
	# if(!mb_intra)
	tst		R_MBINFO, (1 << B_MBMO_FW)
	jnz		:MB_PAT
	mov		R0, (1 << B_IFRAME)
	tst		R_PICT, R0
	jnz		:MB_PAT
label 2
	rstpmv
label :MB_PAT
	# Get mb_pattern
	mov		R1, 0b1111111
	tst		R_MBINFO, (1 << B_MBINTRA)
	jnz		+1
	rstdcp
	mov		R1, 0b0000000
label 1
	tst		R_MBINFO, (1 << B_MBCODED)
	jz		+1
	vld		R0, TABLE_B9
	or_		R1, R0
label 1
	inout	R1, IO_S0VALID

	# Process blocks (Y*4,U,V)
[:Y, :U, :V].each {|c|
label 19							if c == :Y
	mov		R0, (1 << CN_BLK_START)
	inout	R0, IO_CONTROL
	mov		R0, 0
	inout	R0, IO_CONTROL
	tst		R0, (1 << RDY_S1PAT)
	jz		+13
	and_	R_MBINFO, 0b1111_0000
	tst		R_MBINFO, (1 << B_MBINTRA)
	jz		+10
	# First coefficient of intra
	vld		R0, (c == :Y) ? TABLE_B12 : TABLE_B13
	cmp		R0, 0
	jz		+1
	rdbuf	R1, R0
	sub		R0, 1
	or_		R_MBINFO, R0
	mov		R0, 1
	tst		R_MBINFO, 15
	jz		+2
label 3
	lsl		R0
	sub		R_MBINFO, 1
	tst		R_MBINFO, 15
	jnz		-3
label 2
	cmp		R1, R0
	jnc		+2
	add		R0, R0
	sub		R0, R1
	sub		R0, 1
	sub		R_DCPRED[c], R0
	jmp		+1
label 2
	add		R_DCPRED[c], R1
label 1
	mov		R1, R_DCPRED[c]
	mov		R0, (1 << 11) - 1
	and_	R1, R0
	mov		R0, 0
	rlpair	R0, R1
	mov		R0, (1 << B_IVLCFMT)
	tst		R_PICT, R0
	mov		R0, TABLE_B14
	jz		+1
	mov		R0, TABLE_B15
label 1
	vldtbl	R0, R0
	jmp		+11
label 10
	# non-intra first
	mov		R0, TABLE_B14
	vldtbl	R0, R0
	rdbuf	R1, -1
	cmp		R1, 1
	jne		+11
	rdbuf	R1, 2
	lsr		R1
	jnc		+1
	mov		R0, (1 << 11)
	or_		R1, R0
label 1
	mov		R0, 0
	rlpair	R0, R1
label 11
	# remainder coefficients
	mov		R0, (1 << CN_RLAUTO)
	inout	R0, IO_CONTROL
label 1
	mov		R0, 0
	inout	R0, IO_CONTROL
	tst		R0, (1 << RDY_ESCAPE)
	jnz		+2
	tst		R0, (1 << RDY_RLPAIR)
	jz		-1
	jmp		+12
label 2
	# escape RLpair
	rdbuf	R1, 6
	rdbuf	R0, 12
5.times {
	lsl		R0
}
	jnc		+1
	not_	R0
	sub		R0, -1		# add 1, with carry-set
	# add		R0, 1
	# cmp		R1, (1 << 6)	# set carry
label 1
5.times {
	ror		R0
}
	rlpair	R1, R0
	jmp		-11
label 12
	mov		R0, (1 << CN_BLK_END)
	inout	R0, IO_CONTROL
label 13
	mov		R1, 0
	inout	R1, IO_CONTROL
	and_	R1, (1 << RDY_ISDQ) | (1 << RDY_IDCT) | (1 << RDY_MC)
	cmp		R1, (1 << RDY_ISDQ) | (1 << RDY_IDCT) | (1 << RDY_MC)
	jnz		-13
	mov		R0, 0					if c == :Y
	inout	R0, IO_CONTROL			if c == :Y
	and_	R0, (3 << RDY_BLK0)		if c == :Y
	cmp		R0, (3 << RDY_BLK0)		if c == :Y
	jne		-19						if c == :Y
}
	jmp		:MB_START
label :MB_END
	nhead	true
	rdbuf	R0, 8
	jmp		:SLICE_START
label :PICTURE_END
3.times {
	# block_start(enable=0)
	mov		R0, (1 << CN_BLK_START)
	inout	R0, IO_CONTROL
	mov		R0, (1 << RDY_ISDQ) | (1 << RDY_IDCT) | (1 << RDY_MC)
label 1
	mov		R1, 0
	inout	R1, IO_CONTROL
	and_	R1, R0
	cmp		R1, R0
	jnz		-1
}
	# picture_complete & picture_irq
	mov		R0, (1 << CN_IRQ_PIC)
	mov		R1, R0
	inout	R0, IO_CONTROL
	mov		R0, (1 << RDY_FRAME)
label 1
	mov		R1, 0
	inout	R1, IO_CONTROL
	and_	R1, R0
	jz		-1
label :NEXT_PICTURE
	# restore next code
	mov		R0, R2
	cmp		R0, (GROUP_START_CODE & 0xff)
	je		:SKIP_USER_DATA
	cmp		R0, (PICTURE_START_CODE & 0xff)
	je		:PICTURE_HEADER
	jmp		:SEQ_HEADER
label :ERROR
	mov		R0, (1 << CN_ERROR)
	inout	R0, IO_CONTROL
label 1
	jmp		-1


# vim:set foldmethod=marker:
