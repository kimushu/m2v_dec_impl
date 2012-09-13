//================================================================================
// MPEG2 Motion Compensation
// Written by kimu_shu
//================================================================================

module m2vmc #(
	parameter
	MEM_WIDTH = 21,
	MVH_WIDTH = 16,
	MVV_WIDTH = 15,
	MBX_WIDTH = 6,
	MBY_WIDTH = 5
) (
	input         clk,
	input         reset_n,
	input         softreset,

	output        ready_mc,
	input         block_start,
	input         picture_complete,

	output        pixel_coded,
	output  [4:0] pixel_addr,
	input   [8:0] pixel_data0,
	input   [8:0] pixel_data1,

	input         sa_iframe,

	input [(MVH_WIDTH-1):0] s3_mv_h,
	input [(MVV_WIDTH-1):0] s3_mv_v,
	input [(MBX_WIDTH-1):0] s3_mb_x,
	input [(MBY_WIDTH-1):0] s3_mb_y,
	input         s3_mb_intra,
	input   [2:0] s3_block,
	input         s3_coded,
	input         s3_enable,

	input [(MBX_WIDTH-1):0] s4_mb_x,
	input [(MBY_WIDTH-1):0] s4_mb_y,
	input         s4_mb_intra,
	input   [2:0] s4_block,
	input         s4_coded,
	input         s4_enable,

	// (Avalon-MM Master) Frame buffer
	output [(MEM_WIDTH-1):0] fbuf_address,
	output        fbuf_read,
	input  [15:0] fbuf_readdata,
	output        fbuf_write,
	output [15:0] fbuf_writedata,
	input         fbuf_waitrequest,
	input         fbuf_readdatavalid,

	// Frame pointer
	input [(MBX_WIDTH+MBY_WIDTH-1):0] fptr_address,
	output        fptr_updated,
	output        fptr_number
);

localparam MBXY_WIDTH = (MBX_WIDTH+MBY_WIDTH);

//--------------------------------------------------------------------------------
// Common
//
localparam
	ST_IDLE     = 0,
	ST_MIXHEAD  = 1,
	ST_PREMIX   = 2,
	ST_MIX      = 3,
	ST_CALCREF  = 4,
	ST_PREFETCH = 5,
	ST_FETCH    = 6,
	ST_PICTURE  = 7;

reg [2:0] state_r;

assign ready_mc = (state_r == ST_IDLE);

//--------------------------------------------------------------------------------
// Fetch stage (s3)
//

//----------------------------------------
// common (available in ST_FETCH state)
//
reg xhalf_r;
reg xodd_r;
reg yhalf_r;

wire fptr_fetch_w;

//----------------------------------------
// request to framebuffer
//
reg [(MBX_WIDTH+3-1):0] xref_r;		// Reference luma coord (X)
reg [(MBY_WIDTH+4-1):0] yref_r;		// Reference luma coord (Y)
reg [2:0] rxcnt_r;					// X counter (0 -> 4 -> (5:last))
reg [3:0] rycnt_r;					// Y counter (0 -> 8 -> (9:last))
reg [(MBX_WIDTH+3-1):0] xref_1d_r;	// Reference luma coord (X)
reg [(MBY_WIDTH+4-1):0] yref_1d_r;	// Reference luma coord (Y)
reg       fptr_fetch_1d_r;
reg       use_1d_fptr_r;
reg       fren_r;

wire [(MBX_WIDTH+4):0] xraa_w;		// Reference adder (X)
wire [(MVH_WIDTH-1):0] xrab_w;
wire xrac_w;
wire [(MVH_WIDTH-1):0] xrar_w;
wire [(MBY_WIDTH+4):0] yraa_w;		// Reference adder (Y)
wire [(MVV_WIDTH-1):0] yrab_w;
wire yrac_w;
wire [(MVV_WIDTH-1):0] yrar_w;

wire fptr_fetch_wait_w;
wire [(MBXY_WIDTH-1):0] frmbyx_w;
wire [(MEM_WIDTH-1):0] fb_fraddr_w;

assign xraa_w = &rxcnt_r[2] ? {s3_mb_x, s3_block[0] & ~s3_block[2], 4'd0} : {xref_r, 2'b0};
assign xrab_w = &rxcnt_r[2] ? s3_mv_h : {{(MVH_WIDTH-4){1'b0}}, (s3_block[2] ? 4'd8 : 4'd4)};
assign xrac_w = &rxcnt_r[2] & s3_block[2] & s3_mv_h[MVH_WIDTH-1];
assign xrar_w = xraa_w + xrab_w + xrac_w;
assign yraa_w = (state_r == ST_CALCREF) ? {s3_mb_y, s3_block[1], 4'd0} : {yref_r, 1'b0};
assign yrab_w = (state_r == ST_CALCREF) ? s3_mv_v : {{(MVV_WIDTH-3){1'b0}}, (s3_block[2] ? 3'd4 : 3'd2)};
assign yrac_w = (state_r == ST_CALCREF) ? (s3_block[2] & s3_mv_v[MVV_WIDTH-1]) : 1'b0;
assign yrar_w = yraa_w + yrab_w + yrac_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		xref_r <= {(MBX_WIDTH+3){1'b0}};
	else if(softreset)
		xref_r <= {(MBX_WIDTH+3){1'b0}};
	else if(state_r == ST_CALCREF || state_r == ST_PREFETCH ||
			(state_r == ST_FETCH && ~fbuf_waitrequest))
		xref_r <= xrar_w[(MBX_WIDTH+4):2];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		{xodd_r, xhalf_r} <= 2'd0;
	else if(softreset)
		{xodd_r, xhalf_r} <= 2'd0;
	else if(state_r == ST_CALCREF)
		{xodd_r, xhalf_r} <= s3_block[2] ? xrar_w[2:1] : xrar_w[1:0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		rxcnt_r <= 3'd4;
	else if(softreset || state_r == ST_MIX || state_r == ST_IDLE)
		rxcnt_r <= 3'd4;
	else if((rxcnt_r[2] & ~rycnt_r[3] & ~fbuf_waitrequest) || state_r == ST_CALCREF)
		rxcnt_r <= 3'd0;
	else if(~fbuf_waitrequest || state_r == ST_PREFETCH)
		rxcnt_r <= rxcnt_r + 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		yref_r <= 0;
	else if(softreset)
		yref_r <= 0;
	else if(state_r == ST_CALCREF || (state_r == ST_FETCH && &rxcnt_r[2] && ~fbuf_waitrequest))
		yref_r <= yrar_w[(MBY_WIDTH+4):1];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		yhalf_r <= 1'b0;
	else if(softreset)
		yhalf_r <= 1'b0;
	else if(state_r == ST_CALCREF)
		yhalf_r <= s3_block[2] ? yrar_w[1] : yrar_w[0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		rycnt_r <= 4'd0;
	else if(softreset || state_r == ST_CALCREF)
		rycnt_r <= 4'd0;
	else if(rxcnt_r[2] & ~fbuf_waitrequest)
		rycnt_r <= rycnt_r + 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		{xref_1d_r, yref_1d_r} <= 0;
	else if(state_r == ST_PREFETCH || ~fbuf_waitrequest)
		{xref_1d_r, yref_1d_r} <= {xref_r, yref_r};

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		fptr_fetch_1d_r <= 1'b0;
	else
		fptr_fetch_1d_r <= fptr_fetch_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		use_1d_fptr_r <= 1'b0;
	else if(state_r == ST_PREFETCH)
		use_1d_fptr_r <= 1'b0;
	else
		use_1d_fptr_r <= fbuf_waitrequest;

assign fptr_fetch_wait_w = use_1d_fptr_r ? fptr_fetch_1d_r : fptr_fetch_w;

m2vfbagen #(
	.MEM_WIDTH (MEM_WIDTH),
	.MBX_WIDTH (MBX_WIDTH),
	.MBY_WIDTH (MBY_WIDTH)
) u_fbagen_r (
	.block (s3_block),
	.frame (fptr_fetch_wait_w),
	.mbx   (xref_1d_r[(MBX_WIDTH+3-1):3]),
	.x2    (xref_1d_r[2:0]),
	.mby   (yref_1d_r[(MBY_WIDTH+4-1):4]),
	.y     (yref_1d_r[3:0]),
	.addr  (fb_fraddr_w)
);

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		fren_r <= 1'b0;
	else if(state_r == ST_IDLE)
		fren_r <= 1'b0;
	else if(state_r == ST_PREFETCH)
		fren_r <= 1'b1;
	else if(rycnt_r[3] & rxcnt_r[2] & rxcnt_r[0] & ~fbuf_waitrequest)
		fren_r <= 1'b0;

assign frmbyx_w = {yref_r[(MBY_WIDTH+4-1):4], xref_r[(MBX_WIDTH+3-1):3]};

//----------------------------------------
// response from framebuffer
//
reg [2:0] wxcnt_r;		// 0-4
reg [3:0] wycnt_r;		// 0-8
reg [2:0] wxcnt_1d_r;
reg [3:0] wycnt_1d_r;
reg [7:0] px1_1d_r;		// Right-side pixel value (delayed)

reg [8:0] i0ram_r [0:3];
reg [8:0] i1ram_r [0:3];

wire [7:0] px0_w;		// Left-side pixel value
wire [7:0] px1_w;		// Right-side pixel value
wire [8:0] i0out_w;
wire [8:0] i1out_w;
wire [7:0] sum0a_w;		// Half-pixel adder (x,left)
wire [7:0] sum0b_w;
wire [8:0] sum0r_w;
wire [7:0] sum1a_w;		// Half-pixel adder (x,right)
wire [7:0] sum1b_w;
wire [8:0] sum1r_w;
wire [8:0] sum2a_w;		// Half-pixel adder (y,left)
wire [8:0] sum2b_w;
wire [9:0] sum2r_w;
wire [8:0] sum3a_w;		// Half-pixel adder (y,right)
wire [8:0] sum3b_w;
wire [9:0] sum3r_w;
wire [5:0] fwaddr0_w;	// Fetched data write address (Left)
wire [5:0] fwaddr1_w;	// Fetched data write address (Right)
wire       fwxen0_w;
wire       fwxen1_w;
wire       fwen0_w;
wire       fwen1_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		wxcnt_r <= 3'd0;
	else if(state_r != ST_FETCH)
		wxcnt_r <= 3'd0;
	else if(wxcnt_r[2] && fbuf_readdatavalid)
		wxcnt_r <= 3'd0;
	else if(fbuf_readdatavalid)
		wxcnt_r <= wxcnt_r + 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		wycnt_r <= 4'd0;
	else if(state_r != ST_FETCH)
		wycnt_r <= 4'd0;
	else if(wxcnt_r[2] && fbuf_readdatavalid)
		wycnt_r <= wycnt_r + 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		wxcnt_1d_r <= 3'd4;
	else if(state_r != ST_FETCH)
		wxcnt_1d_r <= 3'd4;
	else if(fbuf_readdatavalid)
		wxcnt_1d_r <= wxcnt_r;

/*

■整数精度(偶数)
    Y0 Y1   Y2 Y3   Y4 Y5   Y6 Y7  (Y8 Y9)
    Y0 Y1   Y2 Y3   Y4 Y5   Y6 Y7  (Y8 Y9)
  +)_______________________________________
     0  1    2  3    4  5    6  7

■半画素精度(偶数)
       Y0   Y1 Y2   Y3 Y4   Y5 Y6   Y7(Y8) (Y9)
    Y0 Y1   Y2 Y3   Y4 Y5   Y6 Y7   Y8(Y9)
  +)____________________________________________
        0    1  2    3  4    5  6    7

■整数精度(奇数)
   (Y0)Y1   Y2 Y3   Y4 Y5   Y6 Y7   Y8(Y9)
   (Y0)Y1   Y2 Y3   Y4 Y5   Y6 Y7   Y8(Y9)
  +)_______________________________________
        0    1  2    3  4    5  6    7

■半画素精度(奇数)
      (Y0)  Y1 Y2   Y3 Y4   Y5 Y6   Y7 Y8  (Y9)
   (Y0)Y1   Y2 Y3   Y4 Y5   Y6 Y7   Y8 Y9
  +)____________________________________________
             0  1    2  3    4  5    6  7

*/

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		wycnt_1d_r <= 4'd8;
	else if(state_r != ST_FETCH)
		wycnt_1d_r <= 4'd8;
	else if(wxcnt_r[2] && fbuf_readdatavalid)
		wycnt_1d_r <= wycnt_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		px1_1d_r <= 8'd0;
	else if(fbuf_readdatavalid)
		px1_1d_r <= px1_w;

always @(posedge clk) if(fwxen0_w) i0ram_r[wxcnt_r[1:0]] <= sum0r_w;

always @(posedge clk) if(fwxen1_w) i1ram_r[wxcnt_r[1:0]] <= sum1r_w;

assign px0_w = fbuf_readdata[7:0];
assign px1_w = fbuf_readdata[15:8];

assign i0out_w = i0ram_r[wxcnt_r[1:0]];
assign i1out_w = i1ram_r[wxcnt_r[1:0]];

assign sum0a_w = xhalf_r ? px1_1d_r : px0_w;
assign sum0b_w = px0_w;
assign sum1a_w = xhalf_r ? px0_w : px1_w;
assign sum1b_w = px1_w;

assign sum0r_w = {1'b0, sum0a_w} + {1'b0, sum0b_w} + 1'b1;
assign sum1r_w = {1'b0, sum1a_w} + {1'b0, sum1b_w} + 1'b1;

assign sum2a_w = yhalf_r ? i0out_w : sum0r_w;
assign sum2b_w = sum0r_w;
assign sum3a_w = yhalf_r ? i1out_w : sum1r_w;
assign sum3b_w = sum1r_w;

assign sum2r_w = {1'b0, sum2a_w} + {1'b0, sum2b_w};
assign sum3r_w = {1'b0, sum3a_w} + {1'b0, sum3b_w};

assign fwaddr0_w = {
	yhalf_r ? wycnt_1d_r[2:0] : wycnt_r[2:0],
	(xodd_r | xhalf_r) ? {wxcnt_1d_r[1:0], xodd_r ^ xhalf_r} : {wxcnt_r[1:0], 1'b0}
};
assign fwaddr1_w = {
	yhalf_r ? wycnt_1d_r[2:0] : wycnt_r[2:0],
	(xodd_r & xhalf_r) ? {wxcnt_1d_r[1:0], 1'b1} : {wxcnt_r[1:0], ~(xodd_r | xhalf_r)}
};

assign fwxen0_w = fbuf_readdatavalid &
					~((xodd_r | xhalf_r) ? wxcnt_1d_r[2] : wxcnt_r[2]);
assign fwxen1_w = fbuf_readdatavalid &
					~((xodd_r & xhalf_r) ? wxcnt_1d_r[2] : wxcnt_r[2]);

assign fwen0_w = fwxen0_w & ~(yhalf_r ? wycnt_1d_r[3] : wycnt_r[3]);
assign fwen1_w = fwxen1_w & ~(yhalf_r ? wycnt_1d_r[3] : wycnt_r[3]);

//--------------------------------------------------------------------------------
// Mix stage (s4)
//
reg  [4:0] mraddr_r;
reg        mrlast_r;
reg  [4:0] mwaddr_r;
reg        mwen_r;
reg        waitreq_1d_r;

wire [5:0] next_mraddr_w;

wire [7:0] mrdata0_w;
wire [7:0] mrdata1_w;
wire [8:0] p0sum_w;
wire [8:0] p1sum_w;
wire [7:0] p0clip_w;
wire [7:0] p1clip_w;
reg  [7:0] p0clip_r;
reg  [7:0] p1clip_r;

wire [(MBXY_WIDTH-1):0] mwmbyx_w;
wire [(MEM_WIDTH-1):0] fb_mwaddr_w;
wire       fptr_mix_w;
wire       fptr_update_w;

// fetched memory  0 ～ 255
// pixel_data   -256 ～ 255
// (sum)        -256 ～ 510

assign next_mraddr_w = {1'b0, mraddr_r} + 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		{mrlast_r, mraddr_r} <= 6'd0;
	else if(state_r == ST_IDLE)
		{mrlast_r, mraddr_r} <= 6'd0;
	else if(state_r == ST_PREMIX || (state_r == ST_MIX && ~fbuf_waitrequest))
		{mrlast_r, mraddr_r} <= next_mraddr_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		mwaddr_r <= 5'd0;
	else if(state_r == ST_IDLE)
		mwaddr_r <= 5'd0;
	else if(state_r == ST_MIX && ~fbuf_waitrequest)
		mwaddr_r <= mraddr_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		mwen_r <= 1'b0;
	else if(state_r == ST_IDLE || (mrlast_r & ~fbuf_waitrequest))
		mwen_r <= 1'b0;
	else if(state_r == ST_PREMIX)
		mwen_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		waitreq_1d_r <= 1'b0;
	else if(state_r == ST_PREMIX)
		waitreq_1d_r <= 1'b0;
	else
		waitreq_1d_r <= fbuf_waitrequest;

assign pixel_coded = s4_coded;
assign pixel_addr = mraddr_r;

assign p0sum_w = mrdata0_w + pixel_data0;
assign p1sum_w = mrdata1_w + pixel_data1;
assign p0clip_w = p0sum_w[8] ? (pixel_data0[8] ? 8'h00 : 8'hff) : p0sum_w[7:0];
assign p1clip_w = p1sum_w[8] ? (pixel_data1[8] ? 8'h00 : 8'hff) : p1sum_w[7:0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		{p0clip_r, p1clip_r} <= 16'd0;
	else if(state_r == ST_MIX && ~(waitreq_1d_r))
		{p0clip_r, p1clip_r} <= {p0clip_w, p1clip_w};

assign mwmbyx_w = {s4_mb_y, s4_mb_x};

m2vfbagen #(
	.MEM_WIDTH (MEM_WIDTH),
	.MBX_WIDTH (MBX_WIDTH),
	.MBY_WIDTH (MBY_WIDTH)
) u_fbagen_w (
	.block (s4_block),
	.frame (fptr_mix_w),
	.mbx   (s4_mb_x),
	.x2    (s4_block[2] ? {mwaddr_r[1:0], 1'b0} : {s4_block[0], mwaddr_r[1:0]}),
	.mby   (s4_mb_y),
	.y     (s4_block[2] ? {mwaddr_r[4:2], 1'b0} : {s4_block[1], mwaddr_r[4:2]}),
	.addr  (fb_mwaddr_w)
);

assign fptr_update_w = s4_block[2] & s4_block[0] & mrlast_r & ~fbuf_waitrequest;

//--------------------------------------------------------------------------------
// Fetched data ram
//
m2vmc_fetch u_fmem(
	.address_a (state_r == ST_FETCH ? {1'b0, fwaddr0_w} : {s4_mb_intra, mraddr_r, 1'b0}),
	.address_b (state_r == ST_FETCH ? {1'b0, fwaddr1_w} : {s4_mb_intra, mraddr_r, 1'b1}),
	.clock     (clk),
	.data_a    (sum2r_w[9:2]),
	.data_b    (sum3r_w[9:2]),
	.wren_a    (state_r == ST_FETCH && fwen0_w),
	.wren_b    (state_r == ST_FETCH && fwen1_w),
	.q_a       (mrdata0_w),
	.q_b       (mrdata1_w)
);

//--------------------------------------------------------------------------------
// Frame buffer
//
assign fbuf_address = (state_r == ST_FETCH) ? fb_fraddr_w : fb_mwaddr_w;
assign fbuf_read = fren_r;
assign fbuf_write = mwen_r;
assign fbuf_writedata = waitreq_1d_r ? {p1clip_r, p0clip_r} : {p1clip_w, p0clip_w};

//--------------------------------------------------------------------------------
// Frame pointer
//
reg         fptr_page1_r;
reg [(MBXY_WIDTH-4-1):0] fptr_addrb_r;

reg  [(MBXY_WIDTH):0] fptr_addra_w;
wire [(MBXY_WIDTH-4-1):0] next_fpaddrb_w;
wire        last_fpaddrb_w;
wire [15:0] fpn_datab_w;
wire        fpn_douta_w;
wire [15:0] fpu_datab_w;
wire        fpu_douta_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		fptr_page1_r <= 1'b0;
	else if(fptr_page1_r)
		fptr_page1_r <= 1'b0;
	else if(state_r == ST_PICTURE)
		fptr_page1_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		fptr_addrb_r <= {(MBXY_WIDTH-4){1'b0}};
	else if(picture_complete)
		fptr_addrb_r <= {(MBXY_WIDTH-4){1'b0}};
	else if(fptr_page1_r)
		fptr_addrb_r <= next_fpaddrb_w[(MBXY_WIDTH-4-1):0];

assign {last_fpaddrb_w, next_fpaddrb_w} = {1'b0, fptr_addrb_r} + 1'b1;

always @*
	case(state_r)
	ST_PREMIX,
	ST_MIX:		fptr_addra_w = {1'b0, mwmbyx_w};
	ST_PREFETCH,
	ST_FETCH:	fptr_addra_w = {1'b1, frmbyx_w};
	default:	fptr_addra_w = {1'b1, fptr_address};
	endcase

assign fptr_fetch_w = sa_iframe | fpn_douta_w;
assign fptr_mix_w = ~fptr_fetch_w;

m2vmc_frameptr u_fp_num(
	.address_a (fptr_addra_w),
	.address_b ({fptr_page1_r, fptr_addrb_r}),
	.clock     (clk),
	.data_a    (fptr_mix_w),
	.data_b    (fpn_datab_w),
	.wren_a    (fptr_update_w),
	.wren_b    (fptr_page1_r),
	.q_a       (fpn_douta_w),
	.q_b       (fpn_datab_w)
);

m2vmc_frameptr u_fp_upd(
	.address_a (fptr_addra_w),
	.address_b ({fptr_page1_r, fptr_addrb_r}),
	.clock     (clk),
	.data_a    (1'b1),
	.data_b    (fptr_page1_r ? fpu_datab_w : 16'd0),
	.wren_a    (fptr_update_w),
	.wren_b    (state_r == ST_PICTURE),
	.q_a       (fpu_douta_w),
	.q_b       (fpu_datab_w)
);

assign fptr_updated = fpu_douta_w;
assign fptr_number = fpn_douta_w;

//--------------------------------------------------------------------------------
// State machine
//
always @(posedge clk or negedge reset_n)
	if(~reset_n)
		state_r <= ST_IDLE;
	else case(state_r)
	ST_IDLE:
		state_r <= picture_complete ? ST_PICTURE :
					block_start ? (
					s4_enable ? ST_PREMIX :
					(~s3_enable | s3_mb_intra) ? ST_IDLE :
					ST_CALCREF) : ST_IDLE;
	ST_PREMIX:
		state_r <= ST_MIX;
	ST_MIX:
		state_r <= (mrlast_r & ~fbuf_waitrequest) ?
					(s3_enable & ~s3_mb_intra ? ST_CALCREF : ST_IDLE) : ST_MIX;
	ST_CALCREF:
		state_r <= ST_PREFETCH;
	ST_PREFETCH:
		state_r <= ST_FETCH;
	ST_FETCH:
		state_r <= (wxcnt_r[2] & wycnt_r[3] & fbuf_readdatavalid) ?
					ST_IDLE : ST_FETCH;
	ST_PICTURE:
		state_r <= (last_fpaddrb_w & fptr_page1_r) ? ST_IDLE : ST_PICTURE;
	endcase

`ifdef SIM	// For debugging {{{
reg [31:0] state_name;
always @(state_r)
	case(state_r)
	ST_IDLE:	state_name = "Idle";
	ST_PREMIX:	state_name = "PreM";
	ST_MIX:		state_name = "Mix ";
	ST_CALCREF:	state_name = "Calc";
	ST_PREFETCH:state_name = "PreF";
	ST_FETCH:	state_name = "Fet ";
	ST_PICTURE:	state_name = "Pict";
	default:	state_name = "----";
	endcase
`endif		// }}}

endmodule
// vim:set foldmethod=marker:
