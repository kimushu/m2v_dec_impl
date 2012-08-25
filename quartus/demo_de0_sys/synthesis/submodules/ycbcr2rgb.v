//================================================================================
// Pipelined YCbCr to RGB converter
// Written by kimu_shu
//================================================================================

module ycbcr2rgb (
	input        clk,
	input        reset_n,

	input  [7:0] y,
	input  [7:0] cb,
	input  [7:0] cr,
	input        convert,

	output [7:0] r,
	output [7:0] g,
	output [7:0] b,
	output       valid
);

// YCbCr -> RGB 変換
//
// R = 1.164(Y-16)                 + 1.596(Cr-128)
// G = 1.164(Y-16) - 0.391(Cb-128) - 0.813(Cr-128)
// B = 1.164(Y-16) + 2.018(Cb-128)
//
// ここで小数を*256で整数化すると
// 1.164 ≒ 298/256
// 1.596 ≒ 409/256
// 0.391 ≒ 100/256
// 0.813 ≒ 208/256
// 2.018 ≒ 517/256
//
// 従って
// R = ( 298 * (Y-16)                  + 409 * (Cr-128) ) / 256
// G = ( 298 * (Y-16) - 100 * (Cb-128) - 208 * (Cr-128) ) / 256
// B = ( 298 * (Y-16) + 517 * (Cb-128)                  ) / 256
// ただし R,G,B は [0,255]
//
// 計算は4サイクル要する。パイプラインでは無いので、
// valid=1 となるまで次のconvert=1入力はできない。
//
// 1st: R,G,B  = -298 * 16 + 128                    (convert =1)
// 2nd: R,G,B += +298 * Y                           (addy_r  =1)
// 3rd: R += +409 * (Cr-128), G += -100 * (Cb-128)  (add2rg_r=1)
// 4th: B += +517 * (Cb-128), G += -208 * (Cr-128)  (add2bg_r=1)
// 5th:                                             (valid   =1)

reg addy_r;		// 1-delay of convert
reg add2rg_r;	// 2-delay of convert
reg add2bg_r;	// 3-delay of convert
reg valid_r;	// 4-delay of convert

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		{valid_r, add2bg_r, add2rg_r, addy_r} <= 4'd0;
	else
		{valid_r, add2bg_r, add2rg_r, addy_r} <=
			{add2bg_r, add2rg_r, addy_r, convert};

wire signed [8:0] y_w;
reg         [7:0] cb_r;
reg         [7:0] cr_r;
wire signed [8:0] cb_w;
wire signed [8:0] cr_w;

assign y_w = {1'b0, y};

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		cb_r <= 8'h80;
	else if(convert)
		cb_r <= {~cb[7], cb[6:0]};

assign cb_w = {cb_r[7], cb_r};

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		cr_r <= 8'h80;
	else if(convert)
		cr_r <= {~cr[7], cr[6:0]};

assign cr_w = {cr_r[7], cr_r};

wire signed  [8:0] rcomp_w;
wire signed [10:0] rcoef_w;
wire signed [19:0] rres_w;
wire signed  [8:0] gcomp_w;
wire signed [10:0] gcoef_w;
wire signed [19:0] gres_w;
wire signed  [8:0] bcomp_w;
wire signed [10:0] bcoef_w;
wire signed [19:0] bres_w;

assign rcomp_w = addy_r ? cr_w : convert ? y_w : -9'sd16;
assign gcomp_w = addy_r ? cb_w : add2rg_r ? cr_w : convert ? y_w : -9'sd16;
assign bcomp_w = add2rg_r ? cb_w : convert ? y_w : -9'sd16;

assign rcoef_w = convert ? 11'sd298 : addy_r ?  11'sd409 : add2rg_r ?    11'sd0 : 11'sd290;
assign gcoef_w = convert ? 11'sd298 : addy_r ? -11'sd100 : add2rg_r ? -11'sd208 : 11'sd290;
assign bcoef_w = convert ? 11'sd298 : addy_r ?    11'sd0 : add2rg_r ?  11'sd517 : 11'sd290;

ycbcr2rgb_mac u_r(
	.accum_sload (convert),
	.clock0      (clk),
	.dataa       (rcomp_w),
	.datab       (rcoef_w),
	.ena0        (1'b1),
	.result      (rres_w)
);

ycbcr2rgb_mac u_g(
	.accum_sload (convert),
	.clock0      (clk),
	.dataa       (gcomp_w),
	.datab       (gcoef_w),
	.ena0        (1'b1),
	.result      (gres_w)
);

ycbcr2rgb_mac u_b(
	.accum_sload (convert),
	.clock0      (clk),
	.dataa       (bcomp_w),
	.datab       (bcoef_w),
	.ena0        (1'b1),
	.result      (bres_w)
);

assign r = rres_w[19] ? 8'd0 : rres_w[15:8];
assign g = gres_w[19] ? 8'd0 : gres_w[15:8];
assign b = bres_w[19] ? 8'd0 : bres_w[15:8];
assign valid = valid_r;

endmodule
// vim:set foldmethod=marker:
