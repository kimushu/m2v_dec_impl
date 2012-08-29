//================================================================================
// MPEG2 Video Side Information container (1st stage)
// Written by kimu_shu
//================================================================================

module m2vside1 #(
	parameter
	MVH_WIDTH = 16,
	MVV_WIDTH = 15,
	MBX_WIDTH = 6,
	MBY_WIDTH = 5
) (
	// common
	input        clk,
	input        reset_n,

	// from m2vctrl
	input [(MVH_WIDTH-1):0] s0_data,
	input        pict_valid,		// {qstype,dcprec}
	input        mvec_h_valid,
	input        mvec_v_valid,
	input        s0_valid,			// {mb_intra,pattern}
	input [(MBX_WIDTH-1):0] s0_mb_x,
	input [(MBY_WIDTH-1):0] s0_mb_y,
	input  [4:0] s0_mb_qscode,

	// from m2vctrl
	input        pre_block_start,
	input        block_start,

	// to all modules
	output [1:0] sa_dcprec,
	output       sa_qstype,
	output       sa_iframe,

	// to m2visdq, m2vside2
	output [(MVH_WIDTH-1):0] s1_mv_h,
	output [(MVV_WIDTH-1):0] s1_mv_v,
	output [(MBX_WIDTH-1):0] s1_mb_x,
	output [(MBY_WIDTH-1):0] s1_mb_y,
	output [4:0] s1_mb_qscode,
	output       s1_mb_intra,
	output [2:0] s1_block,
	output       s1_coded,
	output       s1_enable
);

//--------------------------------------------------------------------------------
// Common (All stages)
//
reg       sa_iframe_r;
reg [1:0] sa_dcprec_r;
reg       sa_qstype_r;

// {{{
always @(posedge clk or negedge reset_n)
	if(~reset_n)
		{sa_iframe_r, sa_qstype_r, sa_dcprec_r} <= 4'd0;
	else if(pict_valid)
		{sa_iframe_r, sa_qstype_r, sa_dcprec_r} <= s0_data[3:0];

assign sa_iframe = sa_iframe_r;
assign sa_dcprec = sa_dcprec_r;
assign sa_qstype = sa_qstype_r;
// }}}

//--------------------------------------------------------------------------------
// Stage 0 (Latched by xxx_valid/xxx_start pulses)
//
reg [(MVH_WIDTH-1):0] s0_mv_h_r;
reg [(MVV_WIDTH-1):0] s0_mv_v_r;
reg [(MBX_WIDTH-1):0] s0_mb_x_r;
reg [(MBY_WIDTH-1):0] s0_mb_y_r;
reg       s0_mb_intra_r;
reg [4:0] s0_mb_qscode_r;
reg [5:0] s0_pattern_r;
reg [2:0] s0_block_r;
reg       s0_enable_r;

// {{{
always @(posedge clk or negedge reset_n)
	if(~reset_n)
		s0_mv_h_r <= 0;
	else if(mvec_h_valid)
		s0_mv_h_r <= s0_data[(MVH_WIDTH-1):0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		s0_mv_v_r <= 0;
	else if(mvec_v_valid)
		s0_mv_v_r <= s0_data[(MVV_WIDTH-1):0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		{s0_mb_intra_r, s0_mb_qscode_r, s0_mb_x_r, s0_mb_y_r} <= 0;
	else if(s0_valid)
		{s0_mb_intra_r, s0_mb_qscode_r, s0_mb_x_r, s0_mb_y_r} <=
			{s0_data[6], s0_mb_qscode, s0_mb_x, s0_mb_y};

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		s0_pattern_r <= 6'd0;
	else if(s0_valid)
		s0_pattern_r <= s0_data[5:0];
	else if(block_start)
		s0_pattern_r <= {s0_pattern_r[4:0], 1'b0};

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		s0_block_r <= 3'd0;
	else if(s0_valid)
		s0_block_r <= 3'd0;
	else if(block_start)
		s0_block_r <= s0_block_r + 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		s0_enable_r <= 1'b0;
	else if(s0_valid)
		s0_enable_r <= 1'b1;
	else if(block_start & s0_block_r[2] & s0_block_r[0])
		s0_enable_r <= 1'b0;

assign s0_enable = s0_enable_r;
// }}}

//--------------------------------------------------------------------------------
// Stage 1 (Latched by pre_block_start pules)
//
reg [(MVH_WIDTH-1):0] s1_mv_h_r;
reg [(MVV_WIDTH-1):0] s1_mv_v_r;
reg [(MBX_WIDTH-1):0] s1_mb_x_r;
reg [(MBY_WIDTH-1):0] s1_mb_y_r;
reg       s1_mb_intra_r;
reg [4:0] s1_mb_qscode_r;
reg [2:0] s1_block_r;
reg       s1_coded_r;
reg       s1_enable_r;

// {{{
always @(posedge clk or negedge reset_n)
	if(~reset_n) begin
		s1_mv_h_r      <= 0;
		s1_mv_v_r      <= 0;
		s1_mb_x_r      <= 0;
		s1_mb_y_r      <= 0;
		s1_mb_qscode_r <= 5'd0;
		s1_mb_intra_r  <= 1'b0;
		s1_block_r     <= 3'd0;
		s1_coded_r     <= 1'b0;
		s1_enable_r    <= 1'b0;
	end else if(pre_block_start) begin
		s1_mv_h_r      <= s0_mv_h_r;
		s1_mv_v_r      <= s0_mv_v_r;
		s1_mb_x_r      <= s0_mb_x_r;
		s1_mb_y_r      <= s0_mb_y_r;
		s1_mb_qscode_r <= s0_mb_qscode_r;
		s1_mb_intra_r  <= s0_mb_intra_r;
		s1_block_r     <= s0_block_r;
		s1_coded_r     <= s0_pattern_r[5];
		s1_enable_r    <= s0_enable_r;
	end

assign s1_mv_h = s1_mv_h_r;
assign s1_mv_v = s1_mv_v_r;
assign s1_mb_x = s1_mb_x_r;
assign s1_mb_y = s1_mb_y_r;
assign s1_mb_qscode = s1_mb_qscode_r;
assign s1_mb_intra = s1_mb_intra_r;
assign s1_block = s1_block_r;
assign s1_coded = s1_coded_r;
assign s1_enable = s1_enable_r;
// }}}

endmodule
// vim:set foldmethod=marker:
