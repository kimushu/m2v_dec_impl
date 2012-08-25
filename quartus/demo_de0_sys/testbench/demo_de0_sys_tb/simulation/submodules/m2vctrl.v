//================================================================================
// MPEG2 Video decode Controller
// Written by kimu_shu
//================================================================================

module m2vctrl #(
	parameter
	MEM_WIDTH = 21,
	MVH_WIDTH = 16,
	MVV_WIDTH = 15,
	MBX_WIDTH = 6,
	MBY_WIDTH = 5,
	MBX_ADDER = 6
) (
	input         clk,
	input         reset_n,

	// Control port (external)
	input   [0:0] control_address,
	input         control_read,
	output [31:0] control_readdata,
	input         control_write,
	input  [31:0] control_writedata,
	output        control_readdatavalid,
	output        irq,

	// Video stream input port (external)
	input         stream_valid,
	input   [7:0] stream_data,
	output        stream_ready,

	// for side1
	output [(MVH_WIDTH-1):0] s0_data,
	output        pict_valid,		// {iframe,qstype,dcprec}
	output        mvec_h_valid,
	output        mvec_v_valid,
	output        s0_valid,
	output [(MBX_WIDTH-1):0] s0_mb_x,
	output [(MBY_WIDTH-1):0] s0_mb_y,
	output  [4:0] s0_mb_qscode,
	input   [2:0] s1_block,
	input         s1_coded,

	// for isdq
	input         ready_isdq,
	output  [5:0] run,
	output        level_sign,
	output [10:0] level_data,
	output        rl_valid,
	output        qm_valid,
	output        qm_custom,
	output        qm_intra,
	output  [7:0] qm_value,

	// for idct
	input         ready_idct,

	// for mc
	input         ready_mc,

	// for all stages
	output        softreset,
	output        block_start,
	output        block_end,
	output        picture_complete
);

//--------------------------------------------------------------------------------
// Constants
//
localparam
	IO_CONTROL   = 1,
	IO_VIDEOINFO = 2,
	IO_MAX_MBXY  = 3,
	IO_QMATRIX   = 4,
	IO_SLICEVERT = 5,
	IO_QSCODE    = 6,
	IO_MB_ADDR   = 7,
	IO_MB_QSCODE = 8,
	IO_S0INFO    = (1 << 8),
	IO_S0PICT    = IO_S0INFO | (1 << 4),
	IO_S0MVH     = IO_S0INFO | (1 << 5),
	IO_S0MVV     = IO_S0INFO | (1 << 6),
	IO_S0VALID   = IO_S0INFO | (1 << 7);
localparam
	CN_BLK_START = 0,
	CN_RLAUTO    = 1,
	CN_BLK_END   = 2,
	CN_IRQ_SEQ   = 3,
	CN_IRQ_PIC   = 4,
	CN_PAUSE     = 5,
	CN_ERROR     = 6,
	CN_SOFTRESET = 7;
localparam
	VI_WIDTH  = 13,
	VI_HEIGHT = 14,
	VI_FRATE  = 15;
localparam
	QM_INTRA  = 8,
	QM_CUSTOM = 9;
localparam
	QC_SLICE = 5,
	QC_COPY  = 6;
localparam
	RDY_S1PAT  = 0,
	RDY_ESCAPE = 1,
	RDY_RLPAIR = 2,
	RDY_ISDQ   = 3,
	RDY_IDCT   = 4,
	RDY_MC     = 5,
	RDY_BLK0   = 6,
	RDY_BLK1   = 7,
	RDY_BLK2   = 8,
	RDY_FRAME  = 9;

//--------------------------------------------------------------------------------
// Register access (control port)
//
wire [31:0] reg_status_w;
wire [31:0] reg_video_w;
wire        sel_status_w;
reg         ctrl_addr_1d_r;
reg         ctrl_read_1d_r;

assign sel_status_w = (control_address == 1'b0);

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		{ctrl_addr_1d_r, ctrl_read_1d_r} <= 2'b00;
	else
		{ctrl_addr_1d_r, ctrl_read_1d_r} <= {control_address, control_read};

assign control_readdata = ctrl_addr_1d_r ? reg_video_w : reg_status_w;
assign control_readdatavalid = ctrl_read_1d_r;

//--------------------------------------------------------------------------------
// Processor
//
reg  [15:0] adata_r;
reg  [15:0] bdata_r;
reg         softreset_r;
reg         custom_rdbuf_r;
reg         custom_align_r;
reg         custom_vld_r;
reg         custom_vldmask_r;
reg   [2:0] vld_table_r;
reg         custom_vldtbl_r;
reg         custom_inout_r;
reg         custom_rlpair_r;

wire  [9:0] iaddress_w;
wire        ireadenable_w;
wire [17:0] instruction_w;
wire [15:0] adata_w;
wire [15:0] bdata_w;
reg  [15:0] result_w;
wire  [2:0] custom_select_w;
wire        custom_start_w;
wire        custom_wait_w;
wire        custom_done_w;

wire  [3:0] ioaddr_w;

m2vsdp u_sdp(
	.clk           (clk),
	.reset_n       (reset_n),
	.softreset     (softreset_r),
	.iaddress      (iaddress_w),
	.ireadenable   (ireadenable_w),
	.instruction   (instruction_w),
	.custom_adata  (adata_w),
	.custom_bdata  (bdata_w),
	.custom_result (result_w),
	.custom_select (custom_select_w),
	.custom_start  (custom_start_w),
	.custom_enable (custom_wait_w),
	.custom_done   (custom_done_w)
);

m2vctrl_code u_code(
	.address (iaddress_w),
	.clock   (clk),
	.rden    (ireadenable_w),
	.q       (instruction_w)
);

`ifdef SIM
wire [17:0] linenumber;
m2vctrl_debug u_debug(
	.address (iaddress_w),
	.clock   (clk),
	.rden    (ireadenable_w),
	.q       (linenumber)
);
`endif

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		adata_r <= 16'd0;
	else if(custom_start_w)
		adata_r <= adata_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		bdata_r <= 16'd0;
	else if(custom_start_w)
		bdata_r <= bdata_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		custom_rdbuf_r <= 1'b0;
	else if(custom_done_w)
		custom_rdbuf_r <= 1'b0;
	else if(custom_select_w[0] & custom_start_w & ~bdata_w[5])
		custom_rdbuf_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		custom_align_r <= 1'b0;
	else if(custom_done_w)
		custom_align_r <= 1'b0;
	else if(custom_select_w[0] & custom_start_w & bdata_w[5])
		custom_align_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		custom_vld_r <= 1'b0;
	else if(custom_done_w)
		custom_vld_r <= 1'b0;
	else if(custom_select_w[1] & custom_start_w & bdata_w[5])
		custom_vld_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		custom_vldmask_r <= 1'b0;
	else if(custom_vldmask_r)
		custom_vldmask_r <= 1'b0;
	else if(custom_start_w)
		custom_vldmask_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		vld_table_r <= 3'd0;
	else if(custom_select_w[1] & custom_start_w)
		vld_table_r <= bdata_w[2:0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		custom_vldtbl_r <= 1'b0;
	else if(custom_vldtbl_r)
		custom_vldtbl_r <= 1'b0;
	else if(custom_select_w[1] & custom_start_w & ~bdata_w[5])
		custom_vldtbl_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		custom_inout_r <= 1'b0;
	else if(custom_inout_r)
		custom_inout_r <= 1'b0;
	else if(custom_select_w[2] & custom_start_w)
		custom_inout_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		custom_rlpair_r <= 1'b0;
	else if(custom_rlpair_r)
		custom_rlpair_r <= 1'b0;
	else if(custom_select_w == 3'd0 && custom_start_w)
		custom_rlpair_r <= 1'b1;

assign ioaddr_w = bdata_r[3:0];

//--------------------------------------------------------------------------------
// Control
//
reg block_start_r;
reg block_end_r;
reg pic_complete_r;
reg [7:0] pictures_r;

reg irq_seq_r;
reg irq_pic_r;
reg pause_r;
reg error_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		block_start_r <= 1'b0;
	else if(block_start_r)
		block_start_r <= 1'b0;
	else if(custom_inout_r && ioaddr_w == IO_CONTROL && adata_r[CN_BLK_START])
		block_start_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		block_end_r <= 1'b0;
	else if(block_end_r)
		block_end_r <= 1'b0;
	else if(custom_inout_r && ioaddr_w == IO_CONTROL && adata_r[CN_BLK_END])
		block_end_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		irq_seq_r <= 1'b0;
	else if(control_write & sel_status_w & control_writedata[CN_IRQ_SEQ])
		irq_seq_r <= 1'b0;
	else if(custom_inout_r && ioaddr_w == IO_CONTROL && adata_r[CN_IRQ_SEQ])
		irq_seq_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		irq_pic_r <= 1'b0;
	else if(control_write & sel_status_w & control_writedata[CN_IRQ_PIC])
		irq_pic_r <= 1'b0;
	else if(custom_inout_r && ioaddr_w == IO_CONTROL && adata_r[CN_IRQ_PIC])
		irq_pic_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		pic_complete_r <= 1'b0;
	else if(pic_complete_r)
		pic_complete_r <= 1'b0;
	else if(custom_inout_r && ioaddr_w == IO_CONTROL && adata_r[CN_IRQ_PIC])
		pic_complete_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		pause_r <= 1'b0;
	else if(control_write & sel_status_w & control_writedata[CN_PAUSE])
		pause_r <= 1'b0;
	else if(custom_inout_r && ioaddr_w == IO_CONTROL && adata_r[CN_IRQ_PIC])
		pause_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		pictures_r <= 8'd0;
	else if(softreset_r)
		pictures_r <= 8'd0;
	else if(custom_inout_r && ioaddr_w == IO_CONTROL && adata_r[CN_IRQ_PIC])
		pictures_r <= pictures_r + 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		error_r <= 1'b0;
	else if(control_write & sel_status_w & control_writedata[CN_ERROR])
		error_r <= 1'b0;
	else if(custom_inout_r && ioaddr_w == IO_CONTROL && adata_r[CN_ERROR])
		error_r <= 1'b1;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		softreset_r <= 1'b1;
	else if(control_write & sel_status_w)
		softreset_r <= control_writedata[CN_SOFTRESET];

assign softreset = softreset_r;
assign block_start = block_start_r;
assign block_end = block_end_r;
assign picture_complete = pic_complete_r;

assign reg_status_w[31:24] = pictures_r;
assign reg_status_w[23:0] = (error_r << CN_ERROR) |
						(pause_r << CN_PAUSE) |
						(irq_seq_r << CN_IRQ_SEQ) |
						(irq_pic_r << CN_IRQ_PIC);

assign irq = irq_pic_r | irq_seq_r;

//--------------------------------------------------------------------------------
// Video basic info (IO_VIDEOINFO)
//
reg [(MBX_WIDTH+4-1):0] video_wd_r;
reg [(MBY_WIDTH+4-1):0] video_ht_r;
reg [3:0] frate_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		video_wd_r <= 0;
	else if(custom_inout_r && ioaddr_w == IO_VIDEOINFO && adata_r[VI_WIDTH])
		video_wd_r <= adata_r[(MBX_WIDTH+4-1):0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		video_ht_r <= 0;
	else if(custom_inout_r && ioaddr_w == IO_VIDEOINFO && adata_r[VI_HEIGHT])
		video_ht_r <= adata_r[(MBY_WIDTH+4-1):0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		frate_r <= 4'd0;
	else if(custom_inout_r && ioaddr_w == IO_VIDEOINFO && adata_r[VI_FRATE])
		frate_r <= adata_r[3:0];

assign reg_video_w = {frate_r,
						{(10-MBY_WIDTH){1'b0}}, video_ht_r,
						{(10-MBX_WIDTH){1'b0}}, video_wd_r};

//--------------------------------------------------------------------------------
// Quant matrix (IO_QMATRIX)
//
assign qm_valid = custom_inout_r && ioaddr_w == IO_QMATRIX;
assign qm_intra = adata_r[QM_INTRA];
assign qm_custom = adata_r[QM_CUSTOM];
assign qm_value = adata_r[7:0];

//--------------------------------------------------------------------------------
// Macroblock Address (IO_MAX_MBXY, IO_SLICEVERT, IO_MB_ADDR)
//
reg [(MBX_WIDTH-1):0] max_mbx_r;
reg [(MBY_WIDTH-1):0] max_mby_r;
reg [(MBX_ADDER-1):0] cur_mbx_r;
reg [(MBY_WIDTH-1):0] cur_mby_r;
wire       mbinc_en_w;
wire       slvert_en_w;
wire [MBX_ADDER:0] addsub_mbx_w;
wire       mbxy_wait_w;

assign mbinc_en_w = custom_inout_r && (ioaddr_w == IO_MB_ADDR);
assign slvert_en_w = custom_inout_r && (ioaddr_w == IO_SLICEVERT);
assign mbxy_wait_w = ~addsub_mbx_w[MBX_ADDER];

assign addsub_mbx_w = cur_mbx_r + (mbinc_en_w ?
	{{(MBX_ADDER-6+1){1'b0}}, adata_r[5:0]} :
	{{(MBX_ADDER-MBX_WIDTH+1){1'b1}}, ~max_mbx_r});

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		{max_mby_r, max_mbx_r} <= 0;
	else if(custom_inout_r && ioaddr_w == IO_MAX_MBXY)
		{max_mby_r, max_mbx_r} <= {adata_r[(MBY_WIDTH+8-1):8], adata_r[(MBX_WIDTH-1):0]};

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		cur_mbx_r <= 0;
	else if(slvert_en_w)
		cur_mbx_r <= max_mbx_r;
	else if(mbinc_en_w || mbxy_wait_w)
		cur_mbx_r <= addsub_mbx_w[(MBX_ADDER-1):0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		cur_mby_r <= 0;
	else if(slvert_en_w)
		cur_mby_r <= adata_r[(MBY_WIDTH-1):0];
	else if(~mbinc_en_w && mbxy_wait_w)
		cur_mby_r <= cur_mby_r + 1'b1;

assign s0_mb_x = cur_mbx_r;
assign s0_mb_y = cur_mby_r;

//--------------------------------------------------------------------------------
// Side information
//
reg [4:0] sl_qs_code_r;
reg [4:0] mb_qs_code_r;

assign s0_data = adata_r[(MVH_WIDTH-1):0];
assign pict_valid = custom_inout_r && ((bdata_r & IO_S0PICT) == IO_S0PICT);
assign mvec_h_valid = custom_inout_r && ((bdata_r & IO_S0MVH) == IO_S0MVH);
assign mvec_v_valid = custom_inout_r && ((bdata_r & IO_S0MVV) == IO_S0MVV);
assign s0_valid = custom_inout_r && ((bdata_r & IO_S0VALID) == IO_S0VALID);

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		sl_qs_code_r <= 5'd0;
	else if(custom_inout_r && ioaddr_w == IO_QSCODE && adata_r[QC_SLICE])
		sl_qs_code_r <= adata_r[4:0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		mb_qs_code_r <= 5'd0;
	else if(custom_inout_r && ioaddr_w == IO_QSCODE && adata_r[QC_COPY])
		mb_qs_code_r <= sl_qs_code_r;
	else if(custom_inout_r && ioaddr_w == IO_QSCODE && ~adata_r[QC_SLICE])
		mb_qs_code_r <= adata_r[4:0];

assign s0_mb_qscode = mb_qs_code_r;

//--------------------------------------------------------------------------------
// VLC decoder
//
wire        rlvld_w;
wire [13:0] symbol_data_w;
wire        symbol_valid_w;
wire        symbol_nextbit_w;
wire  [2:0] vld_width_w;
wire        vld_shift_w;
wire [12:0] buffer_data_w;
wire        buffer_valid_w;

m2vvld u_vld(
	.clk            (clk),
	.reset_n        (reset_n),
	.softreset      (softreset_r),
	.vld_table      (vld_table_r),
	.vld_decode     ((custom_vld_r & custom_vldmask_r) | rlvld_w),
	.buffer_data    (buffer_data_w),
	.buffer_valid   (buffer_valid_w),
	.vld_width      (vld_width_w),
	.vld_shift      (vld_shift_w),
	.symbol_data    (symbol_data_w),
	.symbol_valid   (symbol_valid_w),
	.symbol_nextbit (symbol_nextbit_w)
);

assign custom_done_w = custom_inout_r |
						((custom_rdbuf_r | custom_align_r) & buffer_valid_w & ~vld_shift_w) |
						(custom_vld_r & symbol_valid_w) |
						custom_vldtbl_r |
						custom_rlpair_r;

//--------------------------------------------------------------------------------
// Block coefficients decoding
//
reg  [2:0] rl_state_r;
reg        rl_wmask_r;
reg  [4:0] rl_run_r;
reg  [5:0] rl_level_r;
reg        rl_nextbit_r;
reg        rl_valid_r;
wire       rl_shift1_w;

localparam
	RLST_STOP   = 3'd0,
	RLST_VLD    = 3'd1,
	RLST_SEND   = 3'd2,
	RLST_ESCAPE = 3'd3,
	RLST_WAIT   = 3'd4;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		rl_state_r <= RLST_STOP;
	else if(softreset_r)
		rl_state_r <= RLST_STOP;
	else case(rl_state_r)
	RLST_STOP,
	RLST_ESCAPE:	rl_state_r <=
		(custom_inout_r && ioaddr_w == IO_CONTROL && adata_r[CN_RLAUTO]) ?
		RLST_VLD : rl_state_r;
	RLST_VLD:	rl_state_r <= ~symbol_valid_w ? RLST_VLD :
								symbol_data_w[11] ? RLST_ESCAPE :
								symbol_data_w[12] ? RLST_STOP :
								RLST_SEND;
	RLST_SEND:	rl_state_r <= (buffer_valid_w & ~vld_shift_w) ? RLST_WAIT : RLST_SEND;
	RLST_WAIT:	rl_state_r <= RLST_VLD;
	endcase

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		rl_wmask_r <= 1'b1;
	else if(symbol_valid_w)
		rl_wmask_r <= 1'b1;
	else if(rl_state_r == RLST_VLD)
		rl_wmask_r <= 1'b0;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		rl_run_r <= 5'd0;
	else if(symbol_valid_w)
		rl_run_r <= symbol_data_w[10:6];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		rl_level_r <= 6'd0;
	else if(symbol_valid_w)
		rl_level_r <= symbol_data_w[5:0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		rl_nextbit_r <= 1'b0;
	else if(symbol_valid_w)
		rl_nextbit_r <= symbol_nextbit_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		rl_valid_r <= 1'b0;
	else if(rl_valid_r & buffer_valid_w)
		rl_valid_r <= 1'b0;
	else if(rl_state_r == RLST_VLD && symbol_valid_w && symbol_data_w[12:11] == 2'b00)
		rl_valid_r <= 1'b1;

assign rlvld_w = rl_wmask_r & (rl_state_r == RLST_VLD);
assign rl_shift1_w = (rl_state_r == RLST_SEND) & buffer_valid_w;

assign run = (rl_state_r == RLST_SEND) ?
				{1'b0, rl_run_r} : bdata_r[5:0];
assign level_sign = (rl_state_r == RLST_SEND) ? rl_nextbit_r : adata_r[11];
assign level_data = (rl_state_r == RLST_SEND) ? {5'd0, rl_level_r} :
					adata_r[10:0];
assign rl_valid = (rl_valid_r && buffer_valid_w) || custom_rlpair_r;

//--------------------------------------------------------------------------------
// Data buffer
//
wire        parser_shift_w;
wire  [3:0] parser_width_w;
wire        parser_align_w;

m2vstbuf u_stbuf(
	.clk          (clk),
	.reset_n      (reset_n),
	.softreset    (softreset_r),
	.stream_valid (stream_valid),
	.stream_data  (stream_data),
	.stream_ready (stream_ready),
	.parser_shift (parser_shift_w),
	.parser_width (parser_width_w),
	.parser_align (parser_align_w),
	.vld_width    (vld_width_w),
	.vld_shift    (vld_shift_w),
	.buffer_data  (buffer_data_w),
	.buffer_valid (buffer_valid_w)
);

assign parser_shift_w = (rl_shift1_w | (buffer_valid_w & custom_rdbuf_r & bdata_r[4])) & ~vld_shift_w;
assign parser_width_w = rl_shift1_w ? 4'd1 : bdata_r[3:0];
assign parser_align_w = buffer_valid_w & custom_align_r;

always @*
	if(custom_vld_r)
		result_w = {2'd0, symbol_data_w};
	else if(custom_inout_r)
		case(ioaddr_w)
		IO_MB_ADDR:
			result_w = {15'bx, mbxy_wait_w};
		IO_CONTROL:
			result_w = {6'bx,
						~pause_r,
						s1_block,
						ready_mc,
						ready_idct,
						ready_isdq,
						(rl_state_r == RLST_STOP),
						(rl_state_r == RLST_ESCAPE),
						s1_coded};
		default:
			result_w = 16'bx;
		endcase
	else	// custom_rdbuf_r
		case(bdata_r[3:0])
		4'd0:	result_w = {16'd0                      };
		4'd1:	result_w = {15'd0, buffer_data_w[12]   };
		4'd2:	result_w = {14'd0, buffer_data_w[12:11]};
		4'd3:	result_w = {13'd0, buffer_data_w[12:10]};
		4'd4:	result_w = {12'd0, buffer_data_w[12: 9]};
		4'd5:	result_w = {11'd0, buffer_data_w[12: 8]};
		4'd6:	result_w = {10'd0, buffer_data_w[12: 7]};
		4'd7:	result_w = { 9'd0, buffer_data_w[12: 6]};
		4'd8:	result_w = { 8'd0, buffer_data_w[12: 5]};
		4'd9:	result_w = { 7'd0, buffer_data_w[12: 4]};
		4'd10:	result_w = { 6'd0, buffer_data_w[12: 3]};
		4'd11:	result_w = { 5'd0, buffer_data_w[12: 2]};
		4'd12:	result_w = { 4'd0, buffer_data_w[12: 1]};
		4'd13:	result_w = { 3'd0, buffer_data_w[12: 0]};
		default:result_w = 16'bx;
		endcase

endmodule
// vim:set foldmethod=marker:
