//================================================================================
// MPEG2 Video Inverse Scanner & DeQuantizer
// Written by kimu_shu
//================================================================================

module m2visdq(
	// common
	input         clk,
	input         reset_n,
	input         softreset,

	// from m2vctrl
	output        ready_isdq,
	input         block_start,
	input         block_end,

	// from m2vside1
	input         s1_enable,
	input         s1_coded,
	input         s1_mb_intra,
	input   [4:0] s1_mb_qscode,
	input         sa_qstype,
	input   [1:0] sa_dcprec,

	// from m2vctrl
	input   [5:0] run,
	input         level_sign,
	input  [10:0] level_data,
	input         rl_valid,
	input         qm_valid,
	input         qm_custom,
	input         qm_intra,
	input   [7:0] qm_value,

	// to m2vidct
	output        coef_sign,
	output [11:0] coef_data,
	input         coef_next
);

parameter
	ST_CLEAR  = 0,
	ST_IDLE   = 1,
	ST_BLOCK  = 2,
	ST_LOADQM = 3;

reg   [1:0] state_r;		// 現在のステート
reg         cust_qm_ni_r;	// Non-intraでカスタムQMを利用するなら1
reg         cust_qm_i_r;	// IntraでカスタムQMを利用するなら1
reg   [6:0] qscale_r;		// 量子化スケール値
reg   [5:0] wpos_r;			// バッファ書き込み位置
reg   [5:0] rpos_r;			// バッファ読み込み位置
reg         wpage_r;		// バッファ書き込み側ページ
reg         empty_r;		// 読み込み側ページにデータが無いとき1
reg         cvalid_r;		// 読み込み側データ有効
reg         clrcoef_r;		// 係数クリアした次のサイクルで1
reg         mismatch_r;		// ミスマッチ補正計算用
reg         lastcoef_r;		// 最後の係数の次のサイクルで1

reg         start_blk_1d_r;	// ブロック開始信号の1遅延
reg         end_blk_r;		// ブロック終了信号の1遅延(ブロック無効で開始したときも1)
reg   [2:0] rlv_d_r;		// rl_validの1～3遅延
reg   [2:0] sign_d_r;		// rl_signの1～3遅延
reg         head_pair_r;	// 先頭要素(＝DC)で1
reg  [11:0] mult_cache_r;	// 乗算結果のキャッシュ(クリッピング用データ)
reg         ovf_r;			// オーバーフロー検知

wire        end_blkstate_w;
wire  [6:0] next_wpos_w;
wire  [6:0] next_rpos_w;
reg   [8:0] cmem_addr_w;
wire [15:0] cmem_dout_w;
wire [12:0] dmem_doutb_w;
reg   [3:0] dc_mult_w;
wire  [8:0] mult_a_w;
wire [19:0] mult_b_w;
wire [28:0] mult_result_w;
wire [11:0] clipped_w;

assign end_blkstate_w = (end_blk_r & ~(|rlv_d_r) & ~cvalid_r);
assign next_wpos_w = wpos_r + (rl_valid ? run : 6'd1);
assign next_rpos_w = rpos_r + 1'b1;

assign ready_isdq = (state_r == ST_IDLE);

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		state_r <= ST_CLEAR;
	else if(softreset)
		state_r <= ST_CLEAR;
	else case(state_r)
	ST_CLEAR:	state_r <= (wpage_r & next_rpos_w[6]) ? ST_IDLE : ST_CLEAR;
	ST_IDLE:	state_r <= block_start ? ST_BLOCK :
							(qm_valid & qm_custom) ? ST_LOADQM : ST_IDLE;
	ST_BLOCK:	state_r <= end_blkstate_w ? ST_IDLE : ST_BLOCK;
	ST_LOADQM:	state_r <= next_wpos_w[6] ? ST_IDLE : ST_LOADQM;
	endcase

`ifdef SIM	// For debugging {{{
reg [23:0] state_name;
always @(state_r)
	case(state_r)
	ST_CLEAR:	state_name = "Clr";
	ST_IDLE:	state_name = "Idl";
	ST_BLOCK:	state_name = "Blk";
	ST_LOADQM:	state_name = "LQm";
	default:	state_name = "---";
	endcase
`endif		// }}}

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		cust_qm_ni_r <= 1'b0;
	else if(softreset)
		cust_qm_ni_r <= 1'b0;
	else if(state_r == ST_IDLE && qm_valid && ~qm_intra)
		cust_qm_ni_r <= qm_custom;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		cust_qm_i_r <= 1'b0;
	else if(softreset)
		cust_qm_i_r <= 1'b0;
	else if(state_r == ST_IDLE && qm_valid && qm_intra)
		cust_qm_i_r <= qm_custom;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		qscale_r <= 7'd0;
	else if(softreset)
		qscale_r <= 7'd0;
	else if(start_blk_1d_r)
		qscale_r <= cmem_dout_w[14:8];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		wpos_r <= 6'd0;
	else if(softreset || state_r == ST_IDLE)
		wpos_r <= 6'd0;
	else if((state_r == ST_BLOCK && (rl_valid || rlv_d_r[0])) ||
			(state_r == ST_LOADQM && qm_valid))
		wpos_r <= next_wpos_w[5:0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		rpos_r <= 6'd0;
	else if(softreset || state_r == ST_IDLE)
		rpos_r <= 6'd0;
	else if(state_r == ST_CLEAR || (state_r == ST_BLOCK && cvalid_r && coef_next))
		rpos_r <= next_rpos_w[5:0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		wpage_r <= 1'b0;
	else if(softreset)
		wpage_r <= 1'b0;
	else if((state_r == ST_BLOCK && end_blkstate_w) ||
			(state_r == ST_CLEAR && next_rpos_w[6]))
		wpage_r <= ~wpage_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		empty_r <= 1'b1;
	else if(softreset)
		empty_r <= 1'b1;
	else if(block_start)
		empty_r <= ~(s1_enable & s1_coded);

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		cvalid_r <= 1'b0;
	else if(softreset || (next_rpos_w[6] && coef_next))
		cvalid_r <= 1'b0;
	else if(block_start)
		cvalid_r <= ~empty_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		clrcoef_r <= 1'b1;
	else if(softreset)
		clrcoef_r <= 1'b1;
	else
		clrcoef_r <= cvalid_r & coef_next;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		mismatch_r <= 1'b1;
	else if(softreset || state_r == ST_IDLE)
		mismatch_r <= 1'b1;
	else if(clrcoef_r && dmem_doutb_w[0])
		mismatch_r <= ~mismatch_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		lastcoef_r <= 1'b0;
	else if(softreset)
		lastcoef_r <= 1'b0;
	else
		lastcoef_r <= next_rpos_w[6];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		start_blk_1d_r <= 1'b0;
	else if(softreset)
		start_blk_1d_r <= 1'b0;
	else
		start_blk_1d_r <= block_start;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		end_blk_r <= 1'b0;
	else if(softreset)
		end_blk_r <= 1'b0;
	else if(block_end || (block_start & ~s1_enable) || (start_blk_1d_r & ~s1_coded))
		end_blk_r <= 1'b1;
	else if(state_r == ST_IDLE)
		end_blk_r <= 1'b0;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		rlv_d_r <= 3'b0;
	else if(softreset)
		rlv_d_r <= 3'b0;
	else
		rlv_d_r <= {rlv_d_r[1:0], rl_valid};

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		sign_d_r <= 3'd0;
	else if(softreset)
		sign_d_r <= 3'd0;
	else
		sign_d_r <= {sign_d_r[1:0], level_sign};

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		head_pair_r <= 1'b1;
	else if(softreset || state_r == ST_IDLE)
		head_pair_r <= 1'b1;
	else if(rl_valid || ~s1_mb_intra)
		head_pair_r <= 1'b0;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		mult_cache_r <= 12'd0;
	else if(softreset)
		mult_cache_r <= 12'd0;
	else
		mult_cache_r <= {mult_result_w[28], mult_result_w[15:5]};

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		ovf_r <= 1'b0;
	else if(softreset)
		ovf_r <= 1'b0;
	else
		ovf_r <= |mult_result_w[28:16];

assign clipped_w = ovf_r ? (sign_d_r[2] ? 12'h800 : 12'h7ff) :
					mult_cache_r;

always @*
	case(state_r)
	ST_IDLE:
		cmem_addr_w = {3'b010, sa_qstype, s1_mb_qscode};
	ST_BLOCK:
		cmem_addr_w = rlv_d_r[0] ? {3'b000, wpos_r} : s1_mb_intra ?
						{1'b1, cust_qm_i_r, 1'b1, next_wpos_w[5:0]} :
						{1'b1, cust_qm_ni_r, 1'b0, next_wpos_w[5:0]};
	ST_LOADQM:
		cmem_addr_w = {2'b11, qm_intra, wpos_r};
	default:
		cmem_addr_w = 9'bx;		// don't care
	endcase

always @*
	case(sa_dcprec)
	2'd0:	dc_mult_w = 4'd8;
	2'd1:	dc_mult_w = 4'd4;
	2'd2:	dc_mult_w = 4'd2;
	2'd3:	dc_mult_w = 4'd1;
	endcase

assign mult_a_w = rl_valid ? ((head_pair_r && run == 6'd0) ?
					{5'd0, dc_mult_w} :	// multiplier for DC coefficient (in Intra MB)
					{2'd0, qscale_r}) :	// S
					{1'b0, cmem_dout_w[8] ? 8'd16 : cmem_dout_w[7:0]};			// Q
assign mult_b_w = rl_valid ?
					{7'd0, level_data, ~s1_mb_intra} :	// L
					mult_result_w[19:0];		// S*L

m2visdq_mult u_mult(
	.clock  (clk),
	.dataa  (mult_a_w),
	.datab  (mult_b_w),
	.result (mult_result_w)
);

// (cmem memory map)
// 000xxxxxx [ 64] Table (RL pair index --> XY index)
// 001xxxxxx [ 64] Unused
// 0100xxxxx [ 32] Quant scale [Type=0] (Upper-byte:pos, Lower-byte:neg)
// 0101xxxxx [ 32] Quant scale [Type=1] (Upper-byte:pos, Lower-byte:neg)
// 011xxxxxx [ 64] Unused
// 100xxxxxx [ 64] Standard qmat for nonintra
// 101xxxxxx [ 64] Standard qmat for intra
// 110xxxxxx [ 64] Custom qmat for nonintra
// 111xxxxxx [ 64] Custom qmat for intra
m2visdq_cmem u_cmem(
	.address (cmem_addr_w),
	.clock   (clk),
	.data    ({8'd0, qm_value}),
	.wren    (qm_valid & qm_custom),
	.byteena (2'b01),
	.q       (cmem_dout_w)
);

// (dmem memory map)
// 0xxxxxx [64] Coefficient data for page 0
// 1xxxxxx [64] Coefficient data for page 1
m2visdq_dmem u_dmem(
	.address_a      ({wpage_r, cmem_dout_w[5:0]}),
	.address_b      ({~wpage_r, rpos_r[2:0], rpos_r[5:3]}),
	.addressstall_a (rlv_d_r[2]),
	.clock          (clk),
	.data_a         ({sign_d_r[2], clipped_w}),
	.data_b         (13'd0),
	.wren_a         (rlv_d_r[2]),
	.wren_b         (state_r == ST_CLEAR || (cvalid_r & coef_next)),
	.q_a            (),
	.q_b            (dmem_doutb_w)
);

assign coef_sign = dmem_doutb_w[12];
assign coef_data = (dmem_doutb_w[12] & lastcoef_r & ~mismatch_r) ?
					{dmem_doutb_w[11:1] + 11'd1, 1'b0} :
					{dmem_doutb_w[11:1], lastcoef_r ? mismatch_r : dmem_doutb_w[0]};

endmodule
// vim:set foldmethod=marker:
