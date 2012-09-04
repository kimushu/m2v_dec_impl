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
	s4_enable_r <= s3_enable_r;
	s4_coded_r <= s3_coded_r;
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

export "DPI-C" task set_sideinfo_blk;
task set_sideinfo_blk;
	input       s2_enable;
	input       s2_coded;
begin
	s2_enable_r <= s2_enable;
	s2_coded_r <= s2_coded;
end
endtask

export "DPI-C" task set_coef_data;
task set_coef_data;
	input        coef_sign;
	input [11:0] coef_data;
begin
	coef_sign_r <= coef_sign;
	coef_data_r <= coef_data;
end
endtask

export "DPI-C" task get_coef_next;
task get_coef_next;
	output coef_next;
begin
	coef_next = coef_next_w;
end
endtask

export "DPI-C" task set_pixel_addr;
task set_pixel_addr;
	input       pixel_coded;
	input [4:0] pixel_addr;
begin
	pixel_coded_r <= pixel_coded;
	pixel_addr_r <= pixel_addr;
end
endtask

export "DPI-C" task get_pixel_data;
task get_pixel_data;
	output [8:0] pixel_data0;
	output [8:0] pixel_data1;
begin
	pixel_data0 = pixel_data0_w;
	pixel_data1 = pixel_data1_w;
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
import "DPI-C" context task verify_block(input s4_enable, input s4_coded);
reg verify_finished;
integer verify_count;
initial begin
	start_verifying(REF_DIR);
	verify_finished = 1'b0;
	verify_count = 0;
	while(~verify_finished) begin
		while(~block_start_r) @(posedge clk);
		verify_block(s4_enable_r, s4_coded_r);
		verify_count += 1;
		if(feed_finished && feed_count == verify_count) verify_finished = 1'b1;
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
