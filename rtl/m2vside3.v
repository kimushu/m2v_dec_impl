//================================================================================
// MPEG2 Video Side Information container (3rd stage)
// Written by kimu_shu
//================================================================================

module m2vside3 #(
	parameter
	MVH_WIDTH = 16,
	MVV_WIDTH = 15,
	MBX_WIDTH = 6,
	MBY_WIDTH = 5
) (
	input        clk,
	input        reset_n,

	input [(MVH_WIDTH-1):0] s2_mv_h,
	input [(MVV_WIDTH-1):0] s2_mv_v,
	input [(MBX_WIDTH-1):0] s2_mb_x,
	input [(MBY_WIDTH-1):0] s2_mb_y,
	input        s2_mb_intra,
	input  [2:0] s2_block,
	input        s2_coded,
	input        s2_enable,

	input        block_start,

	output [(MVH_WIDTH-1):0] s3_mv_h,
	output [(MVV_WIDTH-1):0] s3_mv_v,
	output [(MBX_WIDTH-1):0] s3_mb_x,
	output [(MBY_WIDTH-1):0] s3_mb_y,
	output       s3_mb_intra,
	output [2:0] s3_block,
	output       s3_coded,
	output       s3_enable
);

//--------------------------------------------------------------------------------
// Stage 3 (Latched by block_start pules)
//
reg [(MVH_WIDTH-1):0] s3_mv_h_r;
reg [(MVV_WIDTH-1):0] s3_mv_v_r;
reg [(MBX_WIDTH-1):0] s3_mb_x_r;
reg [(MBY_WIDTH-1):0] s3_mb_y_r;
reg       s3_mb_intra_r;
reg [2:0] s3_block_r;
reg       s3_coded_r;
reg       s3_enable_r;

// {{{
always @(posedge clk or negedge reset_n)
	if(~reset_n) begin
		s3_mv_h_r      <= 0;
		s3_mv_v_r      <= 0;
		s3_mb_x_r      <= 0;
		s3_mb_y_r      <= 0;
		s3_mb_intra_r  <= 1'b0;
		s3_block_r     <= 3'd0;
		s3_coded_r     <= 1'b0;
		s3_enable_r    <= 1'b0;
	end else if(block_start) begin
		s3_mv_h_r      <= s2_mv_h;
		s3_mv_v_r      <= s2_mv_v;
		s3_mb_x_r      <= s2_mb_x;
		s3_mb_y_r      <= s2_mb_y;
		s3_mb_intra_r  <= s2_mb_intra;
		s3_block_r     <= s2_block;
		s3_coded_r     <= s2_coded;
		s3_enable_r    <= s2_enable;
	end

assign s3_mv_h = s3_mv_h_r;
assign s3_mv_v = s3_mv_v_r;
assign s3_mb_x = s3_mb_x_r;
assign s3_mb_y = s3_mb_y_r;
assign s3_mb_intra = s3_mb_intra_r;
assign s3_block = s3_block_r;
assign s3_coded = s3_coded_r;
assign s3_enable = s3_enable_r;
// }}}

endmodule
// vim:set foldmethod=marker:
