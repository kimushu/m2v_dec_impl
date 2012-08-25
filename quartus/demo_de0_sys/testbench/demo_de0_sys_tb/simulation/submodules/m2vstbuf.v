//================================================================================
// MPEG2 Video Input Stream Buffer (Submodule of m2vdec)
// Written by kimu_shu
//================================================================================

module m2vstbuf(
	input         clk,
	input         reset_n,
	input         softreset,

	input         stream_valid,
	input   [7:0] stream_data,
	output        stream_ready,

	input         parser_shift,
	input   [3:0] parser_width,
	input         parser_align,

	input   [2:0] vld_width,
	input         vld_shift,

	output [12:0] buffer_data,
	output        buffer_valid
);

reg  [23:0] fetched_r;		// 3*8-bit wide fetch buffer
reg   [4:0] offset_r;		// Offset from top of fetch buffer

wire        wrfull_w;
wire  [7:0] fifo_out_w;
wire        fifo_rdreq_w;
wire        fifo_rdempty_w;
wire  [4:0] next_offset_w;
wire [23:0] dataout_w;

/*
offset_r は有効データの先頭位置を示す
0～24

シフトを実行すると、先頭位置はシフト量だけ増える。増やした後が8以上であり、
かつ、次のデータが有効ならば、+8してfetchバッファ全体をバイトシフトする。

また、シフトを実行しないサイクルでも、offset_rが8以上かつ次のデータが有効ならば、+8してfetch(ry
*/

assign stream_ready = ~wrfull_w | softreset;
assign buffer_data = dataout_w[23:11];
assign buffer_valid = ~(|offset_r[4:3]);

assign next_offset_w = offset_r + (
						parser_shift ? {1'd0, parser_width} :
						vld_shift ? {2'd0, vld_width} :
						parser_align ? {1'b0, |offset_r[2:0], 3'd0} :
						5'd0);
assign fifo_rdreq_w = (|next_offset_w[4:3] && ~fifo_rdempty_w) | softreset;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		fetched_r <= 24'h000000;
	else if(softreset)
		fetched_r <= 24'h000000;
	else if(fifo_rdreq_w)
		fetched_r <= {fetched_r[15:0], fifo_out_w};

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		offset_r <= 5'd24;
	else if(softreset)
		offset_r <= 5'd24;
	else
		offset_r <= {next_offset_w[4:3] - fifo_rdreq_w, parser_align ? 3'd0 : next_offset_w[2:0]};

// Input FIFO (8-bit IN --> 8-bit OUT [Look-ahead])
m2vstbuf_fifo u_input_fifo(
	.data    (stream_data),
	.wrclk   (clk),
	.wrreq   (stream_valid & stream_ready & ~softreset),
	.wrfull  (wrfull_w),
	.rdclk   (clk),
	.q       (fifo_out_w),
	.rdreq   (fifo_rdreq_w),
	.rdempty (fifo_rdempty_w)
);

// Barrel Shifter
m2vstbuf_shifter u_shifter(
	.data     (fetched_r),
	.distance (offset_r[2:0]),
	.result   (dataout_w)
);

endmodule
// vim:set foldmethod=marker:
