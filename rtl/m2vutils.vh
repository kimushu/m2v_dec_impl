//================================================================================
// MPEG2 Video Utility functions
// Written by kimu_shu
//================================================================================

// Luma Coord --> Luma byte address
function [(MEM_WIDTH-1):0] FBADDR_LU;
	input frame;
	input [(MBX_WIDTH-1):0] mbx;
	input [2:0] x2;
	input [(MBY_WIDTH-1):0] mby;
	input [3:0] y;
begin
	FBADDR_LU = {frame, 1'b0, mby, mbx, y, x2, 1'b0};
end
endfunction

// Luma Conversion Coord --> Chroma byte address
function [(MEM_WIDTH-1):0] FBADDR_CH;
	input frame;
	input cr;
	input [(MBX_WIDTH-1):0] mbx;
	input [2:0] x2;
	input [(MBY_WIDTH-1):0] mby;
	input [3:0] y;
begin
	FBADDR_CH = {frame, 1'b1, mby, mbx, y[3:1], 1'b0, x2[2:1], cr, 1'b0};
end
endfunction

