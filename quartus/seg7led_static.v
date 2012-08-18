//================================================================================
// 7-segment LED driver (Static drive)
// Written by kimu_shu
//================================================================================

module seg7led_static #(
	parameter
	DIGITS     = 1,
	ACTIVE_LOW = 1
) (
	input         clk,
	input         reset_n,

	input   [1:0] ctrl_address,
	input         ctrl_write,
	input  [31:0] ctrl_writedata,

	output [(DIGITS-1):0] seg_a,
	output [(DIGITS-1):0] seg_b,
	output [(DIGITS-1):0] seg_c,
	output [(DIGITS-1):0] seg_d,
	output [(DIGITS-1):0] seg_e,
	output [(DIGITS-1):0] seg_f,
	output [(DIGITS-1):0] seg_g,
	output [(DIGITS-1):0] seg_dp
);

reg [(DIGITS-1):0] on_r;
reg [(DIGITS-1):0] dp_r;
reg [(DIGITS*4-1):0] data_r;

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		on_r <= {(DIGITS){1'b1}};
	else if(ctrl_address == 2'd1 && ctrl_write)
		on_r <= ctrl_writedata[(DIGITS-1):0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		dp_r <= {(DIGITS){1'b0}};
	else if(ctrl_address == 2'd2 && ctrl_write)
		dp_r <= ctrl_writedata[(DIGITS-1):0];

always @(posedge clk or negedge reset_n)
	if(~reset_n)
		data_r <= {(DIGITS*4){1'b0}};
	else if(ctrl_address == 2'd0 && ctrl_write)
		data_r <= ctrl_writedata[(DIGITS*4-1):0];

wire polar_w;
generate
	if(ACTIVE_LOW)
		assign polar_w = 1'b1;
	else
		assign polar_w = 1'b0;
endgenerate

generate
	genvar i;
	for(i = 0; i < DIGITS; i = i + 1) begin: digit
		reg [6:0] segs_w;
		always @*
			if(~on_r[i])
				segs_w = 7'b0000000;
			else case(data_r[i*4+3:i*4])
			4'h0:	segs_w = 7'b0000001;
			4'h1:	segs_w = 7'b1001111;
			4'h2:	segs_w = 7'b0010010;
			4'h3:	segs_w = 7'b0000110;
			4'h4:	segs_w = 7'b1001100;
			4'h5:	segs_w = 7'b0100100;
			4'h6:	segs_w = 7'b0100000;
			4'h7:	segs_w = 7'b0001111;
			4'h8:	segs_w = 7'b0000000;
			4'h9:	segs_w = 7'b0000100;
			4'ha:	segs_w = 7'b0001000;
			4'hb:	segs_w = 7'b1100000;
			4'hc:	segs_w = 7'b1110010;
			4'hd:	segs_w = 7'b1000010;
			4'he:	segs_w = 7'b0110000;
			4'hf:	segs_w = 7'b0111000;
			endcase
		assign seg_a[i] = segs_w[6] ^ polar_w;
		assign seg_b[i] = segs_w[5] ^ polar_w;
		assign seg_c[i] = segs_w[4] ^ polar_w;
		assign seg_d[i] = segs_w[3] ^ polar_w;
		assign seg_e[i] = segs_w[2] ^ polar_w;
		assign seg_f[i] = segs_w[1] ^ polar_w;
		assign seg_g[i] = segs_w[0] ^ polar_w;
		assign seg_dp[i] = (dp_r[i] & on_r[i]) ^ polar_w;
	end
endgenerate

endmodule

