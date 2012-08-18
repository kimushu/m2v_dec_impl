//================================================================================
// MPEG2 Video Stream Decode Processor (Submodule of m2vctrl)
// Written by kimu_shu
//================================================================================

module m2vsdp #(
	parameter
	IADR_WIDTH = 10,
	DATA_WIDTH = 16,
	IMED_WIDTH = 9,
	CSEL_WIDTH = 3,
	RSEL_WIDTH = 3,
	INST_WIDTH = (DATA_WIDTH+2)
) (
	input  clk,
	input  reset_n,
	input  softreset,

	output [(IADR_WIDTH-1):0] iaddress,
	output                    ireadenable,
	input  [(INST_WIDTH-1):0] instruction,

	output [(DATA_WIDTH-1):0] custom_adata,
	output [(DATA_WIDTH-1):0] custom_bdata,
	input  [(DATA_WIDTH-1):0] custom_result,
	output [(CSEL_WIDTH-1):0] custom_select,
	output                    custom_start,
	output                    custom_enable,
	input                     custom_done
);

reg [(DATA_WIDTH-1):0] adata_r;
reg [(DATA_WIDTH-1):0] bdata_r;
reg [(IADR_WIDTH-1):0] ip_r;
reg nop_r;
reg stall_r;
reg [(DATA_WIDTH-1):0] reg_r [0:((1<<RSEL_WIDTH)-1)];
reg zf_r;
reg cf_r;

localparam
	G_WIDTH  = 2,
	G_MOVR0  = 2'b01,
	G_OTHERS = 2'b00,
	G_CUSTOM = 2'b10,
	G_JUMPS  = 2'b11;

localparam
	SC_WIDTH = 3,
	SC_MOV = 3'b000,
	SC_ADD = 3'b001,
	SC_CMP = 3'b010,
	SC_SUB = 3'b011,
	SC_AND = 3'b100,
	SC_TST = 3'b101,
	SC_OR  = 3'b110,
	SC_UNI = 3'b111;

localparam
	SSC_WIDTH = 3,
	SSC_NOT = 3'bz0z,
	SSC_LSR = 3'b010,
	SSC_LSL = 3'b011,
	SSC_ROR = 3'b110,
	SSC_ROL = 3'b111;

localparam
	JC_WIDTH = 3,
	JC_JMP = 3'b00z,
	JC_JZ  = 3'b010,
	JC_JNZ = 3'b011,
	JC_JC  = 3'b100,
	JC_JNC = 3'b101;

wire [1:0] group_w;
wire [2:0] subcode_w;
wire [2:0] subsubcode_w;
wire [(RSEL_WIDTH-1):0] rd_w;
wire imed_w;
wire [(RSEL_WIDTH-1):0] rs_w;
wire [(DATA_WIDTH-1):0] fk_w;
wire [(IMED_WIDTH-1):0] k_w;
wire [(CSEL_WIDTH-1):0] csel_w;
reg  [(DATA_WIDTH-IMED_WIDTH-1):0] kext_w;

assign group_w = instruction[(INST_WIDTH-1):(INST_WIDTH-2)];
assign subcode_w = instruction[(INST_WIDTH-3):(INST_WIDTH-5)];
assign subsubcode_w = instruction[IMED_WIDTH:(IMED_WIDTH-2)];
assign rd_w = instruction[(RSEL_WIDTH+IMED_WIDTH):(IMED_WIDTH+1)];
assign imed_w = instruction[IMED_WIDTH];
assign rs_w = instruction[(RSEL_WIDTH-1):0];
assign fk_w = instruction[(DATA_WIDTH-1):0];
assign k_w = instruction[(IMED_WIDTH-1):0];
assign csel_w = instruction[(INST_WIDTH-3):(INST_WIDTH-CSEL_WIDTH-2)];

always @(subcode_w, k_w)
	casez(subcode_w)
	SC_MOV,
	SC_ADD,
	SC_CMP,
	SC_SUB:	kext_w = {(DATA_WIDTH-IMED_WIDTH){k_w[IMED_WIDTH-1]}};
	SC_TST,
	SC_AND,
	SC_OR:	kext_w = {(DATA_WIDTH-IMED_WIDTH){1'b0}};
	default:kext_w = {(DATA_WIDTH-IMED_WIDTH){1'bx}};
	endcase

`ifdef SIM
reg [(8*3-1):0] mnemonic_1st;
reg [(8*3-1):0] mnemonic_2nd;

always @(instruction, nop_r)
	if(nop_r)
		mnemonic_1st = "nop";
	else if(group_w == G_MOVR0)
		mnemonic_1st = "mov";
	else if(group_w == G_CUSTOM)
		mnemonic_1st = "cst";
	else if(group_w == G_JUMPS)
		casez(subcode_w)
		JC_JMP:	mnemonic_1st = "jmp";
		JC_JZ:	mnemonic_1st = "jz ";
		JC_JNZ:	mnemonic_1st = "jnz";
		JC_JC:	mnemonic_1st = "jc ";
		JC_JNC:	mnemonic_1st = "jnc";
		default:mnemonic_1st = "***";
		endcase
	else if(group_w == G_OTHERS)
		casez(subcode_w)
		SC_MOV:	mnemonic_1st = "mov";
		SC_ADD:	mnemonic_1st = "add";
		SC_CMP:	mnemonic_1st = "cmp";
		SC_SUB:	mnemonic_1st = "sub";
		SC_TST:	mnemonic_1st = "tst";
		SC_AND:	mnemonic_1st = "and";
		SC_OR:	mnemonic_1st = "or ";
		SC_UNI:
			casez(subsubcode_w)
			SSC_NOT:	mnemonic_1st = "not";
			SSC_LSR:	mnemonic_1st = "lsr";
			SSC_LSL:	mnemonic_1st = "lsl";
			SSC_ROR:	mnemonic_1st = "ror";
			SSC_ROL:	mnemonic_1st = "rol";
			default:	mnemonic_1st = "***";
			endcase
		default:mnemonic_1st = "***";
		endcase
	else
		mnemonic_1st = "***";

always @(posedge clk) mnemonic_2nd <= mnemonic_1st;
`endif

//--------------------------------------------------------------------------------
// Instruction fetch
//
// reg movr0_r;
reg cst_r;
reg mov_r;
reg add_r;
reg sub_r;
reg and_r;
reg or_r;
reg not_r;
reg shr_r;
reg shl_r;
reg usecf_r;
reg store_r;
reg jxz_r;
reg jxc_r;
reg jnx_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n) begin
		// movr0_r <= 1'b0;
		cst_r <= 1'b0;
	end else begin
		// movr0_r <= (~softreset & ~nop_r) && (group_w == G_MOVR0);
		cst_r <= (~softreset & ~nop_r & ~custom_done) && (group_w == G_CUSTOM);
	end

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		{mov_r, add_r, sub_r, and_r, or_r} <= 5'b00000;
	else if((softreset | nop_r) || (group_w != G_OTHERS))
		{mov_r, add_r, sub_r, and_r, or_r} <= 5'b00000;
	else casez(subcode_w)
		SC_MOV:		{mov_r, add_r, sub_r, and_r, or_r} <= 5'b10000;
		SC_ADD:		{mov_r, add_r, sub_r, and_r, or_r} <= 5'b01000;
		SC_SUB,
		SC_CMP:		{mov_r, add_r, sub_r, and_r, or_r} <= 5'b00100;
		SC_AND,
		SC_TST:		{mov_r, add_r, sub_r, and_r, or_r} <= 5'b00010;
		SC_OR:		{mov_r, add_r, sub_r, and_r, or_r} <= 5'b00001;
		SC_UNI:		{mov_r, add_r, sub_r, and_r, or_r} <= 5'b00000;
	endcase

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		{not_r, shr_r, shl_r} <= 3'b000;
	else if((softreset | nop_r) || (group_w != G_OTHERS) ||
		(subcode_w != SC_UNI))
		{not_r, shr_r, shl_r} <= 3'b000;
	else casez(subsubcode_w)
		SSC_NOT:	{not_r, shr_r, shl_r} <= 3'b100;
		SSC_LSR,
		SSC_ROR:	{not_r, shr_r, shl_r} <= 3'b010;
		SSC_LSL,
		SSC_ROL:	{not_r, shr_r, shl_r} <= 3'b001;
	endcase

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		{jxz_r, jxc_r, jnx_r} <= 3'b000;
	else if((softreset | nop_r) || (group_w != G_JUMPS))
		{jxz_r, jxc_r, jnx_r} <= 3'b000;
	else casez(subcode_w)
		JC_JMP:	{jxz_r, jxc_r, jnx_r} <= 3'b001;
		JC_JZ:	{jxz_r, jxc_r, jnx_r} <= 3'b100;
		JC_JNZ:	{jxz_r, jxc_r, jnx_r} <= 3'b101;
		JC_JC:	{jxz_r, jxc_r, jnx_r} <= 3'b010;
		JC_JNC:	{jxz_r, jxc_r, jnx_r} <= 3'b011;
	endcase

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		store_r <= 1'b0;
	else if(softreset | nop_r | custom_done)
		store_r <= 1'b0;
	else if(~stall_r)
		casez(group_w)
		G_JUMPS:
			store_r <= 1'b0;
		G_OTHERS:
			casez(subcode_w)
			SC_CMP,
			SC_TST:
				store_r <= 1'b0;
			default:
				store_r <= 1'b1;
			endcase
		default:
			store_r <= 1'b1;
		endcase

always @(posedge clk)
	casez(subsubcode_w)
	SSC_ROR,
	SSC_ROL:
		usecf_r <= 1'b1;
	default:
		usecf_r <= 1'b0;
	endcase

//--------------------------------------------------------------------------------
// Instruction pointer
//
reg  stall_w;
wire dojump_w;

always @*
	if(~reset_n | softreset | nop_r)
		stall_w = 1'b0;
	else if(group_w == G_CUSTOM)
		stall_w = ~custom_done;
	else if(group_w == G_JUMPS)
		stall_w = ~stall_r;
	else
		stall_w = 1'b0;

assign dojump_w = ((jxz_r & zf_r) | (jxc_r & cf_r)) ^ jnx_r;

`ifdef SIM
initial ip_r = 0;
`endif

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		{ip_r, nop_r} <= {{IADR_WIDTH{1'b0}}, 1'b1};
	else if(softreset)
		{ip_r, nop_r} <= {{IADR_WIDTH{1'b0}}, 1'b1};
	else if(~nop_r && dojump_w)
		{ip_r, nop_r} <= {adata_r[(IADR_WIDTH-1):0], 1'b1};
	else if(~stall_w)
		{ip_r, nop_r} <= {ip_r + 1'b1, 1'b0};

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		stall_r <= 1'b0;
	else if(softreset)
		stall_r <= 1'b0;
	else
		stall_r <= stall_w;

assign iaddress = ip_r;
assign ireadenable = ~stall_w;

//--------------------------------------------------------------------------------
// Custom instruction
//
reg cst_mask_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		cst_mask_r <= 1'b1;
	else if(softreset | custom_done)
		cst_mask_r <= 1'b1;
	else if(cst_r)
		cst_mask_r <= 1'b0;

assign custom_adata = adata_r;
assign custom_bdata = bdata_r;
assign custom_select = csel_w;
assign custom_start = cst_r & cst_mask_r;
assign custom_enable = cst_r;

//--------------------------------------------------------------------------------
// ALU
//
wire [DATA_WIDTH:0] result_add_w;
wire [DATA_WIDTH:0] result_sub_w;
wire [(DATA_WIDTH-1):0] result_and_w;
wire [(DATA_WIDTH-1):0] result_or_w;
wire [(DATA_WIDTH-1):0] result_not_w;
wire [(DATA_WIDTH-1):0] result_shr_w;
wire [(DATA_WIDTH-1):0] result_shl_w;
reg  [(DATA_WIDTH-1):0] result_w;

assign result_add_w = {1'b0, adata_r} + bdata_r;
assign result_sub_w = {1'b0, adata_r} - bdata_r;
assign result_and_w = adata_r & bdata_r;
assign result_or_w  = adata_r | bdata_r;
assign result_not_w = ~adata_r;
assign result_shr_w = {cf_r & usecf_r, adata_r[(DATA_WIDTH-1):1]};
assign result_shl_w = {adata_r[(DATA_WIDTH-2):0], cf_r & usecf_r};

always @*
	if(cst_r & custom_done)
		result_w = custom_result;
	else if(add_r)
		result_w = result_add_w[(DATA_WIDTH-1):0];
	else if(sub_r)
		result_w = result_sub_w[(DATA_WIDTH-1):0];
	else if(and_r)
		result_w = result_and_w;
	else if(or_r)
		result_w = result_or_w;
	else if(not_r)
		result_w = result_not_w;
	else if(shr_r)
		result_w = result_shr_w;
	else if(shl_r)
		result_w = result_shl_w;
	else if(mov_r)
		result_w = bdata_r;
	else
		result_w = adata_r;

//--------------------------------------------------------------------------------
// Register store
//
reg [(RSEL_WIDTH-1):0] stsel_r;

`ifdef SIM
initial stsel_r = 0;
`endif
always @(posedge clk) stsel_r <= (group_w == G_MOVR0) ? 3'd0 : rd_w;

always @(posedge clk)
	if(~nop_r & store_r)
		reg_r[stsel_r] <= result_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		zf_r <= 1'b0;
	else if(softreset)
		zf_r <= 1'b0;
	else if(~nop_r)
		case({add_r, sub_r, and_r})
		3'b100:	zf_r <= ~|(result_add_w[(DATA_WIDTH-1):0]);
		3'b010:	zf_r <= ~|(result_sub_w[(DATA_WIDTH-1):0]);
		3'b001:	zf_r <= ~|result_and_w;
		endcase

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		cf_r <= 1'b0;
	else if(softreset)
		cf_r <= 1'b0;
	else if(~nop_r)
		case({add_r, sub_r, shr_r, shl_r})
		4'b1000:	cf_r <= result_add_w[DATA_WIDTH];
		4'b0100:	cf_r <= result_sub_w[DATA_WIDTH];
		4'b0010:	cf_r <= adata_r[0];
		4'b0001:	cf_r <= adata_r[DATA_WIDTH - 1];
		endcase

//--------------------------------------------------------------------------------
// Data fetch
//
always @(posedge clk)
	if(~nop_r & ~stall_r)
		adata_r <= (group_w == G_MOVR0 || group_w == G_JUMPS) ? fk_w :
					(store_r && stsel_r == rd_w) ? result_w : reg_r[rd_w];

always @(posedge clk)
	if(~nop_r & ~stall_r)
		bdata_r <= imed_w ? {kext_w, k_w} :
					(store_r && stsel_r == rs_w) ? result_w : reg_r[rs_w];

endmodule
// vim:set foldmethod=marker:
