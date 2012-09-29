//================================================================================
// Testbench for m2vctrl
//================================================================================
`timescale 1ns / 1ps

`define CLOCK_PERIOD	10

module test_m2vctrl;

parameter
	MEM_WIDTH = 21,
	MVH_WIDTH = 16,
	MVV_WIDTH = 15,
	MBX_WIDTH = 6,
	MBY_WIDTH = 5;

`include "../common.vh"

reg   [0:0] control_address_r;
reg         control_read_r;
wire [31:0] control_readdata_w;
reg         control_write_r;
reg  [31:0] control_writedata_r;
wire        control_readdatavalid_w;
wire        irq_w;

reg         stream_valid_r;
reg   [7:0] stream_data_r;
wire        stream_ready_w;

wire [(MVH_WIDTH-1):0] s0_data_w;
wire        pict_valid_w;
wire        mvec_h_valid_w;
wire        mvec_v_valid_w;
wire        s0_valid_w;
wire [(MBX_WIDTH-1):0] s0_mb_x_w;
wire [(MBY_WIDTH-1):0] s0_mb_y_w;
wire  [4:0] s0_mb_qscode_w;
reg   [2:0] s1_block_r;
reg         s1_coded_r;

reg         ready_isdq_r;
wire  [5:0] run_w;
wire        level_sign_w;
wire [10:0] level_data_w;
wire        rl_valid_w;
wire        qm_valid_w;
wire        qm_custom_w;
wire        qm_intra_w;
wire  [7:0] qm_value_w;

reg         ready_idct_r;

reg         ready_mc_r;

wire        softreset_w;
wire        pre_block_start_w;
wire        block_start_w;
wire        block_end_w;
wire        picture_complete_w;

always @(negedge reset_n) begin
	control_address_r <= 1'bx;
	control_read_r <= 1'b0;
	control_write_r <= 1'b0;
	control_writedata_r <= 32'bx;
	stream_valid_r <= 1'b0;
	stream_data_r <= 8'bx;

	s1_block_r <= 3'bx;
	s1_coded_r <= 1'bx;

	ready_isdq_r <= 1'b0;
	ready_idct_r <= 1'b0;
	ready_mc_r <= 1'b0;
end

import "DPI-C" context task init_feed(string);
import "DPI-C" context task feed_stream(output finished);
reg feed_finished;
integer feed_count;
initial begin
	init_feed(REF_DIR);
	feed_finished = 1'b0;
	feed_count = 0;
	while(~feed_finished) begin
		feed_stream(feed_finished);
		feed_count += 1;
	end
	$display("[%t] Feed finished", $time);
end

import "DPI-C" context task init_verify(string);
import "DPI-C" context task verify_video(output finished);
reg verify_finished;
integer verify_count;
initial begin
	init_verify(REF_DIR);
	verify_finished = 1'b0;
	verify_count = 0;
	while(~verify_finished) begin
		verify_video(verify_finished);
		verify_count += 1;
	end
	$display("[%t] Verify finished", $time);
end

export "DPI-C" task control_write;
task control_write;
	input        address;
	input [31:0] data;
begin
	control_address_r <= address;
	control_writedata_r <= data;
	control_write_r <= 1'b1;
	@(posedge clk);
	control_address_r <= 1'bx;
	control_writedata_r <= 32'bx;
	control_write_r <= 1'b0;
end
endtask

export "DPI-C" task control_read;
task control_read;
	input          address;
	output  [31:0] data;
	output integer cycles;
begin
	control_address_r <= address;
	control_read_r <= 1'b1;
	@(posedge clk);
	cycles = 1;
	while(~control_readdatavalid_w) begin
		@(posedge clk);
		cycles += 1;
	end
	data = control_readdata_w;
	control_address_r <= 1'bx;
	control_read_r <= 1'bx;
end
endtask

export "DPI-C" task stream_write;
task stream_write;
	input [7:0] data;
	output integer cycles;
begin
	cycles = 1;
	while(~stream_ready_w) begin
		@(posedge clk);
		cycles += 1;
	end
	stream_valid_r <= 1'b1;
	stream_data_r <= data;
	@(posedge clk);
	stream_valid_r <= 1'b0;
	stream_data_r <= 8'bx;
end
endtask

export "DPI-C" task set_ready;
task set_ready;
	input isdq;
	input idct;
	input mc;
begin
	ready_isdq_r <= isdq;
	ready_idct_r <= idct;
	ready_mc_r <= mc;
end
endtask

export "DPI-C" task set_s1_sideinfo;
task set_s1_sideinfo;
	input [2:0] block;
	input       coded;
begin
	s1_block_r <= block;
	s1_coded_r <= coded;
end
endtask

reg irq_1d_r;
initial irq_1d_r = irq_w;
always @(posedge clk) irq_1d_r <= irq_w;

event ev;
export "DPI-C" task wait_event;
task wait_event;
	output irq_change;
	output irq_value;
	output pict_valid;
	output mvec_h_valid;
	output mvec_v_valid;
	output s0_valid;
	output rl_valid;
	output qm_valid;
	output pre_block_start;
	output block_start;
	output block_end;
	output picture_complete;
begin
	@ev;
	$write("# Info: [event]");
	irq_change = (irq_1d_r ^ irq_w);
	irq_value = irq_w;
	if(irq_change) $write(" irq");
	pict_valid = pict_valid_w;
	if(pict_valid) $write(" pict_valid");
	mvec_h_valid = mvec_h_valid_w;
	if(mvec_h_valid) $write(" mvec_h_valid");
	mvec_v_valid = mvec_v_valid_w;
	if(mvec_v_valid) $write(" mvec_v_valid");
	s0_valid = s0_valid_w;
	if(s0_valid) $write(" s0_valid");
	rl_valid = rl_valid_w;
	if(rl_valid) $write(" rl_valid");
	qm_valid = qm_valid_w;
	if(qm_valid) $write(" qm_valid");
	pre_block_start = pre_block_start_w;
	if(pre_block_start) $write(" pre_block_start");
	block_start = block_start_w;
	if(block_start) $write(" block_start");
	block_end = block_end_w;
	if(block_end) $write(" block_end");
	picture_complete = picture_complete_w;
	if(picture_complete) $write(" picture_complete");
	$display("");
end
endtask

always @(posedge clk)
	if((irq_1d_r ^ irq_w) | pict_valid_w |
		mvec_h_valid_w | mvec_v_valid_w |
		s0_valid_w | rl_valid_w | qm_valid_w)
		->ev;

m2vctrl u_dut(
	.clk                   (clk),
	.reset_n               (reset_n),

	.control_address       (control_address_r),
	.control_read          (control_read_r),
	.control_readdata      (control_readdata_w),
	.control_write         (control_write_r),
	.control_writedata     (control_writedata_r),
	.control_readdatavalid (control_readdatavalid_w),
	.irq                   (irq_w),

	.stream_valid          (stream_valid_r),
	.stream_data           (stream_data_r),
	.stream_ready          (stream_ready_w),

	.s0_data               (s0_data_w),
	.pict_valid            (pict_valid_w),	// {iframe,qstype,dcprec}
	.mvec_h_valid          (mvec_h_valid_w),
	.mvec_v_valid          (mvec_v_valid_w),
	.s0_valid              (s0_valid_w),
	.s0_mb_x               (s0_mb_x_w),
	.s0_mb_y               (s0_mb_y_w),
	.s0_mb_qscode          (s0_mb_qscode_w),
	.s1_block              (s1_block_r),
	.s1_coded              (s1_coded_r),

	.ready_isdq            (ready_isdq_r),
	.run                   (run_w),
	.level_sign            (level_sign_w),
	.level_data            (level_data_w),
	.rl_valid              (rl_valid_w),
	.qm_valid              (qm_valid_w),
	.qm_custom             (qm_custom_w),
	.qm_intra              (qm_intra_w),
	.qm_value              (qm_value_w),

	.ready_idct            (ready_idct_r),

	.ready_mc              (ready_mc_r),

	.softreset             (softreset_w),
	.pre_block_start       (pre_block_start_w),
	.block_start           (block_start_w),
	.block_end             (block_end_w),
	.picture_complete      (picture_complete_w)
);

endmodule
// vim:set foldmethod=marker:
