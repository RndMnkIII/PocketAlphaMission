//AlphaMissionCore_FinalVideo_sync.sv
//Author: @RndMnkIII
//Date: 15/03/2022
`default_nettype none
`timescale 1ns/1ps

module AlphaMissionCore_FinalVideo_sync(
    //clocks
    input  wire VIDEO_RSTn,
    input wire clk,
    input wire HD8,
    input wire H1,
    input wire CK1,
    input wire CK1n,
    //hps_io rom interface
    input wire         [24:0] ioctl_addr,
    input wire         [7:0] ioctl_data,
    input wire               ioctl_wr,
    //Graphics layers
    input wire [2:0] layer_ena_dbg, //dbg interface to enable/disable layers
    input wire [7:0] LD, //Line buffer
    input wire [6:0] SD, //Side layer
    input wire [7:0] B1D, //Background layer

    //Final pixel color RGB triplet
    input wire DISP, //enable/disable pixel color
    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B
);
    logic A8_1_Qn;

    DFF_pseudoAsyncClrPre #(.W(1)) a8_1 (
        .clk(clk),
        .rst(~VIDEO_RSTn),
        .din(HD8),
        .q(),
        .qn(A8_1_Qn),
        .set(1'b0),    // active high
        .clr(1'b0),    // active high
        .cen(H1) // signal whose edge will trigger the FF
    );

    logic A9, A10, A14;
    logic [6:0] SD_ena;
    assign SD_ena = (layer_ena_dbg[0]) ? SD : 7'h7f;

    assign A9 = ~( A8_1_Qn & SD_ena[0]);
    assign A10 = ~A9;
    assign A14 = ~(A10 & SD_ena[3] & SD_ena[2] & SD_ena[1]);

    logic [7:0] SLD;
    logic [7:0] SLBD;

    logic [7:0] ld_ena;
    assign ld_ena = (layer_ena_dbg[2]) ? LD : 8'hff;
    ttl_74298_sync e9 (.VIDEO_RSTn(VIDEO_RSTn), .clk(clk), .Cen(CK1n), .WS(A14), .A(ld_ena[3:0]), .B(SD_ena[3:0]), .Q(SLD[3:0]));
    ttl_74298_sync e10  (.VIDEO_RSTn(VIDEO_RSTn), .clk(clk), .Cen(CK1n), .WS(A14), .A(ld_ena[7:4]), .B({1'b0,SD_ena[6:4]}), .Q(SLD[7:4]));

    logic H1_SD30_r; //input
    logic COLBANK3, COLBANK4, COLBANK5, LAYER_SELA, LAYER_SELB;
    pal16l8a_F9_nodly f9(
        //inputs
        .SLBD7(SLBD[7]), //2
        .SLD7(SLD[7]), //3
        .SLD0(SLD[0]), //4
        .SLD1(SLD[1]), //5
        .SLD2(SLD[2]), //6
        .i7(1'b1), //7
        .i8(1'b1), //8
        .i9(1'b1), //9
        .i11(1'b1), //11
        .H1_SD30_r(H1_SD30_r), //13
        //outputs
        .COLBANK5(COLBANK5), //12 
        .LAYER_SELA(LAYER_SELA), //15
        .LAYER_SELB(LAYER_SELB), //16
        .COLBANK3(COLBANK3), //17
        .COLBANK4(COLBANK4) //18
    );
    logic COLBANK5n, LAYER_SELAn;
    assign COLBANK5n = ~COLBANK5;
    assign LAYER_SELAn = ~LAYER_SELA;

    //Block1 = A
    //Block2 = B
    //A = {Block2, Block1};

    logic [7:0] B1D_ena;
    assign B1D_ena = (layer_ena_dbg[1]) ? B1D : 8'hff; 
    ttl_74153 #(.DELAY_RISE(0), .DELAY_FALL(0)) e11
    (
        .Enable_bar({2{1'b0}}),
        .Select({LAYER_SELB,LAYER_SELAn}),
        .A_2D({{1'b1, SLD[1], B1D_ena[1], B1D_ena[1]},{1'b1, SLD[0], B1D_ena[0], B1D_ena[0]}}),
        .Y(SLBD[1:0])
    );
    ttl_74153 #(.DELAY_RISE(0), .DELAY_FALL(0)) e12
    (
        .Enable_bar({2{1'b0}}),
        .Select({LAYER_SELB,LAYER_SELAn}),
        .A_2D({{1'b1, SLD[3], B1D_ena[3], B1D_ena[3]},{1'b1, SLD[2], B1D_ena[2], B1D_ena[2]}}),
        .Y(SLBD[3:2])
    );
    ttl_74153 #(.DELAY_RISE(0), .DELAY_FALL(0)) e13
    (
        .Enable_bar({2{1'b0}}),
        .Select({LAYER_SELB,LAYER_SELAn}),
        .A_2D({{1'b1, SLD[5], B1D_ena[5], B1D_ena[5]},{1'b1, SLD[4], B1D_ena[4], B1D_ena[4]}}),
        .Y(SLBD[5:4])
    );
    ttl_74153 #(.DELAY_RISE(0), .DELAY_FALL(0)) e14
    (
        .Enable_bar({2{1'b0}}),
        .Select({LAYER_SELB,LAYER_SELAn}),
        .A_2D({{1'b0, 1'b0, B1D_ena[7], B1D_ena[7]},{1'b1, SLD[6], B1D_ena[6], B1D_ena[6]}}),
        .Y(SLBD[7:6])
    );

    logic [9:0] COLOR_IDX;
    ttl_74174_sync f10
    (
        .Reset_n(VIDEO_RSTn),
        .Clk(clk),
        .Cen(CK1),
        .Clr_n(1'b1),
        .D(SLBD[5:0]),
        .Q(COLOR_IDX[5:0])
    );

    logic F11_Q4; //dummy output
    ttl_74174_sync f11
    (
        .Reset_n(VIDEO_RSTn),
        .Clk(clk),
        .Cen(CK1),
        .Clr_n(1'b1),
        .D({A14, 1'b1, COLBANK5n, COLBANK4, COLBANK3, SLBD[6]}),
        .Q({H1_SD30_r, F11_Q4, COLOR_IDX[9:6]})
    );

    //PROMS MB7122E x 3
    wire F12_3_cs = (ioctl_addr >= 25'h80_000) & (ioctl_addr < 25'h80_400);
    wire F13_2_cs = (ioctl_addr >= 25'h80_400) & (ioctl_addr < 25'h80_800); 
    wire F14_1_cs = (ioctl_addr >= 25'h80_800) & (ioctl_addr < 25'h80_C00);     // 1KbytesX3 Color     PROMs
    
    //tAA (address change time): 25ns(typ) 45ns(max), tEN,tDIS (output enable/disable time): 30ns (max)
    logic [3:0] F12_D;
    logic [3:0] F13_D;
    logic [3:0] F14_D;

    prom_1K_4bit F12_3
    (
        .ADDR(COLOR_IDX),
        .CLK(clk),
        .DATA(F12_D),
        .ADDR_DL(ioctl_addr),
        .CLK_DL(clk),
        .DATA_IN(ioctl_data[3:0]),
        .CS_DL(F12_3_cs),
        .WR(ioctl_wr)
    );

    prom_1K_4bit F13_2
    (
        .ADDR(COLOR_IDX),
        .CLK(clk),
        .DATA(F13_D),
        .ADDR_DL(ioctl_addr),
        .CLK_DL(clk),
        .DATA_IN(ioctl_data[3:0]),
        .CS_DL(F13_2_cs),
        .WR(ioctl_wr)
    );

    prom_1K_4bit F14_1
    (
        .ADDR(COLOR_IDX),
        .CLK(clk),
        .DATA(F14_D),
        .ADDR_DL(ioctl_addr),
        .CLK_DL(clk),
        .DATA_IN(ioctl_data[3:0]),
        .CS_DL(F14_1_cs),
        .WR(ioctl_wr)
    );

  //Final stage RGB color output, the data lines to RGB component bits are scrambled, intentional or not?
    ttl_74174_sync g13
    (
        .Reset_n(VIDEO_RSTn),
        .Clk(clk),
        .Cen(CK1),
        .Clr_n(DISP),
        .D({{F13_D[3],F12_D[0]},{F14_D[3],F12_D[1],F12_D[2],F12_D[3]}}),
        .Q({G[2],G[3],R[0],R[1],R[2],R[3]})
    );

    ttl_74174_sync g14
    (
        .Reset_n(VIDEO_RSTn),
        .Clk(clk),
        .Cen(CK1),
        .Clr_n(DISP),
        .D({ {F14_D[0],F14_D[1],F13_D[0],F13_D[1]}, {F14_D[2],F13_D[2]}}),
        .Q({B[0],B[1],B[2],B[3],G[0],G[1]})
    );
endmodule
