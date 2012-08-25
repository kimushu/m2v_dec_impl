//================================================================================
// MPEG2 Video Inverse DCT
// Written by kimu_shu
//================================================================================

module m2vidct(
	input         clk,
	input         reset_n,
	input         softreset,

	output        ready_idct,
	input         block_start,
	input         s1_enable,
	input         s2_enable,

	output        coef_next,
	input         coef_sign,
	input  [11:0] coef_data,

	input         pixel_coded,
	input   [4:0] pixel_addr,
	output  [8:0] pixel_data0,
	output  [8:0] pixel_data1
);

// see design document: ../doc/m2vidct.xlsx

//--------------------------------------------------------------------------------
// Common
//
reg         busy_r;
reg         wpage_r;
reg         rpage_r;
reg   [7:0] taddr_r;
wire [71:0] romdata_w;
wire [17:0] coefxp_w;
wire [17:0] coefxm_w;
wire [17:0] coefyp_w;
wire [17:0] coefym_w;
wire  [1:0] t0idx_w;
wire  [1:0] t1idx_w;
wire  [1:0] midx_w;
wire        imed_w;
wire        save_w;
wire        askip_w;
wire        final_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		busy_r <= 1'b0;
	else if(softreset || final_w)
		busy_r <= 1'b0;
	else if(block_start && (s1_enable | s2_enable))
		busy_r <= 1'b1;

assign ready_idct = ~busy_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		wpage_r <= 1'b0;
	else if(softreset)
		wpage_r <= 1'b0;
	else if(block_start)
		wpage_r <= ~wpage_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		rpage_r <= 1'b1;
	else if(softreset)
		rpage_r <= 1'b1;
	else if(block_start)
		rpage_r <= ~rpage_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		taddr_r <= 8'd0;
	else if(softreset || final_w)
		taddr_r <= 8'd0;
	else if(busy_r)
		taddr_r <= {taddr_r[7:5] + askip_w, askip_w ? 5'd0 : taddr_r[4:0] + 1'd1};

m2vidct_rom u_rom(
	.address (taddr_r),
	.clock   (clk),
	.q       (romdata_w)
);

assign coefxp_w = {{2{romdata_w[15]}}, romdata_w[15: 0]};
assign coefxm_w = {{2{romdata_w[31]}}, romdata_w[31:16]};
assign coefyp_w = {{2{romdata_w[47]}}, romdata_w[47:32]};
assign coefym_w = {{2{romdata_w[63]}}, romdata_w[63:48]};
assign t0idx_w  = taddr_r[1:0];
assign t1idx_w  = romdata_w[65:64];
assign midx_w   = romdata_w[67:66];
assign imed_w   = romdata_w[68];
assign save_w   = romdata_w[69];
assign askip_w  = romdata_w[70];
assign final_w  = romdata_w[71];

//--------------------------------------------------------------------------------
// Column
//
reg  [31:0] ctram0_r [0:3];
reg  [31:0] ctram1_r [0:3];
wire [35:0] cm0res_w;
wire [35:0] cm1res_w;
wire [31:0] ca0a_w, ca0b_w;
wire [31:0] ca0s_w;
wire [31:0] ca1a_w, ca1b_w;
wire        ca1c_w;
wire [31:0] ca1s_w;
wire [31:0] ct0d_w, ct1d_w;

assign ct0d_w = ctram0_r[t0idx_w];
assign ct1d_w = ctram1_r[t1idx_w];

assign ca0a_w = imed_w ? {21'd0, taddr_r[1], 10'd0} : ct0d_w;
assign ca0b_w = save_w ? ct1d_w : cm0res_w[31:0];
assign ca0s_w = ca0a_w + ca0b_w;
assign ca1a_w = imed_w ? {21'd0, taddr_r[1], 10'd0} :
				(save_w & taddr_r[1]) ? ct0d_w : ct1d_w;
assign ca1b_w = save_w ? (taddr_r[1] ? ~ct1d_w : ~ct0d_w) :
				cm1res_w[31:0];
assign ca1c_w = save_w;
assign ca1s_w = ca1a_w + ca1b_w + ca1c_w;

always @(posedge clk) ctram0_r[t0idx_w] <= ca0s_w;
always @(posedge clk) ctram1_r[t1idx_w] <= ca1s_w;

m2vidct_mult u_rm0(
	.clock  (clk),
	.dataa  (coef_sign ? coefxm_w : coefxp_w),
	.datab  ({6'd0, coef_data}),
	.result (cm0res_w)
);

m2vidct_mult u_rm1(
	.clock  (clk),
	.dataa  (coef_sign ? coefym_w : coefyp_w),
	.datab  ({6'd0, coef_data}),
	.result (cm1res_w)
);

assign coef_next = taddr_r[0] & ~taddr_r[4];

//--------------------------------------------------------------------------------
// Intermediate data
//
reg   [2:0] irhigh_r;		// also used in fram
wire [17:0] iwrdata0_w;
wire [17:0] iwrdata1_w;
wire  [5:0] iwraddr_w;
wire  [6:0] irdaddr_w;
wire [17:0] coldata_w;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		irhigh_r <= 3'd0;
	else if(taddr_r[4])
		irhigh_r <= taddr_r[7:5];

assign iwrdata0_w = ca0s_w[28:11];
assign iwrdata1_w = ca1s_w[28:11];
assign iwraddr_w = {wpage_r, irhigh_r, t1idx_w};
assign irdaddr_w = {rpage_r, taddr_r[3:1], midx_w, taddr_r[7]};

m2vidct_iram u_iram(
	.clock     (clk),
	.data      ({iwrdata1_w, iwrdata0_w}),
	.rdaddress (irdaddr_w),
	.wraddress (iwraddr_w),
	.wren      (save_w),
	.q         (coldata_w)
);

//--------------------------------------------------------------------------------
// Row
//
reg  [31:0] rtram0_r [0:3];
reg  [31:0] rtram1_r [0:3];
wire [35:0] rm0res_w;
wire [35:0] rm1res_w;
wire [31:0] ra0a_w, ra0b_w;
wire [31:0] ra0s_w;
wire [31:0] ra1a_w, ra1b_w;
wire        ra1c_w;
wire [31:0] ra1s_w;
wire [31:0] rt0d_w, rt1d_w;

assign rt0d_w = rtram0_r[t0idx_w];
assign rt1d_w = rtram1_r[t1idx_w];

assign ra0a_w = imed_w ? {12'd0, taddr_r[1], 19'd0} : rt0d_w;
assign ra0b_w = save_w ? rt1d_w : rm0res_w[31:0];
assign ra0s_w = ra0a_w + ra0b_w;
assign ra1a_w = imed_w ? {12'd0, taddr_r[1], 19'd0} :
				(save_w & taddr_r[1]) ? rt0d_w : rt1d_w;
assign ra1b_w = save_w ? (taddr_r[1] ? ~rt1d_w : ~rt0d_w) :
				rm1res_w[31:0];
assign ra1c_w = save_w;
assign ra1s_w = ra1a_w + ra1b_w + ra1c_w;

always @(posedge clk) rtram0_r[t0idx_w] <= ra0s_w;
always @(posedge clk) rtram1_r[t1idx_w] <= ra1s_w;

m2vidct_mult u_cm0(
	.clock  (clk),
	.dataa  (coefxp_w),
	.datab  (coldata_w),
	.result (rm0res_w)
);

m2vidct_mult u_cm1(
	.clock  (clk),
	.dataa  (coefyp_w),
	.datab  (coldata_w),
	.result (rm1res_w)
);

//--------------------------------------------------------------------------------
// Final data
//
reg        teven_r;
wire [3:0] byteena_w;
wire [8:0] clip0_w;
wire [8:0] clip1_w;
wire [5:0] fwraddr_w;
wire [6:0] frdaddr_w;

function [8:0] clip12to9;
	input [11:0] value;
begin
	if(value[11])
		clip12to9 = {1'b1, &value[10:8] ? value[7:0] : 8'h00};
	else
		clip12to9 = {1'b0, |value[10:8] ? 8'hff : value[7:0]};
end
endfunction

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		teven_r <= 1'b0;
	else
		teven_r <= taddr_r[0];

assign byteena_w = {teven_r, {2{taddr_r[0]}}, teven_r};
assign clip0_w = clip12to9(ra0s_w[31:20]);
assign clip1_w = clip12to9(ra1s_w[31:20]);
assign fwraddr_w = {wpage_r, 1'b1, irhigh_r, t1idx_w[1]};
assign frdaddr_w = {rpage_r, pixel_coded,
					pixel_addr[4:2], ^pixel_addr[1:0], pixel_addr[1]};

m2vidct_fram u_fram(
	.byteena_a (byteena_w),
	.clock     (clk),
	.data      ({clip1_w, clip1_w, clip0_w, clip0_w}),
	.rdaddress (frdaddr_w),
	.wraddress (fwraddr_w),
	.wren      (save_w),
	.q         ({pixel_data1, pixel_data0})
);

endmodule

