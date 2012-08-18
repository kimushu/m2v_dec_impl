//================================================================================
// Display driver for Himax HX8347-A (320x240)
// Written by kimu_shu
//================================================================================

module m2vdd_hx8347a #(
	parameter
	MEM_WIDTH = 21,
	MBX_WIDTH = 6,
	MBY_WIDTH = 5
) (
	input         clk,
	input         reset_n,

	// LCD (Conduit)
	input         lcd_clk,
	output        lcd_reset_n,
	output        lcd_cs,
	output        lcd_rs,
	inout  [15:0] lcd_data,
	output        lcd_write_n,
	output        lcd_read_n,

	// Driver control port (Avalon-MM Slave)
	input         ctrl_read,
	output [31:0] ctrl_readdata,
	input         ctrl_write,
	input  [31:0] ctrl_writedata,
	output        ctrl_waitrequest,
	output        ctrl_readdatavalid,

	// Frame buffer (Avalon-MM Master)
	output [(MEM_WIDTH-1):0] fbuf_address,
	output        fbuf_read,
	input  [15:0] fbuf_readdata,
	output        fbuf_write,
	output [15:0] fbuf_writedata,
	input         fbuf_waitrequest,
	input         fbuf_readdatavalid,

	// Page-select input (Conduit)
	output [(MBX_WIDTH+MBY_WIDTH-1):0] fptr_address,
	input         fptr_updated,
	input         fptr_number
);

`define R_SCU		8'h02	// Column address Start (Upper byte)
`define R_SCL		8'h03	// Column address Start (Lower byte)
`define R_ECU		8'h04	// Column address End (Upper byte)
`define R_ECL		8'h05	// Column address End (Lower byte)
`define R_SPU		8'h06	// Row address Start (Upper byte)
`define R_SPL		8'h07	// Row address Start (Lower byte)
`define R_EPU		8'h08	// Row address End (Upper byte)
`define R_EPL		8'h09	// Row address End (Lower byte)
`define R_WD		8'h22	// Write Data (the same address as RD)

`include "m2vutils.vh"

localparam
	B_START   = 31,
	B_WRITE   = 30,
	B_VIDEOWD = 29,
	B_VIDEOHT = 28,
	B_SRESET  = 27;

wire        fifo_write_w;
reg  [17:0] fifo_wdata_w;
wire        fifo_wfull_w;
reg         fifo_read_r;
wire [17:0] fifo_rdata_w;
wire        fifo_rempty_w;

m2vdd_hx8347a_fifo u_fifo(
	.data    (fifo_wdata_w),
	.rdclk   (lcd_clk),
	.rdreq   (fifo_read_r),
	.wrclk   (clk),
	.wrreq   (fifo_write_w),
	.q       (fifo_rdata_w),
	.rdempty (fifo_rempty_w),
	.wrfull  (fifo_wfull_w)
);

//--------------------------------------------------------------------------------
// System clock region (clk)
//
localparam
	ST_IDLE   = 3'd0,
	ST_PAGE   = 3'd1,
	ST_BRANCH = 3'd2,
	ST_FBREAD = 3'd3,
	ST_WAIT   = 3'd4,
	ST_RANGE  = 3'd5,
	ST_NEXT   = 3'd6,
	ST_LAST   = 3'd7;

reg [2:0] state_r;

`ifdef SIM	// {{{
reg [23:0] statename;
always @(state_r)
	case(state_r)
	ST_IDLE:	statename = "IDL";
	ST_PAGE:	statename = "PAG";
	ST_BRANCH:	statename = "BRA";
	ST_FBREAD:	statename = "REA";
	ST_WAIT:	statename = "WAI";
	ST_RANGE:	statename = "RAN";
	ST_NEXT:	statename = "NEX";
	ST_LAST:	statename = "LAS";
	default:	statename = "***";
	endcase
`endif	// }}}

reg ctrl_read_1d_r;
always @(posedge clk or negedge reset_n)
	if(~reset_n)
		ctrl_read_1d_r <= 1'b0;
	else
		ctrl_read_1d_r <= ctrl_read;

assign ctrl_readdata = {30'd0, fifo_wfull_w, (state_r == ST_IDLE) ? 1'd0 : 1'd1};
assign ctrl_readdatavalid = ctrl_read_1d_r;
assign ctrl_waitrequest = 1'b0;

reg softreset_r;
always @(posedge clk or negedge reset_n)
	if(~reset_n)
		softreset_r <= 1'b1;
	else if(ctrl_write)
		softreset_r <= ctrl_writedata[B_SRESET];

//------------------------------------------------------------
// MB address
//
reg [(MBX_WIDTH-1):0] max_mbx_r;
reg [(MBY_WIDTH-1):0] max_mby_r;
reg [3:0] last_pxy_r;
reg [(MBX_WIDTH-1):0] mbx_r;
reg [(MBY_WIDTH-1):0] mby_r;
wire [MBX_WIDTH:0] next_mbx_w;
wire [MBY_WIDTH:0] next_mby_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		max_mbx_r <= {(MBX_WIDTH){1'b0}};
	else if(softreset_r)
		max_mbx_r <= {(MBX_WIDTH){1'b0}};
	else if(ctrl_write & ctrl_writedata[B_VIDEOWD])
		max_mbx_r <= ctrl_writedata[(MBX_WIDTH+3):4];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		max_mby_r <= {(MBY_WIDTH){1'b0}};
	else if(softreset_r)
		max_mby_r <= {(MBY_WIDTH){1'b0}};
	else if(ctrl_write & ctrl_writedata[B_VIDEOHT])
		max_mby_r <= ctrl_writedata[(MBY_WIDTH+3):4];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		last_pxy_r <= 4'd15;
	else if(softreset_r)
		last_pxy_r <= 4'd15;
	else if(ctrl_write & ctrl_writedata[B_VIDEOHT])
		last_pxy_r <= ctrl_writedata[3:0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		mbx_r <= {(MBX_WIDTH){1'b0}};
	else if(softreset_r)
		mbx_r <= {(MBX_WIDTH){1'b0}};
	else if(state_r == ST_IDLE)
		mbx_r <= max_mbx_r;
	else if(state_r == ST_NEXT)
		mbx_r <= next_mbx_w[MBX_WIDTH] ? max_mbx_r :
					next_mbx_w[(MBX_WIDTH-1):0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		mby_r <= {(MBY_WIDTH){1'b0}};
	else if(softreset_r)
		mby_r <= {(MBY_WIDTH){1'b0}};
	else if(state_r == ST_IDLE)
		mby_r <= max_mby_r;
	else if(state_r == ST_NEXT && next_mbx_w[MBX_WIDTH])
		mby_r <= next_mby_w[(MBY_WIDTH-1):0];

assign next_mbx_w = {1'b0, mbx_r} - 1'b1;
assign next_mby_w = {1'b0, mby_r} - 1'b1;

assign fptr_address = {mby_r, mbx_r};

//------------------------------------------------------------
// Pixel address (in MB) / Frame buffer read side
//
reg       frpage_r;
reg       frchroma_r;
reg [2:0] frpxx2_r;
reg [3:0] frpxy_r;
wire [3:0] next_frpxx2_w;
wire [4:0] next_frpxy_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		frpage_r <= 1'b0;
	else if(softreset_r)
		frpage_r <= 1'b0;
	else if(state_r == ST_BRANCH)
		frpage_r <= fptr_number;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		frchroma_r <= 1'b0;
	else if(softreset_r)
		frchroma_r <= 1'b0;
	else if(state_r == ST_BRANCH)
		frchroma_r <= 1'b0;
	else if(next_frpxy_w[4] & next_frpxx2_w[3])
		frchroma_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		frpxx2_r <= 3'd0;
	else if(softreset_r)
		frpxx2_r <= 3'd0;
	else if(state_r == ST_BRANCH)
		frpxx2_r <= 3'd0;
	else if(state_r == ST_FBREAD && ~fbuf_waitrequest)
		frpxx2_r <= next_frpxx2_w[2:0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		frpxy_r <= 4'd0;
	else if(softreset_r || state_r == ST_PAGE || state_r == ST_WAIT)
		frpxy_r <= 4'd0;
	else if((state_r == ST_RANGE && ~fifo_wfull_w) ||
			(state_r == ST_FBREAD && ~fbuf_waitrequest && next_frpxx2_w[3]))
		frpxy_r <= next_frpxy_w[3:0];

assign next_frpxx2_w = {1'b0, frpxx2_r} + 1'b1;
assign next_frpxy_w = {1'b0, frpxy_r} + 1'b1;

assign fbuf_address = frchroma_r ?
	FBADDR_CH(frpage_r, frpxx2_r[0], mbx_r, frpxx2_r, mby_r, {frpxy_r[2:0], 1'bx}) :
	FBADDR_LU(frpage_r,              mbx_r, frpxx2_r, mby_r, frpxy_r);
assign fbuf_read = (state_r == ST_FBREAD);
assign fbuf_write = 1'b0;
assign fbuf_writedata = 16'bx;

//------------------------------------------------------------
// Buffer RAM write address
//
reg        bwpage_r;
reg  [7:0] bwaddr_r;
wire [7:0] next_bwaddr_w;
wire       bwrite_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		bwpage_r <= 1'b0;
	else if(softreset_r)
		bwpage_r <= 1'b0;
	else if(state_r == ST_IDLE)
		bwpage_r <= 1'b0;
	else if(state_r == ST_NEXT)
		bwpage_r <= ~bwpage_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		bwaddr_r <= 8'd0;
	else if(softreset_r || state_r == ST_BRANCH)
		bwaddr_r <= 8'd0;
	else if(fbuf_readdatavalid)
		bwaddr_r <= next_bwaddr_w;

assign next_bwaddr_w = bwaddr_r + 1'b1;
assign bwrite_w = fbuf_readdatavalid;

//------------------------------------------------------------
// Buffer RAM read --> YCbCr convertion
//
reg         brfull_r;
reg   [7:0] brpixel_r;
reg         brluma_r;
reg         brchroma_r;
reg   [7:0] brybuf_r;
reg         convert_r;
reg         brend_r;
wire  [8:0] next_brpixel_w;
wire  [6:0] braddr_w;
wire [31:0] buf_q_w;
wire  [7:0] brcb_w;
wire  [7:0] brcr_w;
wire  [7:0] rout_w;
wire  [7:0] gout_w;
wire  [7:0] bout_w;
wire        rgbvalid_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		brfull_r <= 1'b0;
	else if(softreset_r || state_r == ST_IDLE)
		brfull_r <= 1'b0;
	else if(state_r == ST_NEXT)
		brfull_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		brpixel_r <= 8'd0;
	else if(softreset_r || state_r == ST_PAGE)
		brpixel_r <= 8'd0;
	else if(rgbvalid_w)
		brpixel_r <= next_brpixel_w[7:0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		brluma_r <= 1'b0;
	else if(softreset_r || (brluma_r & ~fifo_wfull_w))
		brluma_r <= 1'b0;
	else if(state_r == ST_BRANCH || rgbvalid_w || state_r == ST_NEXT)
		brluma_r <= brfull_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		brchroma_r <= 1'b0;
	else if(softreset_r)
		brchroma_r <= 1'b0;
	else if(~fifo_wfull_w)
		brchroma_r <= brluma_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		brybuf_r <= 8'd0;
	else if(softreset_r)
		brybuf_r <= 8'd0;
	else if(brchroma_r)
		case(brpixel_r[1:0])
		2'd0:	brybuf_r <= buf_q_w[ 7: 0];
		2'd1:	brybuf_r <= buf_q_w[15: 8];
		2'd2:	brybuf_r <= buf_q_w[23:16];
		2'd3:	brybuf_r <= buf_q_w[31:24];
		endcase

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		convert_r <= 1'b0;
	else if(softreset_r)
		convert_r <= 1'b0;
	else if(state_r == ST_FBREAD || state_r == ST_WAIT || state_r == ST_LAST)
		convert_r <= ~fifo_wfull_w & brchroma_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		brend_r <= 1'b0;
	else if(softreset_r || state_r == ST_BRANCH || state_r == ST_NEXT)
		brend_r <= 1'b0;
	else if(rgbvalid_w & next_brpixel_w[8])
		brend_r <= 1'b1;

assign next_brpixel_w = {1'b0, brpixel_r} + 1'b1;
assign braddr_w = {brchroma_r, brchroma_r ?
					{1'b0, brpixel_r[7:3]} : brpixel_r[7:2]};

assign brcb_w = brpixel_r[1] ? buf_q_w[31:24] : buf_q_w[23:16];
assign brcr_w = brpixel_r[1] ? buf_q_w[15: 8] : buf_q_w[ 7: 0];

m2vdd_hx8347a_buf u_buf(
	.clock     (clk),
	.data      (fbuf_readdata),
	.wraddress ({bwpage_r, bwaddr_r}),
	.wren      (bwrite_w),
	.rdaddress ({~bwpage_r, braddr_w}),
	.q         (buf_q_w)
);

ycbcr2rgb u_conv(
	.clk     (clk),
	.reset_n (reset_n),
	.y       (brybuf_r),
	.cb      (brcb_w),
	.cr      (brcr_w),
	.convert (convert_r),
	.r       (rout_w),
	.g       (gout_w),
	.b       (bout_w),
	.valid   (rgbvalid_w)
);

//------------------------------------------------------------
// State machine
//
always @(posedge clk or negedge reset_n)
	if(~reset_n)
		state_r <= ST_IDLE;
	else if(softreset_r)
		state_r <= ST_IDLE;
	else
		case(state_r)
		ST_IDLE:	state_r <= (ctrl_write & ctrl_writedata[B_START]) ?
								ST_PAGE : ST_IDLE;
		ST_PAGE:	state_r <= ST_BRANCH;
		ST_BRANCH:	state_r <= fptr_updated ? ST_FBREAD : ST_NEXT;
		ST_FBREAD:	state_r <= (frchroma_r & next_frpxy_w[3] & next_frpxx2_w[3]) ?
								ST_WAIT : ST_FBREAD;
		ST_WAIT:	state_r <= (brend_r | ~brfull_r) ? ST_RANGE : ST_WAIT;
		ST_RANGE:	state_r <= (&frpxy_r[3:2] & ~fifo_wfull_w) ? ST_NEXT : ST_RANGE;
		ST_NEXT:	state_r <= (next_mby_w[MBY_WIDTH] & next_mbx_w[MBX_WIDTH]) ?
								ST_LAST : ST_PAGE;
		ST_LAST:	state_r <= brend_r ? ST_IDLE : ST_LAST;
		endcase

//------------------------------------------------------------
// FIFO write
//
assign fifo_write_w = ~softreset_r & ~fifo_wfull_w &
	((ctrl_write & ctrl_writedata[B_WRITE]) || state_r == ST_RANGE || rgbvalid_w);

always @*
	if(state_r == ST_RANGE)
		case(frpxy_r)
		4'd0:	fifo_wdata_w = {2'b10, 8'd0, `R_SCU};
		4'd1,
		4'd5:	fifo_wdata_w = {2'b11, 8'd0, {(12-MBX_WIDTH){1'b0}},
								mbx_r[(MBX_WIDTH-1):4]};
		4'd2:	fifo_wdata_w = {2'b10, 8'd0, `R_SCL};
		4'd3:	fifo_wdata_w = {2'b11, 8'd0, mbx_r[3:0], 4'd0};
		4'd4:	fifo_wdata_w = {2'b10, 8'd0, `R_ECU};
		4'd6:	fifo_wdata_w = {2'b10, 8'd0, `R_ECL};
		4'd7:	fifo_wdata_w = {2'b11, 8'd0, mbx_r[3:0], 4'd15};
		4'd8:	fifo_wdata_w = {2'b10, 8'd0, `R_SPL};
		4'd9:	fifo_wdata_w = {2'b11, 8'd0, mby_r[3:0], 4'd0};
		4'd10:	fifo_wdata_w = {2'b10, 8'd0, `R_EPL};
		4'd11:	fifo_wdata_w = {2'b11, 8'd0, mby_r[3:0], 4'd15};
		4'd12:	fifo_wdata_w = {2'b10, 8'd0, `R_WD};
		default:
				fifo_wdata_w = {2'b10, 16'd0};
		endcase
	else if(ctrl_write & ctrl_writedata[B_WRITE])
		fifo_wdata_w = ctrl_writedata[17:0];
	else
		fifo_wdata_w = {2'b11, rout_w[7:3], gout_w[7:2], bout_w[7:3]};

//--------------------------------------------------------------------------------
// LCD clock region (lcd_clk)
//

// lcd_clk      ~~~~____~~~~____~~~~____~~~~____~~~~____~~~~____~~~~____~~~~____
//
// lcd_write_n  ~~~~~~~~________~~~~~~~~________~~~~~~~~~~~~~~~~________~~~~~~~~
//
// lcd_data     --------X 1st-data      X 2nd-data              X 3rd-data
//
// fifo_empty   ________________________~~~~~~~~________________________________
//
// fifo_read    ~~~~~~~~________~~~~~~~~________________~~~~~~~~________~~~~~~~~

reg lcd_xwr_r;
reg rempty_1d_r;

always @(posedge lcd_clk or negedge reset_n)
	if(~reset_n)
		fifo_read_r <= 1'b0;
	else if(softreset_r)
		fifo_read_r <= 1'b1;
	else if(fifo_rempty_w | fifo_read_r)
		fifo_read_r <= 1'b0;
	else
		fifo_read_r <= 1'b1;

always @(posedge lcd_clk or negedge reset_n)
	if(~reset_n)
		rempty_1d_r <= 1'b1;
	else
		rempty_1d_r <= fifo_rempty_w;

always @(posedge lcd_clk or negedge reset_n)
	if(~reset_n)
		lcd_xwr_r <= 1'b1;
	else if(softreset_r | ~lcd_xwr_r)
		lcd_xwr_r <= 1'b1;
	else if(~rempty_1d_r & fifo_rdata_w[17])
		lcd_xwr_r <= 1'b0;

assign lcd_reset_n = fifo_rdata_w[17];
assign lcd_cs = 1'b0;
assign lcd_rs = fifo_rdata_w[16];
assign lcd_data = fifo_rdata_w[15:0];
assign lcd_write_n = lcd_xwr_r;
assign lcd_read_n = 1'b1;

endmodule
// vim:set foldmethod=marker:
