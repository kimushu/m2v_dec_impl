//================================================================================
// MPEG2 Video Side Information container (2nd stage)
// Written by kimu_shu
//================================================================================

module m2vside2 #(
	parameter
	MVH_WIDTH,
	MVV_WIDTH,
	MBX_WIDTH,
	MBY_WIDTH
) (
	input        clk,
	input        reset_n,

	input [(MVH_WIDTH-1):0] s1_mv_h,
	input [(MVV_WIDTH-1):0] s1_mv_v,
	input [(MBX_WIDTH-1):0] s1_mb_x,
	input [(MBY_WIDTH-1):0] s1_mb_y,
	input        s1_mb_intra,
	input  [2:0] s1_block,
	input        s1_coded,
	input        s1_enable,

	input        block_start,

	output [(MVH_WIDTH-1):0] s2_mv_h,
	output [(MVV_WIDTH-1):0] s2_mv_v,
	output [(MBX_WIDTH-1):0] s2_mb_x,
	output [(MBY_WIDTH-1):0] s2_mb_y,
	output       s2_mb_intra,
	output [2:0] s2_block,
	output       s2_coded,
	output       s2_enable
);

//--------------------------------------------------------------------------------
// Stage 2 (Latched by block_start pules)
//
reg [(MVH_WIDTH-1):0] s2_mv_h_r;
reg [(MVV_WIDTH-1):0] s2_mv_v_r;
reg [(MBX_WIDTH-1):0] s2_mb_x_r;
reg [(MBY_WIDTH-1):0] s2_mb_y_r;
reg       s2_mb_intra_r;
reg [2:0] s2_block_r;
reg       s2_coded_r;
reg       s2_enable_r;

// {{{
always @(posedge clk or negedge reset_n)
	if(~reset_n) begin
		s2_mv_h_r      <= 0;
		s2_mv_v_r      <= 0;
		s2_mb_x_r      <= 0;
		s2_mb_y_r      <= 0;
		s2_mb_intra_r  <= 1'b0;
		s2_block_r     <= 3'd0;
		s2_coded_r     <= 1'b0;
		s2_enable_r    <= 1'b0;
	end else if(block_start) begin
		s2_mv_h_r      <= s1_mv_h;
		s2_mv_v_r      <= s1_mv_v;
		s2_mb_x_r      <= s1_mb_x;
		s2_mb_y_r      <= s1_mb_y;
		s2_mb_intra_r  <= s1_mb_intra;
		s2_block_r     <= s1_block;
		s2_coded_r     <= s1_coded;
		s2_enable_r    <= s1_enable;
	end

assign s2_mv_h = s2_mv_h_r;
assign s2_mv_v = s2_mv_v_r;
assign s2_mb_x = s2_mb_x_r;
assign s2_mb_y = s2_mb_y_r;
assign s2_mb_intra = s2_mb_intra_r;
assign s2_block = s2_block_r;
assign s2_coded = s2_coded_r;
assign s2_enable = s2_enable_r;
// }}}

endmodule
// vim:set foldmethod=marker:
