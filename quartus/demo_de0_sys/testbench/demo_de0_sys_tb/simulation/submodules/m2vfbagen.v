//================================================================================
// MPEG2 Video Frame buffer address generator
// Written by kimu_shu
//================================================================================

module m2vfbagen #(
	parameter
	MEM_WIDTH = 21,
	MBX_WIDTH = 6,
	MBY_WIDTH = 5
) (
	input [2:0] block,
	input frame,
	input [(MBX_WIDTH-1):0] mbx,
	input [2:0] x2,
	input [(MBY_WIDTH-1):0] mby,
	input [3:0] y,
	output [(MEM_WIDTH-1):0] addr
);

localparam REQUIRED_WIDTH = MBX_WIDTH + MBY_WIDTH + 10;

assign addr[(REQUIRED_WIDTH-1):0] =
{
	frame,
	block[2],
	mby,
	mbx,
	y[3:1], block[2] ? 1'b0 : y[0],
	x2[2:1], block[2] ? block[0] : x2[0],
	1'b0
};

generate
	if(MEM_WIDTH > REQUIRED_WIDTH)
		assign addr[(MEM_WIDTH-1):REQUIRED_WIDTH] =
			{(MEM_WIDTH-REQUIRED_WIDTH){1'b0}};
endgenerate

endmodule

