//============================================================================
// 
//  SD card ROM loader and ROM selector for MISTer.
//  adapted for their use with Alpha Mission ROMs.
//  Copyright (C) 2019 Kitrinx (aka Rysha)
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//
//============================================================================
module selector_cpuAB_rom
(
	input  logic [24:0] ioctl_addr,
	output logic P1_8D_cs,
	output logic P2_7D_cs,
	output logic P3_5D_cs,     //16KbytesX3 Main  CPU EPROMs 
    output logic P4_3D_cs,
	output logic P5_2D_cs,
	output logic P6_1D_cs     //16KbytesX3 Sub   CPU EPROMs
);

   assign P1_8D_cs = (ioctl_addr < 25'h04000);
   assign P2_7D_cs = (ioctl_addr >= 25'h04000) & (ioctl_addr < 25'h08000);
   assign P3_5D_cs = (ioctl_addr >= 25'h08000) & (ioctl_addr < 25'h0C000);
   assign P4_3D_cs = (ioctl_addr >= 25'h10000) & (ioctl_addr < 25'h14000);
   assign P5_2D_cs = (ioctl_addr >= 25'h14000) & (ioctl_addr < 25'h18000);
   assign P6_1D_cs = (ioctl_addr >= 25'h18000) & (ioctl_addr < 25'h1C000);
endmodule

module selector_cpu_snd_rom
(
	input  logic [24:0] ioctl_addr,
    output logic P7_F4_cs,
	output logic P8_F3_cs,
	output logic P9_F2_cs     //16KbytesX3 Audio CPU EPROMs
);
   assign P7_F4_cs = (ioctl_addr >= 25'h20_000) & (ioctl_addr < 25'h24_000);
   assign P8_F3_cs = (ioctl_addr >= 25'h20_000) & (ioctl_addr < 25'h28_000);
   assign P9_F2_cs = (ioctl_addr >= 25'h28_000) & (ioctl_addr < 25'h2C_000);
endmodule


////////////
// EPROMS //
////////////

module eprom_32K
(
	input logic        CLK,
	input logic        CLK_DL,
	input logic [14:0] ADDR,
	input logic [19:0] ADDR_DL,
	input logic [7:0]  DATA_IN,
	input logic        CS_DL,
	input logic        WR,
	output logic [7:0] DATA
);
	dpram_dc #(.widthad_a(15), .width_a(8)) eprom_32K
	(
		.clock_a(CLK),
		.address_a(ADDR[14:0]),
		.q_a(DATA[7:0]),

		.clock_b(CLK_DL),
		.address_b(ADDR_DL[14:0]),
		.data_b(DATA_IN),
		.wren_b(WR & CS_DL)
	);
endmodule

module eprom_16K
(
	input logic        CLK,
	input logic        CLK_DL,
	input logic [13:0] ADDR,
	input logic [19:0] ADDR_DL,
	input logic [7:0]  DATA_IN,
	input logic        CS_DL,
	input logic        WR,
	output logic [7:0] DATA
);
	dpram_dc #(.widthad_a(14), .width_a(8)) eprom_16K
	(
		.clock_a(CLK),
		.address_a(ADDR[13:0]),
		.q_a(DATA[7:0]),

		.clock_b(CLK_DL),
		.address_b(ADDR_DL[13:0]),
		.data_b(DATA_IN),
		.wren_b(WR & CS_DL)
	);
endmodule

module eprom_8K
(
	input logic        CLK,
	input logic        CLK_DL,
	input logic [12:0] ADDR,
	input logic [19:0] ADDR_DL,
	input logic [7:0]  DATA_IN,
	input logic        CS_DL,
	input logic        WR,
	output logic [7:0] DATA
);
	dpram_dc #(.widthad_a(13), .width_a(8)) eprom_8K
	(
		.clock_a(CLK),
		.address_a(ADDR[12:0]),
		.q_a(DATA[7:0]),

		.clock_b(CLK_DL),
		.address_b(ADDR_DL[12:0]),
		.data_b(DATA_IN),
		.wren_b(WR & CS_DL)
	);
endmodule

module prom_1K_4bit
(
	input logic        CLK,
	input logic        CLK_DL,
	input logic [9:0]  ADDR,
	input logic [19:0] ADDR_DL,
	input logic [7:0]  DATA_IN,
	input logic        CS_DL,
	input logic        WR,
	output logic [3:0] DATA
);

	logic [7:0] data_tmp;
	assign DATA = data_tmp[3:0];

	dpram_dc #(.widthad_a(10), .width_a(8)) prom_1K_4bit
	(
		.clock_a(CLK),
		.address_a(ADDR[9:0]),
		.q_a(data_tmp),

		.clock_b(CLK_DL),
		.address_b(ADDR_DL[9:0]),
		.data_b(DATA_IN),
		.wren_b(WR & CS_DL)
	);
endmodule