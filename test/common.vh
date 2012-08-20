//================================================================================
// Common codes for testbench (Verilog / SystemVerilog)
//================================================================================

//--------------------------------------------------------------------------------
// Common parameters (overwritten by vsim option)
//
parameter REF_DIR = ".";
parameter DUMP_DIR = ".";

//--------------------------------------------------------------------------------
// Clock & Reset
//
reg clk_r;
reg reset_n_r;
reg softreset_r;

always #(`CLOCK_PERIOD/2) clk_r <= ~clk_r;

initial begin
	clk_r = 1'b1;
	reset_n_r = 1'b1;
	#(`CLOCK_PERIOD*2.3) reset_n_r <= 1'b0;
	softreset_r <= 1'b0;
	#(`CLOCK_PERIOD*1.5) reset_n_r <= 1'b1;
	@(posedge clk_r);
end

wire clk;
wire reset_n;
wire softreset;
assign clk = clk_r;
assign reset_n = reset_n_r;
assign softreset = softreset_r;

`ifdef DPI_C
export "DPI-C" task posedge_clk;
export "DPI-C" task wait_reset_done;
export "DPI-C" task pulse_softreset;
`endif

task posedge_clk;
begin
	@(posedge clk);
end
endtask

task wait_reset_done;
begin
	@(posedge reset_n);
	@(posedge clk);
end
endtask

task pulse_softreset;
begin
	softreset_r <= 1'b1;
	@(posedge clk);
	softreset_r <= 1'b0;
end
endtask

// vim:set foldmethod=marker:
