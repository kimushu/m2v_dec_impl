//================================================================================
// MPEG2 Video Variable Length Decoder (Submodule of m2vdec)
// Written by kimu_shu
//================================================================================

module m2vvld(
	input         clk,
	input         reset_n,
	input         softreset,

	input   [2:0] vld_table,
	input         vld_decode,

	input  [12:0] buffer_data,
	input         buffer_valid,
	output  [2:0] vld_width,
	output        vld_shift,

	output [13:0] symbol_data,
	output        symbol_valid,
	output        symbol_nextbit
);

parameter
	TABLE_B1  = 3'd0,	// [4,4,4 :  112 items] 4x 7
	TABLE_B10 = 3'd1,	// [4,4,4 :   96 items] 4x 6
	TABLE_B12 = 3'd2,	// [4,6   :   80 items] 4x 1,6x1
	TABLE_B13 = 3'd3,	// [4,6   :   80 items] 4x 1,6x1
	TABLE_B3  = 3'd4,	// [6     :   64 items]      6x1
	TABLE_B9  = 3'd5,	// [6,4   :  256 items] 4x12,6x1
	TABLE_B14 = 3'd6,	// [6,6,4 :  624 items] 4x15,6x6
	TABLE_B15 = 3'd7;	// [6,4,6 :  720 items] 4x 9,6x9

parameter
	ST_IDLE    = 0,
	ST_WAIT1   = 1,
	ST_DECODE1 = 2,
	ST_WAIT2   = 3,
	ST_DECODE2 = 4,
	ST_WAIT3   = 5,
	ST_DECODE3 = 6,
	ST_WAITS   = 7;

reg   [2:0] state_r;
reg         decode_r;
reg   [2:0] table_r;
reg         shiftmask_r;
reg         shift6_1d_r;
reg   [5:0] nextbits_r;

reg  [10:0] taddr_w;
reg         nextbit_w;
wire        leaf_w;
wire  [2:0] width_w;
wire [13:0] tdata_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		state_r <= ST_IDLE;
	else if(softreset)
		state_r <= ST_IDLE;
	else case(state_r)
	ST_IDLE:	state_r <= ~(vld_decode | decode_r) ? ST_IDLE :
							(buffer_valid ? ST_DECODE1 : ST_WAIT1);
	ST_WAIT1:	state_r <= buffer_valid ? ST_DECODE1 : ST_WAIT1;
	ST_DECODE1:	state_r <= leaf_w ? (buffer_valid ? ST_IDLE : ST_WAITS) :
							(buffer_valid ? ST_DECODE2 : ST_WAIT2);
	ST_WAIT2:	state_r <= buffer_valid ? ST_DECODE2 : ST_WAIT2;
	ST_DECODE2:	state_r <= leaf_w ? (buffer_valid ? ST_IDLE : ST_WAITS) :
							(buffer_valid ? ST_DECODE3 : ST_WAIT3);
	ST_WAIT3:	state_r <= buffer_valid ? ST_DECODE3 : ST_WAIT3;
	ST_DECODE3,
	ST_WAITS:	state_r <= buffer_valid ? ST_IDLE : ST_WAITS;
	endcase

`ifdef SIM	// For debugging {{{
reg [31:0] state_name;
always @(state_r)
	case(state_r)
	ST_IDLE:	state_name = "Idle";
	ST_WAIT1:	state_name = "Wai1";
	ST_DECODE1:	state_name = "Dec1";
	ST_WAIT2:	state_name = "Wai2";
	ST_DECODE2:	state_name = "Dec2";
	ST_WAIT3:	state_name = "Wai3";
	ST_DECODE3:	state_name = "Dec3";
	ST_WAITS:	state_name = "WaiS";
	default:	state_name = "----";
	endcase
`endif		// }}}

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		decode_r <= 1'b0;
	else if(softreset || state_r == ST_DECODE1)
		decode_r <= 1'b0;
	else if(vld_decode)
		decode_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		table_r <= 3'd0;
	else if(softreset)
		table_r <= 3'd0;
	else if(vld_decode)
		table_r <= vld_table;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		shiftmask_r <= 1'b0;
	else if(softreset)
		shiftmask_r <= 1'b0;
	else case(state_r)
	ST_IDLE, ST_WAIT1:
		shiftmask_r <= (vld_decode | decode_r) & buffer_valid;
	ST_DECODE1, ST_DECODE2, ST_DECODE3, ST_WAITS:
		shiftmask_r <= ~(leaf_w & buffer_valid);
	endcase

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		shift6_1d_r <= 1'b0;
	else if(softreset)
		shift6_1d_r <= 1'b0;
	else if(state_r == ST_IDLE)
		shift6_1d_r <= vld_table[2];
	else if(state_r == ST_WAIT1)
		shift6_1d_r <= table_r[2];
	else if(buffer_valid)
		shift6_1d_r <= tdata_w[7];

always @(posedge clk)
	if(state_r == ST_IDLE || state_r == ST_WAIT1)
		nextbits_r <= buffer_data[11:6];
	else if(shift6_1d_r)
		nextbits_r <= buffer_data[5:0];
	else
		nextbits_r <= buffer_data[7:2];

always @*
	case(width_w)
	3'd1:	nextbit_w = nextbits_r[5];
	3'd2:	nextbit_w = nextbits_r[4];
	3'd3:	nextbit_w = nextbits_r[3];
	3'd4:	nextbit_w = nextbits_r[2];
	3'd5:	nextbit_w = nextbits_r[1];
	3'd6:	nextbit_w = nextbits_r[0];
	default:nextbit_w = 1'bx;
	endcase

assign vld_width = width_w;
assign vld_shift = buffer_valid & shiftmask_r;
assign symbol_data = tdata_w;
assign symbol_valid = (state_r == ST_DECODE1 || state_r == ST_DECODE2 ||
						state_r == ST_DECODE3) && leaf_w;
assign symbol_nextbit = nextbit_w;

always @*
	if(state_r == ST_IDLE)
		taddr_w = {2'b0, vld_table[2:0], ({2{vld_table[2]}} & buffer_data[8:7]), buffer_data[12:9]};
	else if(state_r == ST_WAIT1)
		taddr_w = {2'b0, table_r[2:0], ({2{table_r[2]}} & buffer_data[8:7]), buffer_data[12:9]};
	else if(shift6_1d_r)
		taddr_w = {tdata_w[6:2], tdata_w[1:0] | ({2{tdata_w[7]}} & buffer_data[2:1]), buffer_data[6:3]};
	else
		taddr_w = {tdata_w[6:2], tdata_w[1:0] | ({2{tdata_w[7]}} & buffer_data[4:3]), buffer_data[8:5]};

// Table Structure
//
// 0_sss_xxxxxx_tiiiiiii --> branch t=type(0:4bit,1:6bit),i=index
// 1_sss_dddddd_dddddddd --> leaf   d=data

m2vvld_table u_table(
	.address (taddr_w),
	.clock   (clk),
	.clken   (buffer_valid),
	.q       ({leaf_w, width_w, tdata_w})
);

endmodule
// vim:set foldmethod=marker:
