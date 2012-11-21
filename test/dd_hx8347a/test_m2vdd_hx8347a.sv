//================================================================================
// Testbench for m2vdd_hx8347a
//================================================================================
`timescale 1ns / 1ps

`define CLOCK_PERIOD		10
`define LCD_CLOCK_PERIOD	50

module test_m2vdd_hx8347a;

parameter
	MEM_WIDTH = 21,
	MVH_WIDTH = 16,
	MVV_WIDTH = 15,
	MBX_WIDTH = 6,
	MBY_WIDTH = 5;

`include "tb_common.vh"

reg         lcd_clk_r;
wire        lcd_reset_n_w;
wire        lcd_cs_w;
wire        lcd_rs_w;
wire [15:0] lcd_data_w;
wire        lcd_write_n_w;
wire        lcd_read_n_w;

reg         ctrl_read_r;
wire [31:0] ctrl_readdata_w;
reg         ctrl_write_r;
reg  [31:0] ctrl_writedata_r;
wire        ctrl_waitrequest_w;
wire        ctrl_readdatavalid_w;

wire [(MEM_WIDTH-1):0] fbuf_address_w;
wire        fbuf_read_w;
wire [15:0] fbuf_readdata_w;
wire        fbuf_write_w;
wire [15:0] fbuf_writedata_w;
wire        fbuf_waitrequest_w;
wire        fbuf_readdatavalid_w;

wire [(MBX_WIDTH+MBY_WIDTH-1):0] fptr_address_w;
reg         fptr_updated_r;
reg         fptr_number_r;

reg   [1:0] fptr_data_r[0:((1<<(MBX_WIDTH+MBY_WIDTH))-1)];

always #(`LCD_CLOCK_PERIOD/2) lcd_clk_r <= ~lcd_clk_r;

initial begin
	lcd_clk_r = 1'b1;
	ctrl_read_r = 1'b0;
	ctrl_write_r = 1'b0;
	ctrl_writedata_r = 32'bx;
end

export "DPI-C" task ctrl_write;
task ctrl_write;
	input [31:0] data;
	output integer cycles;
begin
	cycles = 0;
	ctrl_write_r <= 1'b1;
	ctrl_writedata_r <= data;
	begin: LOOP
		while(1) begin
			@(posedge clk);
			cycles += 1;
			if(~ctrl_waitrequest_w) disable LOOP;
		end
	end
	ctrl_write_r <= 1'b0;
	ctrl_writedata_r <= 32'bx;
end
endtask

export "DPI-C" task ctrl_read;
task ctrl_read;
	output [31:0] data;
	output integer cycles;
begin
	cycles = 0;
	ctrl_read_r <= 1'b1;
	begin: LOOP_WAITREQ
		while(1) begin
			@(posedge clk);
			cycles += 1;
			if(~ctrl_waitrequest_w) disable LOOP_WAITREQ;
		end
	end
	ctrl_read_r <= 1'b0;
	while(~ctrl_readdatavalid_w) begin
		@(posedge clk);
		cycles += 1;
	end
	data = ctrl_readdata_w;
end
endtask

export "DPI-C" task set_fptr_data;
task set_fptr_data;
	input [(MBX_WIDTH+MBY_WIDTH-1):0] addr;
	input [1:0] data;
begin
	fptr_data_r[addr] <= data;
end
endtask

always @(posedge clk)
	{fptr_updated_r, fptr_number_r} <= fptr_data_r[fptr_address_w];

export "DPI-C" task picture_start;
event ev_picture_start;
task picture_start;
begin
	->ev_picture_start;
end
endtask

import "DPI-C" context task init_feed(string);
import "DPI-C" context task feed_picture(output finished);
reg feed_finished;
integer feed_count;
initial begin
	init_feed(REF_DIR);
	feed_finished = 1'b0;
	feed_count = 0;
	while(~feed_finished) begin
		feed_picture(feed_finished);
		feed_count += 1;
	end
	$display("[%t] Feed finished", $time);
end

import "DPI-C" context task init_verify(string);
import "DPI-C" context task verify_picture();
reg verify_finished;
integer verify_count;
initial begin
	init_verify(REF_DIR);
	verify_finished = 1'b0;
	verify_count = 0;
	while(~verify_finished) begin
		@ev_picture_start;
		verify_picture();
		verify_count += 1;
		if(feed_finished && feed_count == verify_count) verify_finished = 1'b1;
	end
	$display("[%t] Verify finished", $time);
	$finish;
end

export "DPI-C" task get_lcd_write;
task get_lcd_write;
	input integer max_cycles;
	output rs;
	output [15:0] data;
	integer cycles;
begin
	begin: WAIT_LOOP
		cycles = 0;
		while(cycles < max_cycles) begin
			@(negedge lcd_clk_r);
			if(~lcd_write_n_w) disable WAIT_LOOP;
			cycles += 1;
		end
	end
	if(~lcd_write_n_w) begin
		rs = lcd_rs_w;
		data = lcd_data_w;
	end else begin
		rs = 1'bx;
		data = 16'bx;
	end
end
endtask

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

import "DPI-C" context task dd_fbuf_write(
	input [(MEM_WIDTH-1):0] address,
	input [15:0] data,
	output integer waitcycles);
import "DPI-C" context task dd_fbuf_read(
	input [(MEM_WIDTH-1):0] address,
	output [15:0] data,
	output integer waitcycles);

initial `U.init();

integer temp_waitcycles;
reg [15:0] temp_readdata;

always @(`U.signal_command_received) begin
	`U.pop_command();
	if(`U.get_command_request() == REQ_WRITE) begin
		dd_fbuf_write(
			`U.get_command_address(),
			`U.get_command_data(0),
			temp_waitcycles
		);
		`U.set_interface_wait_time(temp_waitcycles, 0);
	end else if(`U.get_command_request() == REQ_READ) begin
		dd_fbuf_read(
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

m2vdd_hx8347a u_dut(
	.clk                (clk),
	.reset_n            (reset_n),

	// LCD (Conduit)
	.lcd_clk            (lcd_clk_r),
	.lcd_reset_n        (lcd_reset_n_w),
	.lcd_cs             (lcd_cs_w),
	.lcd_rs             (lcd_rs_w),
	.lcd_data           (lcd_data_w),
	.lcd_write_n        (lcd_write_n_w),
	.lcd_read_n         (lcd_read_n_w),

	// Driver control port (Avalon-MM Slave)
	.ctrl_read          (ctrl_read_r),
	.ctrl_readdata      (ctrl_readdata_w),
	.ctrl_write         (ctrl_write_r),
	.ctrl_writedata     (ctrl_writedata_r),
	.ctrl_waitrequest   (ctrl_waitrequest_w),
	.ctrl_readdatavalid (ctrl_readdatavalid_w),

	// Frame buffer (Avalon-MM Master)
	.fbuf_address       (fbuf_address_w),
	.fbuf_read          (fbuf_read_w),
	.fbuf_readdata      (fbuf_readdata_w),
	.fbuf_write         (fbuf_write_w),
	.fbuf_writedata     (fbuf_writedata_w),
	.fbuf_waitrequest   (fbuf_waitrequest_w),
	.fbuf_readdatavalid (fbuf_readdatavalid_w),

	// Page-select input (Conduit)
	.fptr_address       (fptr_address_w),
	.fptr_updated       (fptr_updated_r),
	.fptr_number        (fptr_number_r)
);

endmodule
// vim:set foldmethod=marker:
