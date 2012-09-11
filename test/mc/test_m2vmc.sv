//================================================================================
// Testbench for m2vmc
//================================================================================
`timescale 1ns / 1ps

`define CLOCK_PERIOD	10

module test_m2vmc;

parameter
	MEM_WIDTH = 21,
	MVH_WIDTH = 16,
	MVV_WIDTH = 15,
	MBX_WIDTH = 6,
	MBY_WIDTH = 5;

`include "../common.vh"

wire        ready_mc_w;
reg         block_start_r;
reg         picture_complete_r;

reg         sa_iframe_r;

wire        pixel_coded_w;
wire  [4:0] pixel_addr_w;
reg   [8:0] pixel_data0_r;
reg   [8:0] pixel_data1_r;

reg [(MVH_WIDTH-1):0] s3_mv_h_r;
reg [(MVV_WIDTH-1):0] s3_mv_v_r;
reg [(MBX_WIDTH-1):0] s3_mb_x_r;
reg [(MBY_WIDTH-1):0] s3_mb_y_r;
reg         s3_mb_intra_r;
reg   [2:0] s3_block_r;
reg         s3_coded_r;
reg         s3_enable_r;

reg [(MBX_WIDTH-1):0] s4_mb_x_r;
reg [(MBY_WIDTH-1):0] s4_mb_y_r;
reg         s4_mb_intra_r;
reg   [2:0] s4_block_r;
reg         s4_coded_r;
reg         s4_enable_r;

wire [(MEM_WIDTH-1):0] fbuf_address_w;
wire        fbuf_read_w;
wire [15:0] fbuf_readdata_w;
wire        fbuf_write_w;
wire [15:0] fbuf_writedata_w;
wire        fbuf_waitrequest_w;
wire        fbuf_readdatavalid_w;

reg [(MBX_WIDTH+MBY_WIDTH-1):0] fptr_address_r;
wire        fptr_updated_w;
wire        fptr_number_w;

always @(negedge reset_n) begin
	block_start_r <= 1'b0;
	picture_complete_r <= 1'b0;

	sa_iframe_r <= 1'bx;

	s3_mv_h_r <= 'bx;
	s3_mv_v_r <= 'bx;
	s3_mb_x_r <= 'bx;
	s3_mb_y_r <= 'bx;
	s3_mb_intra_r <= 1'bx;
	s3_block_r <= 3'bx;
	s3_coded_r <= 1'bx;
	s3_enable_r <= 1'bx;

	s4_mb_x_r <= 'bx;
	s4_mb_y_r <= 'bx;
	s4_mb_intra_r <= 1'bx;
	s4_block_r <= 3'bx;
	s4_coded_r <= 1'bx;
	s4_enable_r <= 1'bx;
end

export "DPI-C" task read_ready_mc;
task read_ready_mc;
	output ready_mc;
begin
	ready_mc = ready_mc_w;
end
endtask

export "DPI-C" task pre_block_start;
task pre_block_start;
begin
	@(posedge clk);
	s4_mb_x_r <= s3_mb_x_r;
	s4_mb_y_r <= s3_mb_y_r;
	s4_mb_intra_r <= s3_mb_intra_r;
	s4_block_r <= s3_block_r;
	s4_coded_r <= s3_coded_r;
	s4_enable_r <= s3_enable_r;
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

export "DPI-C" task picture_complete;
task picture_complete;
begin
	picture_complete_r <= 1'b1;
	@(posedge clk);
	picture_complete_r <= 1'b0;
end
endtask

export "DPI-C" task get_s4_coded;
task get_s4_coded;
	output s4_enable;
	output s4_coded;
begin
	s4_enable = s4_enable_r;
	s4_coded = s4_coded_r;
end
endtask

export "DPI-C" task set_sideinfo_pic;
task set_sideinfo_pic;
	input sa_iframe;
begin
	sa_iframe_r <= sa_iframe;
end
endtask

export "DPI-C" task set_sideinfo_mb;
task set_sideinfo_mb;
	input [(MVH_WIDTH-1):0] s3_mv_h;
	input [(MVV_WIDTH-1):0] s3_mv_v;
	input [(MBX_WIDTH-1):0] s3_mb_x;
	input [(MBY_WIDTH-1):0] s3_mb_y;
	input s3_mb_intra;
begin
	s3_mv_h_r <= s3_mv_h;
	s3_mv_v_r <= s3_mv_v;
	s3_mb_x_r <= s3_mb_x;
	s3_mb_y_r <= s3_mb_y;
	s3_mb_intra_r <= s3_mb_intra;
end
endtask

export "DPI-C" task set_sideinfo_blk;
task set_sideinfo_blk;
	input       s3_enable;
	input       s3_coded;
	input [2:0] s3_block;
begin
	s3_enable_r <= s3_enable;
	s3_coded_r <= s3_coded;
	s3_block_r <= s3_block;
end
endtask

export "DPI-C" task get_pixel_addr;
task get_pixel_addr;
	output       pixel_coded;
	output [4:0] pixel_addr;
begin
	pixel_coded = pixel_coded_w;
	pixel_addr = pixel_addr_w;
end
endtask

export "DPI-C" task set_pixel_data;
task set_pixel_data;
	input [8:0] pixel_data0;
	input [8:0] pixel_data1;
begin
	pixel_data0_r <= pixel_data0;
	pixel_data1_r <= pixel_data1;
end
endtask

import "DPI-C" context task start_feeding(string);
import "DPI-C" context task feed_block_s3(output finished);
reg feed_finished_s3;
integer feed_count_s3;
initial begin
	start_feeding(REF_DIR);
	feed_finished_s3 = 1'b0;
	feed_count_s3 = 0;
	while(~feed_finished_s3) begin
		feed_block_s3(feed_finished_s3);
		feed_count_s3 += 1;
	end
	$display("[%t] Feed(s3) finished", $time);
end

import "DPI-C" context task feed_block_s4(output finished);
reg feed_finished_s4;
integer feed_count_s4;
initial begin
	feed_finished_s4 = 1'b0;
	feed_count_s4 = 0;
	wait_reset_done;
	while(~feed_finished_s4) begin
		while(~block_start_r) @(posedge clk);
		feed_block_s4(feed_finished_s4);
		feed_count_s4 += 1;
	end
	$display("[%t] Feed(s4) finished", $time);
end

import "DPI-C" context task start_verifying(string);
import "DPI-C" context task verify_block(s4_enable, s4_coded);
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
		if(feed_finished_s4 && feed_count_s4 == verify_count) verify_finished = 1'b1;
		@(posedge clk);
	end
end


//--------------------------------------------------------------------------------
// Verify (through Avalon MM Slave BFM)
//
import avalon_mm_pkg::*;
`define U u_mm_slave
altera_avalon_mm_slave_bfm #( // {{{
	.AV_ADDRESS_W               (MEM_WIDTH),
	.AV_SYMBOL_W                (16),
	.AV_NUMSYMBOLS              (1),
	.AV_BURSTCOUNT_W            (3),
	.AV_READRESPONSE_W          (16),
	.AV_WRITERESPONSE_W         (16),
	.USE_READ                   (1),
	.USE_WRITE                  (1),
	.USE_ADDRESS                (1),
	.USE_BYTE_ENABLE            (0),
	.USE_BURSTCOUNT             (0),
	.USE_READ_DATA              (1),
	.USE_READ_DATA_VALID        (1),
	.USE_WRITE_DATA             (1),
	.USE_BEGIN_TRANSFER         (0),
	.USE_BEGIN_BURST_TRANSFER   (0),
	.USE_WAIT_REQUEST           (1),
	.USE_TRANSACTIONID          (0),
	.USE_WRITERESPONSE          (0),
	.USE_READRESPONSE           (0),
	.USE_CLKEN                  (0),
	.AV_BURST_LINEWRAP          (1),
	.AV_BURST_BNDR_ONLY         (1),
	.AV_MAX_PENDING_READS       (127),
	.AV_FIX_READ_LATENCY        (0),
	.AV_READ_WAIT_TIME          (1),
	.AV_WRITE_WAIT_TIME         (0),
	.REGISTER_WAITREQUEST       (0),
	.AV_REGISTERINCOMINGSIGNALS (0)
) `U (
	.clk                      (clk),
	.reset                    (~reset_n),
	.avs_writedata            (fbuf_writedata_w),
	.avs_readdata             (fbuf_readdata_w),
	.avs_address              (fbuf_address_w),
	.avs_waitrequest          (fbuf_waitrequest_w),
	.avs_write                (fbuf_write_w),
	.avs_read                 (fbuf_read_w),
	.avs_readdatavalid        (fbuf_readdatavalid_w),
	.avs_begintransfer        (1'b0),
	.avs_beginbursttransfer   (1'b0),
	.avs_burstcount           (3'b001),
	.avs_byteenable           (1'b1),
	.avs_arbiterlock          (1'b0),
	.avs_lock                 (1'b0),
	.avs_debugaccess          (1'b0),
	.avs_transactionid        (8'b00000000),
	.avs_readresponse         (),
	.avs_readid               (),
	.avs_writeresponserequest (1'b0),
	.avs_writeresponse        (),
	.avs_writeresponsevalid   (),
	.avs_writeid              (),
	.avs_clken                (1'b1)
); // }}}

import "DPI-C" context task mc_fbuf_write(
	input [(MEM_WIDTH-1):0] address,
	input [15:0] data,
	output integer waitcycles);
import "DPI-C" context task mc_fbuf_read(
	input [(MEM_WIDTH-1):0] address,
	output [15:0] data,
	output integer waitcycles);

initial `U.init();

integer temp_waitcycles;
reg [15:0] temp_readdata;

always @(`U.signal_command_received) begin
	`U.pop_command();
	if(`U.get_command_request() == REQ_WRITE) begin
		mc_fbuf_write(
			`U.get_command_address(),
			`U.get_command_data(0),
			temp_waitcycles
		);
		`U.set_interface_wait_time(temp_waitcycles, 0);
	end else if(`U.get_command_request() == REQ_READ) begin
		mc_fbuf_read(
			`U.get_command_address(),
			temp_readdata,
			temp_waitcycles
		);
		`U.set_read_response_id(`U.get_command_transaction_id());
		`U.set_read_response_status(1, 0);
		`U.set_response_request(REQ_READ);
		`U.set_response_data(temp_readdata, 0);
		`U.set_interface_wait_time(temp_waitcycles, 0);
		`U.set_response_burst_size(1);
		`U.push_response();
	end
end
`undef U

m2vmc u_dut(
	.clk                (clk),
	.reset_n            (reset_n),
	.softreset          (softreset),

	.ready_mc           (ready_mc_w),
	.block_start        (block_start_r),
	.picture_complete   (picture_complete_r),

	.pixel_coded        (pixel_coded_w),
	.pixel_addr         (pixel_addr_w),
	.pixel_data0        (pixel_data0_r),
	.pixel_data1        (pixel_data1_r),

	.sa_iframe          (sa_iframe_r),

	.s3_mv_h            (s3_mv_h_r),
	.s3_mv_v            (s3_mv_v_r),
	.s3_mb_x            (s3_mb_x_r),
	.s3_mb_y            (s3_mb_y_r),
	.s3_mb_intra        (s3_mb_intra_r),
	.s3_block           (s3_block_r),
	.s3_coded           (s3_coded_r),
	.s3_enable          (s3_enable_r),

	.s4_mb_x            (s4_mb_x_r),
	.s4_mb_y            (s4_mb_y_r),
	.s4_mb_intra        (s4_mb_intra_r),
	.s4_block           (s4_block_r),
	.s4_coded           (s4_coded_r),
	.s4_enable          (s4_enable_r),

	.fbuf_address       (fbuf_address_w),
	.fbuf_read          (fbuf_read_w),
	.fbuf_readdata      (fbuf_readdata_w),
	.fbuf_write         (fbuf_write_w),
	.fbuf_writedata     (fbuf_writedata_w),
	.fbuf_waitrequest   (fbuf_waitrequest_w),
	.fbuf_readdatavalid (fbuf_readdatavalid_w),

	.fptr_address       (fptr_address_r),
	.fptr_updated       (fptr_updated_w),
	.fptr_number        (fptr_number_w)
);

endmodule
// vim:set foldmethod=marker:
