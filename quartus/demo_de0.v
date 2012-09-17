//================================================================================
// Top module for m2v_dec_impl DE0 demo
//================================================================================

module demo_de0(
	// BANK1
	input   [9:0] sw,		// active-low
	input   [2:0] button,
	output  [9:0] led,

	// BANK2
	inout  [15:0] flash_d,
	output [21:0] flash_a,
	output        flash_reset_n,
	output        flash_we_n,
	input         flash_ry,
	output        flash_ce_n,
	output        flash_byte_n,
	output        flash_oe_n,
	output        flash_wp_n,

	// BANK3/4
	inout  [31:0] gpio0_d,
	input   [1:0] gpio0_clkin,
	output  [1:0] gpio0_clkout,

	inout  [31:0] gpio1_d,
	input   [1:0] gpio1_clkin,
	output  [1:0] gpio1_clkout,

	// BANK5
	inout         ps2_kbclk,
	inout         ps2_kbdat,
	inout         ps2_msdat,
	inout         ps2_msclk,

	input         uart_rxd,
	output        uart_txd,
	input         uart_rts,
	output        uart_cts,

	inout         sd_dat0,	// DO
	inout         sd_dat1,
	inout         sd_dat2,
	inout         sd_dat3,	// CS#
	inout         sd_cmd,	// DI
	output        sd_clk,
	input         sd_wpn,

	// BANK6
	inout   [7:0] lcd_d,
	output        lcd_rw,
	output        lcd_en,
	output        lcd_rs,
	output        lcd_blon,

	output  [3:0] vga_r,
	output  [3:0] vga_g,
	output  [3:0] vga_b,	// vga_b<0> is shared with nCEO
	output        vga_vs,
	output        vga_hs,

	input         clk50mhz_1,

	// BANK7
	output  [6:0] hex0_d,	// active-low
	output        hex0_dp,	// active-low
	output  [6:0] hex1_d,	// active-low
	output        hex1_dp,	// active-low
	output  [6:0] hex2_d,	// active-low
	output        hex2_dp,	// active-low
	output  [6:0] hex3_d,	// active-low
	output        hex3_dp,	// active-low

	input         clk50mhz_2,

	// BANK8
	inout  [15:0] dram_d,
	output [12:0] dram_a,
	output  [1:0] dram_dqm,
	output  [1:0] dram_ba,
	output        dram_ras_n,
	output        dram_cs_n,
	output        dram_cas_n,
	output        dram_we_n,
	output        dram_cke,
	output        dram_clk
);

wire [21:0] flash_a_w;
assign flash_a = {1'b0, flash_a_w[21:1]};
assign flash_reset_n = 1'b1;
assign flash_byte_n = 1'b1;
assign flash_wp_n = 1'b1;

wire [6:0] hd_a_w;
wire [6:0] hd_b_w;
wire [6:0] hd_c_w;
wire [6:0] hd_d_w;
wire [6:0] hd_e_w;
wire [6:0] hd_f_w;
wire [6:0] hd_g_w;
wire [6:0] hd_dp_w;
assign hex0_d = {hd_g_w[0], hd_f_w[0], hd_e_w[0], hd_d_w[0], hd_c_w[0], hd_b_w[0], hd_a_w[0]};
assign hex1_d = {hd_g_w[1], hd_f_w[1], hd_e_w[1], hd_d_w[1], hd_c_w[1], hd_b_w[1], hd_a_w[1]};
assign hex2_d = {hd_g_w[2], hd_f_w[2], hd_e_w[2], hd_d_w[2], hd_c_w[2], hd_b_w[2], hd_a_w[2]};
assign hex3_d = {hd_g_w[3], hd_f_w[3], hd_e_w[3], hd_d_w[3], hd_c_w[3], hd_b_w[3], hd_a_w[3]};
assign hex0_dp = hd_dp_w[0];
assign hex1_dp = hd_dp_w[1];
assign hex2_dp = hd_dp_w[2];
assign hex3_dp = hd_dp_w[3];

assign sd_dat1 = 1'bz;
assign sd_dat2 = 1'bz;

assign led[0] = ~button[0];
assign led[1] = ~sysreset_n_w;

wire sysreset_n_w;
wire sysclk_w;	// 100MHz
wire sdrclk_w;	// 100MHz -60deg
wire lcdclk_w;	// 20MHz

demo_de0_pll u_pll(
	.areset (~button[0]),
	.inclk0 (clk50mhz_1),
	.c0     (sysclk_w),
	.c1     (sdrclk_w),
	.c2     (lcdclk_w),
	.locked (sysreset_n_w)
);

assign dram_clk = sdrclk_w;

demo_de0_sys u_sys (
	.sysclk_clk                   (sysclk_w),
	.sysreset_reset_n             (sysreset_n_w),
	.flash_tcm_address_out        (flash_a_w),      //                 flash.tcm_address_out
	.flash_tcm_read_n_out         (flash_oe_n),     //                      .tcm_read_n_out
	.flash_tcm_write_n_out        (flash_we_n),     //                      .tcm_write_n_out
	.flash_tcm_data_out           (flash_d),        //                      .tcm_data_out
	.flash_tcm_chipselect_n_out   (flash_ce_n),     //                      .tcm_chipselect_n_out
	.sdr_addr                     (dram_a),         //                 sdram.addr
	.sdr_ba                       (dram_ba),        //                      .ba
	.sdr_cas_n                    (dram_cas_n),     //                      .cas_n
	.sdr_cke                      (dram_cke),       //                      .cke
	.sdr_cs_n                     (dram_cs_n),      //                      .cs_n
	.sdr_dq                       (dram_d),         //                      .dq
	.sdr_dqm                      (dram_dqm),       //                      .dqm
	.sdr_ras_n                    (dram_ras_n),     //                      .ras_n
	.sdr_we_n                     (dram_we_n),      //                      .we_n
	.lcd_reset_n                  (gpio0_d[7]),     //                   lcd.reset_n
	.lcd_cs                       (gpio0_d[3]),     //                      .cs
	.lcd_rs                       (gpio0_d[4]),     //                      .rs
	.lcd_data                     (gpio0_d[23:8]),  //                      .data
	.lcd_write_n                  (gpio0_d[5]),     //                      .write_n
	.lcd_read_n                   (gpio0_d[6]),     //                      .read_n
	.hd_a                         (hd_a_w),         //                    hd.a
	.hd_b                         (hd_b_w),         //                      .b
	.hd_c                         (hd_c_w),         //                      .c
	.hd_d                         (hd_d_w),         //                      .d
	.hd_e                         (hd_e_w),         //                      .e
	.hd_f                         (hd_f_w),         //                      .f
	.hd_g                         (hd_g_w),         //                      .g
	.hd_dp                        (hd_dp_w),        //                      .dp
	.sdcard_MISO                  (sd_dat0),        //                sdcard.MISO
	.sdcard_MOSI                  (sd_cmd),         //                      .MOSI
	.sdcard_SCLK                  (sd_clk),         //                      .SCLK
	.sdcard_SS_n                  (sd_dat3),        //                      .SS_n
	.sw_export                    ({button[1:0], sw[9:0]}), //            sw.export
	.lcdclk_clk                   (lcdclk_w)
);

endmodule

