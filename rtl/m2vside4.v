//================================================================================
// MPEG2 Video Side Information container (4th stage)
// Written by kimu_shu
//================================================================================

module m2vside4 #(
	parameter
	MBX_WIDTH = 6,
	MBY_WIDTH = 5
) (
	// common
	input        clk,
	input        reset_n,

	// from m2vside4
	input [(MBX_WIDTH-1):0] s3_mb_x,
	input [(MBY_WIDTH-1):0] s3_mb_y,
	input        s3_mb_intra,
	input  [2:0] s3_block,
	input        s3_coded,
	input        s3_enable,

	// from m2vctrl
	input        pre_block_start,
	input        block_start,

	// to m2vmc
	output [(MBX_WIDTH-1):0] s4_mb_x,
	output [(MBY_WIDTH-1):0] s4_mb_y,
	output       s4_mb_intra,
	output [2:0] s4_block,
	output       s4_coded,
	output       s4_enable
);

//--------------------------------------------------------------------------------
// Stage 4 (Latched by block_start pules)
//
reg [(MBX_WIDTH-1):0] s4_mb_x_r;
reg [(MBY_WIDTH-1):0] s4_mb_y_r;
reg       s4_mb_intra_r;
reg [2:0] s4_block_r;
reg       s4_coded_r;
reg       s4_enable_r;

// {{{
always @(posedge clk or negedge reset_n)
	if(~reset_n) begin
		s4_mb_x_r      <= 0;
		s4_mb_y_r      <= 0;
		s4_mb_intra_r  <= 1'b0;
		s4_block_r     <= 3'd0;
		s4_coded_r     <= 1'b0;
		s4_enable_r    <= 1'b0;
	end else if(block_start) begin
		s4_mb_x_r      <= s3_mb_x;
		s4_mb_y_r      <= s3_mb_y;
		s4_mb_intra_r  <= s3_mb_intra;
		s4_block_r     <= s3_block;
		s4_coded_r     <= s3_coded;
		s4_enable_r    <= s3_enable;
	end

assign s4_mb_x = s4_mb_x_r;
assign s4_mb_y = s4_mb_y_r;
assign s4_mb_intra = s4_mb_intra_r;
assign s4_block = s4_block_r;
assign s4_coded = s4_coded_r;
assign s4_enable = s4_enable_r;
// }}}

endmodule
// vim:set foldmethod=marker:
