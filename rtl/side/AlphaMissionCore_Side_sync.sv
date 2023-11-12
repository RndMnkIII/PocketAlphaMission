//AlphaMissionCore_Side_sync.sv
//Author: @RndMnkIII
//Date: 15/03/2022
`default_nettype none
`timescale 1ns/1ps


module AlphaMissionCore_Side_sync(
    input  wire VIDEO_RSTn,
    input wire clk,
    input wire CK1,
    //Flip screen control
    input wire INV,
    input wire INVn,
    //common video data bus
    input wire [7:0] VD_in,
    output logic [7:0] VD_out,
    //Side SRAM address selector V/C
    input wire V_C,
    //hps_io rom interface
	input wire         [24:0] ioctl_addr,
	input wire         [7:0] ioctl_data,
	input wire               ioctl_wr,
    //B address
    input wire SIDE_VRAM_CSn,
    input wire [10:0] VA,
    //A address
    input wire VFLGn,
    input wire H8,
    input wire [4:0] Y, //Y[7:3] in schematics
    input wire [7:0] X, 
    //side SRAM control
    input wire VRD,
    input wire VDG,
    input wire VOE,
    input wire VWE,
    //clocking
    input wire VLK,
    input wire H2n,
    input wire H1n,
    input wire H0n,
    //side data color
    output logic [3:0] SD
);
    logic [7:0] SV;
    logic a10_cout;
    ttl_74283_nodly a10 (.A({INV, 3'b000}), .B(X[3:0]), .C_in(1'b0), .Sum(SV[3:0]), .C_out(a10_cout));
    ttl_74283_nodly a9 (.A({INV,INV,1'b0,INV}), .B(X[7:4]), .C_in(a10_cout), .Sum(SV[7:4]), .C_out());

    //2:1 side SRAM bus addresses MUX
    //ttl_74157 A_2D({B3,A3,B2,A2,B1,A1,B0,A0})
    logic b1_CSn; //SRAM chip select signal
    logic [10:0] A;
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) a6 (.Enable_bar(1'b0), .Select(V_C),
                .A_2D({SIDE_VRAM_CSn,VFLGn, VA[10],H8, VA[9],Y[4], VA[8],Y[3]}), .Y({b1_CSn,A[10:8]}));
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) a7 (.Enable_bar(1'b0), .Select(V_C),
                .A_2D({VA[7],Y[2], VA[6],Y[1], VA[5],Y[0], VA[4],SV[7]}), .Y(A[7:4]));
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) a8 (.Enable_bar(1'b0), .Select(V_C),
                .A_2D({VA[3],SV[6], VA[2],SV[5], VA[1],SV[4], VA[0],SV[3]}), .Y(A[3:0]));

    logic side_EN;
    assign side_EN = ~(SIDE_VRAM_CSn | VDG);

   //bus transceiver between video data common bus and side SRAM.
   // DIR=L B->A, DIR=H A->B
    logic [7:0] D, Din;
    assign Din = (side_EN && VRD) ? VD_in : 8'hff;

    //--- HM6116-3 2Kx8 300ns SRAM ---
    logic [7:0] side_SRAM_Q;
    logic [7:0] Dreg;
    logic b1_CS;
    assign b1_CS = ~b1_CSn;

    SRAM_dual_sync #(.ADDR_WIDTH(11)) b1
    (
        .ADDR0(VA), 
        .clk0(clk), 
        .cen0(~SIDE_VRAM_CSn), 
        .we0(~VWE), 
        .DATA0(Din), 
        .Q0(side_SRAM_Q),
        .ADDR1({H8,Y[4:0],SV[7:3]}), 
        .clk1(clk), 
        .cen1(~VFLGn), 
        .we1(1'b0), 
        .DATA1(8'hff),
        .Q1(Dreg)
    );
    
    //assign D = (!VOE && b1_CS) ? side_SRAM_Q : 8'hff;
    assign D = (!VOE) ? side_SRAM_Q : 8'hff;
    //--------------------------------

    //added delay using FF
    assign VD_out = (side_EN && !VRD) ? D : 8'hff;
    //--------------------------------

    logic [7:0] F1_Q;
    ttl_74273_sync f1(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(VLK), .D(Dreg), .Q(F1_Q));
    logic [7:0] G1_Q;
    ttl_74273_sync g1(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(H2n), .D(F1_Q), .Q(G1_Q));

    //--- HN482764G 250ns 8Kx8 P14 SIDE ROM ---
    logic [7:0] H1_D;
    logic H1_A0;
    logic H1_A1;
    assign H1_A0 = H1n ^ INV; //IC 6B Unit B
    assign H1_A1 = H2n ^ INV; //IC 6B Unit C

    //hps_io rom load interface
    wire P14_H1_cs = (ioctl_addr >= 25'h30_000) & (ioctl_addr < 25'h32_000);

    eprom_8K P14_H1
    (
        .ADDR({G1_Q[7:0], SV[2:0],H1_A1,H1_A0}),
        .CLK(clk),
        .DATA(H1_D),
        .ADDR_DL(ioctl_addr),
        .CLK_DL(clk),
        .DATA_IN(ioctl_data),
        .CS_DL(P14_H1_cs),
        .WR(ioctl_wr)
    );

    logic [7:0] C1_Q;
    ttl_74273_sync c1(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(H0n), .D(H1_D), .Q(C1_Q));

    logic A2_S;
    assign A2_S = H0n ^ INV; //IC 6B Unit A
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) a2 (.Enable_bar(1'b0), .Select(A2_S),
                .A_2D({C1_Q[7],C1_Q[3],C1_Q[6],C1_Q[2],C1_Q[5],C1_Q[1],C1_Q[4],C1_Q[0]}), .Y(SD));
endmodule