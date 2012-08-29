//================================================================================
// Testbench for m2vidct
//================================================================================
`timescale 1ns / 1ps

`define CLOCK_PERIOD	10

module test_m2vidct;

`include "../common.vh"

wire        ready_idct_w;
reg         block_start_r;

reg         s2_enable_r;
reg         s2_coded_r;

reg         s3_enable_r;
reg         s3_coded_r;

reg         s4_enable_r;
reg         s4_coded_r;

wire        coef_next_w;
reg         coef_sign_r;
reg  [11:0] coef_data_r;

reg         pixel_coded_r;
reg   [4:0] pixel_addr_r;
wire  [8:0] pixel_data0_w;
wire  [8:0] pixel_data1_w;

always @(negedge reset_n) begin
	block_start_r <= 1'b0;

	s2_enable_r <= 1'bx;
	s2_coded_r <= 1'bx;

	s3_enable_r <= 1'b0;
	s3_coded_r <= 1'b0;

	coef_sign_r <= 1'bx;
	coef_data_r <= 12'bx;

	pixel_coded_r <= 1'bx;
	pixel_addr_r <= 5'bx;
end

export "DPI-C" task read_ready_idct;
task read_ready_idct;
	output ready_idct;
begin
	ready_idct = ready_idct_w;
end
endtask

export "DPI-C" task pre_block_start;
task pre_block_start;
begin
	@(posedge clk);
	s3_enable_r <= s2_enable_r;
	s3_coded_r <= s2_coded_r;
	s4_enable_r <= s4_enable_r;
	s4_coded_r <= s4_coded_r;
end
endtask

export "DPI-C" task block_start;
task block_start;
begin
	block_start_r <= 1'b1;
	@(posedge clk);
	block_start_r <= 1'b0;
end
endtask

export "DPI-C" task set_sideinfo;
task set_sideinfo;
	input       s1_enable;
	input       s1_coded;
	input       s1_mb_intra;
	input [4:0] s1_mb_qscode;
	input       sa_qstype;
	input [1:0] sa_dcprec;
begin
	s1_enable_r <= s1_enable;
	s1_coded_r <= s1_coded;
	s1_mb_intra_r <= s1_mb_intra;
	s1_mb_qscode_r <= s1_mb_qscode;
	sa_qstype_r <= sa_qstype;
	sa_dcprec_r <= sa_dcprec;
end
endtask

export "DPI-C" task feed_rlpair;
task feed_rlpair;
	input  [5:0] run;
	input        level_sign;
	input [10:0] level_data;
begin
	run_r <= run;
	level_sign_r <= level_sign;
	level_data_r <= level_data;
	rl_valid_r <= 1'b1;
	@(posedge clk);
	run_r <= 6'bx;
	level_sign_r <= 1'bx;
	level_data_r <= 11'bx;
	rl_valid_r <= 1'b0;
end
endtask

export "DPI-C" task set_coef_next;
task set_coef_next;
	input coef_next;
begin
	coef_next_r <= coef_next;
end
endtask

export "DPI-C" task get_coef_values;
task get_coef_values;
	output        coef_sign;
	output [11:0] coef_data;
begin
	coef_sign = coef_sign_w;
	coef_data = coef_data_w;
end
endtask

export "DPI-C" task feed_qm_custom;
task feed_qm_custom;
	input qm_custom;
	input qm_intra;
begin
	qm_valid_r <= 1'b1;
	qm_custom_r <= qm_custom;
	qm_intra_r <= qm_intra;
	@(posedge clk);
	qm_valid_r <= 1'b0;
	qm_custom_r <= 1'bx;
	qm_intra_r <= 1'bx;
end
endtask

export "DPI-C" task feed_qm_value;
task feed_qm_value;
	input       qm_intra;
	input [7:0] qm_value;
begin
	qm_valid_r <= 1'b1;
	qm_custom_r <= 1'b1;
	qm_intra_r <= qm_intra;
	qm_value_r <= qm_value;
	@(posedge clk);
	qm_valid_r <= 1'b0;
	qm_custom_r <= 1'bx;
	qm_intra_r <= 1'bx;
	qm_value_r <= 8'bx;
end
endtask

import "DPI-C" context task start_feeding(string);
import "DPI-C" context task feed_block(output finished);
reg feed_finished;
integer feed_count;
initial begin
	start_feeding(REF_DIR);
	feed_finished = 1'b0;
	feed_count = 0;
	while(~feed_finished) begin
		feed_block(feed_finished);
		feed_count += 1;
	end
	$display("[%t] Feed finished", $time);
end

import "DPI-C" context task start_verifying(string);
import "DPI-C" context task verify_block();
reg verify_finished;
integer verify_count;
initial begin
	start_verifying(REF_DIR);
	verify_finished = 1'b0;
	verify_count = 0;
	while(~verify_finished) begin
		while(~block_start_r) @(posedge clk);
		if(s2_enable_r & s2_coded_r) begin
			verify_block();
			verify_count += 1;
			if(feed_finished && feed_count == verify_count) verify_finished = 1'b1;
		end
		@(posedge clk);
	end
end

m2vidct u_dut(
	.clk         (clk),
	.reset_n     (reset_n),
	.softreset   (softreset),

	.ready_idct  (ready_idct_w),
	.block_start (block_start_r),

	.s2_enable   (s2_enable_r),
	.s2_coded    (s2_coded_r),

	.s3_enable   (s3_enable_r),
	.s3_coded    (s3_coded_r),

	.coef_next   (coef_next_w),
	.coef_sign   (coef_sign_r),
	.coef_data   (coef_data_r),

	.pixel_coded (pixel_coded_r),
	.pixel_addr  (pixel_addr_r),
	.pixel_data0 (pixel_data0_w),
	.pixel_data1 (pixel_data1_w)
);

endmodule
// vim:set foldmethod=marker:
