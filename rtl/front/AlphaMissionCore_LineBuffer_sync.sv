//AlphaMissionCore_LineBuffer_sync.sv
//Author: @RndMnkIII
//Date: 16/03/2022
`default_nettype none
`timescale 1ns/1ps

module AlphaMissionCore_LineBuffer_sync(
    //inputs:
    input  wire VIDEO_RSTn,
    input wire clk,
    input wire RESETn,
    input wire [7:0] FD,
    input wire LT,
    input wire VCKn,
    input wire CK1,
    input wire CK1n,
    input wire CK0,
    input wire CK0n,
    input wire FCK,
    input wire LD,
    input wire [8:0] FL_Y, //comes from FRONT output
    input wire HLD,
    input wire FY8,
    input wire [7:0] FY,
    input wire INVn,

    //output:
    output logic [7:0] LD_BUF

);
    logic LTn;
    logic VCK;

    assign LTn = ~LT;
    assign VCK = ~VCKn;
        
    logic LDn;
    logic FCK_LDn;

    assign LDn = ~(LD & 1'b1);
    assign FCK_LDn = ~(FCK & LDn);

    logic [8:0] WA;
    logic A11_RCO;
    ttl_74163a_sync a11
    (
        .Clk(clk), //2
        .Rst_n(VIDEO_RSTn),
        .Clear_bar(1'b1), //1
        .Load_bar(FCK_LDn), //HACK
        .ENT(1'b1), //7
        .ENP(1'b1), //10
        .D(FL_Y[3:0]), //D 6, C 5, B 4, A 3
        .Cen(CK0),
        .RCO(A11_RCO), //15
        .Q(WA[3:0]) //QD 11, QC 12, QB 13, QA 14
    );

    logic A12_RCO;
    ttl_74163a_sync a12
    (
        .Clk(clk), //2
        .Rst_n(VIDEO_RSTn),
        .Clear_bar(1'b1), //1
        .Load_bar(FCK_LDn), //HACK
        .ENT(A11_RCO), //7
        .ENP(1'b1), //10
        .D(FL_Y[7:4]), //D 6, C 5, B 4, A 3
        .Cen(CK0),
        .RCO(A12_RCO), //15
        .Q(WA[7:4]) //QD 11, QC 12, QB 13, QA 14
    );

    logic [2:0] a13_dum;
    ttl_74163a_sync a13
    (
        .Clk(clk), //2
        .Rst_n(VIDEO_RSTn),
        .Clear_bar(1'b1), //1
        .Load_bar(FCK_LDn), //HACK
        .ENT(A12_RCO), //7
        .ENP(1'b1), //10
        .D({3'b111,FL_Y[8]}), //D 6, C 5, B 4, A 3
        .Cen(CK0),
        .RCO(), //15
        .Q({a13_dum,WA[8]}) //QD 11, QC 12, QB 13, QA 14
    );

    //HACK: delay HLD signal to trigger load 
    logic HLDr;
    logic FCK_LDnr;
    always @(posedge clk) begin
        HLDr <= HLD;
        FCK_LDnr <= FCK_LDn;
    end

    logic [8:0] RA;
    n9bit_counter ra_counter
    (
        .Reset_n(VIDEO_RSTn),
        .clk(clk), 
        .cen(CK1),
        .direction(INVn), // 1 = Up, 0 = Down
        .load_n(HLDr), //Use delayed signal for trigger with rising edge of CK1
        .ent_n(1'b0),
        .enp_n(1'b0),
        .P({FY8,FY}),
        .Q(RA)   // 4-bit output
    );
    // logic c9_rco;
    // counter_74169 c9
    // (
    //     .Reset_n(VIDEO_RSTn),
    //     .clk(clk), 
    //     .cen(CK1),
    //     .direction(INVn), // 1 = Up, 0 = Down
    //     .load_n(HLDr), //Use delayed signal for trigger with rising edge of CK1
    //     .ent_n(1'b0),
    //     .enp_n(1'b0),
    //     .P(FY[3:0]),
    //     .rco_n(c9_rco),    // Ripple Carry-out (RCO)
    //     .Q(RA[3:0])   // 4-bit output
    // );

    // logic c10_rco;
    // counter_74169 c10
    // (
    //     .Reset_n(VIDEO_RSTn),
    //     .clk(clk), 
    //     .cen(CK1),
    //     .direction(INVn), // 1 = Up, 0 = Down
    //     .load_n(HLDr), //Use delayed signal for trigger with rising edge of CK1
    //     .ent_n(c9_rco),
    //     .enp_n(1'b0),
    //     .P(FY[7:4]),
    //     .rco_n(c10_rco),    // Ripple Carry-out (RCO)
    //     .Q(RA[7:4])   // 4-bit output
    // );

    // logic [2:0] c11_dum;
    // counter_74169 c11
    // (
    //     .Reset_n(VIDEO_RSTn),
    //     .clk(clk), 
    //     .cen(CK1),
    //     .direction(INVn), // 1 = Up, 0 = Down
    //     .load_n(HLDr), //Use delayed signal for trigger with rising edge of CK1
    //     .ent_n(c10_rco),
    //     .enp_n(1'b0),
    //     .P({3'b111,FY8}),
    //     .rco_n(),    // Ripple Carry-out (RCO)
    //     .Q({c11_dum,RA[8]})   // 4-bit output
    // );

    logic a14_A; //74LS20 4-input NAND gate
    assign a14_A = ~(&FD[2:0]);

    logic A8_B_Qn;
    DFF_pseudoAsyncClrPre #(.W(1)) a8_A (
        .clk(clk),
        .rst(~VIDEO_RSTn),
        .din(a14_A),
        .q(),
        .qn(A8_B_Qn),
        .set(1'b0),    // active high
        .clr(1'b0),    // active high
        .cen(CK0n) // signal whose edge will trigger the FF
    );

    logic D9_A_Q, D9_A_Qn;
    DFF_pseudoAsyncClrPre #(.W(1)) d9_A (
        .clk(clk),
        .rst(~VIDEO_RSTn),
        .din(D9_A_Qn),
        .q(D9_A_Q),
        .qn(D9_A_Qn),
        .set(1'b0),    // active high
        .clr(~LTn),    // active high
        .cen(VCK) // signal whose edge will trigger the FF
    );

    logic [8:0] L0A;
    logic L0OE, L0WE, L0CE;
    //ttl_74157 A_2D({B3,A3,B2,A2,B1,A1,B0,A0})
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) b9 (.Enable_bar(1'b0), .Select(D9_A_Q),
                .A_2D({RA[3],WA[3],RA[2],WA[2],RA[1],WA[1],RA[0],WA[0]}), .Y(L0A[3:0]));
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) b11 (.Enable_bar(1'b0), .Select(D9_A_Q),
                .A_2D({RA[7],WA[7],RA[6],WA[6],RA[5],WA[5],RA[4],WA[4]}), .Y(L0A[7:4]));
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) b13 (.Enable_bar(1'b0), .Select(D9_A_Q),
                .A_2D({D9_A_Qn,1'b1, CK1,CK0, 1'b0,A8_B_Qn, RA[8],WA[8]}), .Y({L0OE,L0WE,L0CE,L0A[8]}));

    logic [8:0] L1A;
    logic L1OE, L1WE, L1CE;
    //ttl_74157 A_2D({B3,A3,B2,A2,B1,A1,B0,A0})
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) b10 (.Enable_bar(1'b0), .Select(D9_A_Qn),
                .A_2D({RA[3],WA[3],RA[2],WA[2],RA[1],WA[1],RA[0],WA[0]}), .Y(L1A[3:0]));
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) b12 (.Enable_bar(1'b0), .Select(D9_A_Qn),
                .A_2D({RA[7],WA[7],RA[6],WA[6],RA[5],WA[5],RA[4],WA[4]}), .Y(L1A[7:4]));
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) b14 (.Enable_bar(1'b0), .Select(D9_A_Qn),
                .A_2D({D9_A_Q,1'b1, CK1,CK0, 1'b0,A8_B_Qn, RA[8],WA[8]}), .Y({L1OE,L1WE,L1CE,L1A[8]}));


    //now dont use tristate bus for FPGA code
    logic [7:0] DL1_in, DL0_in;
    logic [7:0] DL1_out, DL0_out;

    ttl_74374_sync d14 (.RESETn(VIDEO_RSTn), .OCn(D9_A_Qn), .Clk(clk), .Cen(CK0n), .D(FD[7:0]), .Q(DL1_in));
    ttl_74374_sync d13 (.RESETn(VIDEO_RSTn), .OCn(D9_A_Q), .Clk(clk), .Cen(CK0n), .D(FD[7:0]), .Q(DL0_in));

    //TMM2018D-45 2K x 8bits NMOS Static RAM
    SRAM_sync_noinit #(.ADDR_WIDTH(11)) c13(.ADDR({2'b00,L0A}), .clk(clk), .cen(~L0CE), .we(~L0WE), .DATA(DL0_in), .Q(DL0_out) );
    SRAM_sync_noinit #(.ADDR_WIDTH(11)) c14(.ADDR({2'b00,L1A}), .clk(clk), .cen(~L1CE), .we(~L1WE), .DATA(DL1_in), .Q(DL1_out) );
    
    logic [7:0] DL0, DL1;
    assign DL0 = ((!L0OE && !L0CE) ? DL0_out : 8'hff); //simulate a tri state bus when the bus is tied to High value in the case of that nothing is connected to it.
    assign DL1 = ((!L1OE && !L1CE) ? DL1_out : 8'hff); //simulate a tri state bus when the bus is tied to High value in the case of that nothing is connected to it.

    logic [7:0] DLF;
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) d12 (.Enable_bar(1'b0), .Select(D9_A_Q),
                .A_2D({DL0[3],DL1[3],DL0[2],DL1[2],DL0[1],DL1[1],DL0[0],DL1[0]}), .Y(DLF[3:0]));
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) d11 (.Enable_bar(1'b0), .Select(D9_A_Q),
                .A_2D({DL0[7],DL1[7],DL0[6],DL1[6],DL0[5],DL1[5],DL0[4],DL1[4]}), .Y(DLF[7:4]));
    
    //ttl_74273 d10(.Clk(CK1n), .RESETn(1'b1), .D(DLF), .Q(LD_BUF));
    ttl_74273_sync d10(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(CK1n), .D(DLF), .Q(LD_BUF));
endmodule