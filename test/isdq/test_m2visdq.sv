//================================================================================
// Testbench for m2visdq
//================================================================================
`timescale 1ns / 1ps

`define CLOCK_PERIOD	10

module test_m2visdq;

`include "../common.vh"

wire        ready_isdq_w;
reg         block_start_r;
reg         block_end_r;

reg         s0_enable_r;
reg         s1_coded_r;
reg         s1_mb_intra_r;
reg   [4:0] s1_mb_qscode_r;
reg         sa_qstype_r;
reg   [1:0] sa_dcprec_r;

reg   [5:0] run_r;
reg         level_sign_r;
reg  [10:0] level_data_r;
reg         rl_valid_r;
reg         qm_valid_r;
reg         qm_custom_r;
reg         qm_intra_r;
reg   [7:0] qm_value_r;

wire        coef_sign_w;
wire [11:0] coef_data_w;
reg         coef_next_r;

always @(negedge reset_n) begin
	block_start_r <= 1'b0;
	block_end_r <= 1'b0;

	s0_enable_r <= 1'bx;
	s1_coded_r <= 1'bx;
	s1_mb_intra_r <= 1'bx;
	s1_mb_qscode_r <= 5'bx;
	sa_qstype_r <= 1'bx;
	sa_dcprec_r <= 2'bx;

	run_r <= 6'bx;
	level_sign_r <= 1'bx;
	level_data_r <= 11'bx;
	rl_valid_r <= 1'b0;
	qm_valid_r <= 1'b0;
	qm_custom_r <= 1'bx;
	qm_intra_r <= 1'bx;
	qm_value_r <= 8'bx;

	coef_next_r <= 1'b0;
end

export "DPI-C" task read_ready_isdq;
task read_ready_isdq;
	output ready_isdq;
begin
	ready_isdq = ready_isdq_w;
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

export "DPI-C" task block_end;
task block_end;
begin
	block_end_r <= 1'b1;
	@(posedge clk);
	block_end_r <= 1'b0;
end
endtask

export "DPI-C" task set_sideinfo;
task set_sideinfo;
	input       s0_enable;
	input       s1_coded;
	input       s1_mb_intra;
	input [4:0] s1_mb_qscode;
	input       sa_qstype;
	input [1:0] sa_dcprec;
begin
	s0_enable_r <= s0_enable;
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

export "DPI-C" task set_qm_custom;
task set_qm_custom;
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
initial begin
	wait_reset_done;
	start_feeding(REF_DIR);
	$display("[%t] Feed finished", $time);
end

m2visdq u_dut(
	.clk          (clk),
	.reset_n      (reset_n),
	.softreset    (softreset),

	.ready_isdq   (ready_isdq_w),
	.block_start  (block_start_r),
	.block_end    (block_end_r),

	.s0_enable    (s0_enable_r),
	.s1_coded     (s1_coded_r),
	.s1_mb_intra  (s1_mb_intra_r),
	.s1_mb_qscode (s1_mb_qscode_r),
	.sa_qstype    (sa_qstype_r),
	.sa_dcprec    (sa_dcprec_r),

	.run          (run_r),
	.level_sign   (level_sign_r),
	.level_data   (level_data_r),
	.rl_valid     (rl_valid_r),
	.qm_valid     (qm_valid_r),
	.qm_custom    (qm_custom_r),
	.qm_intra     (qm_intra_r),
	.qm_value     (qm_value_r),

	.coef_sign    (coef_sign_w),
	.coef_data    (coef_data_w),
	.coef_next    (coef_next_r)
);

endmodule
// vim:set foldmethod=marker:
