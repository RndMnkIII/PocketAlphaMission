// Copyright (C) AlphaMissionCore Francisco Javier Fuentes Moreno (@RndMnkIII)
// This file is part of AlphaMissionCore <https://github.com/RndMnkIII/AlphaMissionCore_Clocks_sync.sv>.
//
// AlphaMissionCore is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// AlphaMissionCore is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with AlphaMissionCore.  If not, see <http://www.gnu.org/licenses/>.

//AlphaMissionCoreClocks_Cen.sv
//Author: @RndMnkIII
//Date: 14/03/2022
//----------------
`default_nettype none
`timescale 1ns/1ps

module AlphaMissionCore_Clocks_Sync(
    input wire clk, //53.6
    input wire clk_13p4_cen,
    input wire clk_13p4,
    input wire clk_13p4b_cen,
    input wire clk_13p4b,
    input wire clk_6p7_cen,
    input wire clk_6p7b_cen, 
    input wire reset,
    input wire VIDEO_RSTn,
    input wire INVn,
    input wire FSX, //SELECT FRONT SCROLL X REGISTER???
    input wire FX8, //from BACK1 VIDEO???
    input wire [7:0] VD_in, //VD data bus
    //clocks
    output logic CK0,
    output logic CK0n,
    output logic HLDn,
    output logic CK1,
    output logic CK1n,
    output logic [8:0] H,
    output logic [2:0] Hn,
    output logic [8:0] FH,
    output logic FCK,
    output logic [7:0] Y,
    output logic [7:0] X,
    output logic [8:0] FV,
    output logic VCKn,
    output logic DISP,
    output logic VBL,
    output logic HBLANK,
    output logic VBLANK,
    output logic SYNC,
    output logic HSYNC,
    output logic VSYNC,
    output logic LT,
    //cpu control
    output logic BWA,
    input wire VRD,
    input wire AE, //CPUA Enable
    input wire BE, //CPUB Enable
    output logic A_B,
    output logic RLA,
    output logic RLB,
    output logic WBA,
    output logic WBB,
    //
    output logic VWE,
    output logic VOE,
    output logic VDG,
    output logic VLK,
    output logic V_C,
    output logic VFLGn,
    output logic HD8,
    output logic LC,
    output logic LD,
    output logic LA
);
    assign CK0 = clk_13p4b;
    assign CK0n  = clk_13p4;
    logic CK0_cen;
    logic CK0n_cen;
    assign CK0_cen = clk_13p4b_cen;
    assign CK0n_cen = clk_13p4_cen;

    //------------- H counter ---------------
    logic HCNT_CK; //E9A_Q;
    logic HCNT_CK1;//E9A_Qn
    
    DFF_pseudoAsyncClrPre #(.W(1)) e9a (
        .clk(clk),
        .rst(~VIDEO_RSTn),
        .din(HCNT_CK1),
        .q(HCNT_CK),
        .qn(HCNT_CK1),
        .set(1'b0),    // active high
        .clr(1'b0),    // active high
        .cen(CK0n) // signal whose edge will trigger the FF
    );

    logic HCNT_H0; //E9B_Q, 
    logic E9B_Qn;
    DFF_pseudoAsyncClrPre #(.W(1)) e9b (
        .clk(clk),
        .rst(~VIDEO_RSTn),
        .din(E9B_Qn),
        .q(HCNT_H0),
        .qn(E9B_Qn),
        .set(1'b0),    // active high
        .clr(1'b0),    // active high
        .cen(HCNT_CK) // signal whose edge will trigger the FF
    );

    logic [3:0] C10_Q;
    logic C10_RCO;
    //registered value of HLD (value on previous clk clock cyclee)
    logic HLDn_r;
    always @(posedge clk) HLDn_r <= HLDn;


    ttl_74163a_sync c10
    (
        .Clk(clk), //2
        .Rst_n(VIDEO_RSTn),
        .Clear_bar(1'b1), //1
        // .Load_bar(HLDn), //9
        .Load_bar(HLDn_r), //HACK
        .ENT(HCNT_H0), //7
        .ENP(1'b1), //10
        .D({4'b0110}), //D 6, C 5, B 4, A 3
        .Cen(HCNT_CK),
        .RCO(C10_RCO), //15
        .Q(C10_Q) //QD 11, QC 12, QB 13, QA 14
    );

    logic [3:0] C9_Q; //C)_Q
    ttl_74163a_sync c9
    (
        .Clk(clk), //2
        .Rst_n(VIDEO_RSTn),
        .Clear_bar(1'b1), //1
        // .Load_bar(HLDn), //9
        .Load_bar(HLDn_r), //HACK
        .ENT(C10_RCO), //7
        .ENP(C10_RCO), //10
        .D({4'b1111}), //D 6, C 5, B 4, A 3
        .Cen(HCNT_CK),
        .RCO(),
        .Q(C9_Q) //QD 11, QC 12, QB 13, QA 14
    );

    logic d8;
    logic c9q1_n;
    assign c9q1_n = ~C9_Q[1];
    assign d8 = HCNT_CK1 & C10_Q[2] & C9_Q[3]; //3-input AND
    assign HLDn = ~(d8 & c9q1_n & C9_Q[2] & C10_Q[1]); //C7b  FIXED C10_Q[0] -> C10_Q[1]

    ttl_74175_sync b7
    ( 
        .Reset_n(VIDEO_RSTn),
        .Clk(clk),
        .Cen(CK0n),
        .Clr_n(1'b1),
        .D({C10_Q[1:0], HCNT_H0, HCNT_CK1}),
        .Q({H[2:0], CK1}),
        .Q_bar({Hn[2:0], CK1n})
    );
  
    ttl_74174_sync b8
    (
        .Reset_n(VIDEO_RSTn),
        .Clk(clk),
        .Cen(CK0n),
        .Clr_n(1'b1),
        .D({C9_Q[3:0], C10_Q[3:2]}),
        .Q(H[8:3])
    );

    logic c4_cout;
    ttl_74283_nodly c4 (.A({C9_Q[2:0],C10_Q[3]}), .B({4'b0001}), .C_in(1'b0), .Sum(FH[7:4]), .C_out(c4_cout));
    //Stub
    assign FH[3:0] = 4'b0000;
    
    assign FH[8] = C9_Q[3] ^ c4_cout;
    
    logic e8,b4;
    assign e8 = ~(H[8] & H[5]);
    assign b4 = e8 | H[6];

    logic H_SYNC;
    ttl_74164_sync f11(.Reset_n(VIDEO_RSTn), .A(1'b1), .B(b4), .clk(clk),.Cen(H[2]),.MRn(1'b1), .Q4(H_SYNC));


    logic H_DISP_CL; //8C_8
    //LS30: inputs: 1 VCC, 2 C9_Q[0]*, 3 C9_Q[1], 4 C9_Q[2]*, 5 C10_Q[3]*, 6 E9_Qn*, 11 D8_12*, 12 C10_Q[1]* ,output: 8
    assign H_DISP_CL = ~(C10_Q[1] & C9_Q[0] & C9_Q[1] & C9_Q[2] & d8 & C10_Q[3] & HCNT_CK1);//74LS30 8-input positive NAND gate
    
    logic H_DISP_CK; //7C_A6
    assign H_DISP_CK = ~(C10_Q[1] & C10_Q[3] & d8 & c9q1_n); 

    logic H_DISP; //C5B_Qn
    DFF_pseudoAsyncClrPre #(.W(1)) c5b (
        .clk(clk),
        .rst(~VIDEO_RSTn),
        .din(1'b1),
        .q(),
        .qn(H_DISP),
        .set(1'b0),    // active high
        .clr(~H_DISP_CL),    // active high
        .cen(H_DISP_CK) // signal whose edge will trigger the FF
    );

    DFF_pseudoAsyncClrPre #(.W(1)) c5a (
        .clk(clk),
        .rst(~VIDEO_RSTn),
        .din(C10_Q[1]),
        .q(),
        .qn(FCK),
        .set(1'b0),    // active high
        .clr(1'b0),    // active high
        .cen(Hn[1]) // signal whose edge will trigger the FF
    );

    generate
        genvar i;
        for (i = 7; i >= 3; i = i - 1)
        begin: gen_y73
        assign Y[i] = H[i] ^ INVn;
        end
    endgenerate
    //stub
    assign Y[2:0] = 3'b000;
  
    //----- V Counter ------
    logic H4n;
    logic VCK;
    assign H4n = ~H[4];
    assign VCKn = H[8] & H[7] & H4n;
    assign VCK = ~VCKn;

    logic Vcnt_ld;
    logic [7:0] V;
    logic D10_RCO;
    
    logic d8b, K_trig;

    ttl_74163a_sync  d10
    (
        .Clk(clk), //2
        .Rst_n(1'b1),
        .Clear_bar(1'b1), //1
        .Load_bar(Vcnt_ld), //9
        .ENT(1'b1), //7
        .ENP(1'b1), //10
        .D({4'b1010}), //D 6, C 5, B 4, A 3
        .Cen(VCK),
        .RCO(D10_RCO), //15
        .Q(V[3:0]) //QD 11, QC 12, QB 13, QA 14
    );

    logic D9_RCO;
    ttl_74163a_sync d9
    (
        .Clk(clk), //2
        .Rst_n(1'b1),
        .Clear_bar(1'b1), //1
        .Load_bar(Vcnt_ld), //9
        .ENT(D10_RCO), //7
        .ENP(D10_RCO), //10
        .D({4'b1111}), //D 6, C 5, B 4, A 3
        .Cen(VCK), //2
        .RCO(D9_RCO), //15
        .Q(V[7:4]) //QD 11, QC 12, QB 13, QA 14
    );

    logic V7n;
    assign d8b = & V[2:0];
    assign V7n = ~V[7];
    assign K_trig = d8b & V7n & V[5]; //d8c

    logic d6a_clk;
    assign d6a_clk = ~VCK;
    logic D6A_Q, V_DISP; //D6A_Qn
    
    logic J_trig;
    assign J_trig =  V_DISP & D9_RCO; //D7C AND gate
    
    assign Vcnt_ld = ~(V_DISP & D9_RCO); //E8A NAND gate

    ttl_74107a_sync #(.BLOCKS(1))
    d6a (.Reset_n(VIDEO_RSTn), .CLRn(1'b1), .J(J_trig), .K(K_trig), .Clk(clk), .Cen(d6a_clk), .Q(D6A_Q), .Qn(V_DISP));

    assign VBL = D6A_Q;

    logic D6B_Q;
    ttl_74107a_sync #(.BLOCKS(1))
    d6b (.Reset_n(VIDEO_RSTn), .CLRn(1'b1), .J(D6A_Q), .K(V_DISP), .Clk(clk), .Cen(VCK), .Q(D6B_Q));

    assign DISP = V_DISP & H_DISP;//D7B AND gate
    assign HBLANK = ~H_DISP; //Mister needs active high HBLANK
    assign VBLANK = ~V_DISP; //Mister needs active high VBLANK

    logic d7d;
    assign d7d = V[6] & D6B_Q;
    logic V_SYNC;
    //ttl_74164 e10(.A(1'b1), .B(d7d), .clk(V[1]), .MRn(1'b1), .Q3(V_SYNC), .Q7(E10_Q7));
    ttl_74164_sync e10(.Reset_n(VIDEO_RSTn), .A(1'b1), .B(d7d), .clk(clk),.Cen(V[1]),.MRn(1'b1), .Q3(V_SYNC), .Q7(LT));

    assign SYNC = V_SYNC ^ H_SYNC;
    assign HSYNC = ~H_SYNC; //Mister needs active high HSYNC
    assign VSYNC = ~V_SYNC; ////Mister needs active high VSYNC
  
    generate  
        for (i = 7; i >= 0; i = i - 1)
        begin: gen_x70
        assign X[i] = V[i] ^ INVn;
        end
    endgenerate

    logic [7:0] B13_Q;
    reg [7:0] vdin_r;
    always @(posedge clk) begin
        vdin_r <= VD_in;
    end

    ttl_74273_sync b13(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(FSX), .D(vdin_r), .Q(B13_Q)); //RESET HACK

    logic A14_cout;
    ttl_74283_nodly a14 (.A(B13_Q[3:0]), .B(X[3:0]), .C_in(1'b0), .Sum(FV[3:0]), .C_out(A14_cout));
    
    logic A13_cout;
    ttl_74283_nodly a13 (.A(B13_Q[7:4]), .B(X[7:4]), .C_in(A14_cout), .Sum(FV[7:4]), .C_out(A13_cout));
    
    assign FV[8] = FX8 ^ A13_cout; //C11c XOR gate

    //-----------------------------------
    //--- CPU synchronization signals ---
    //-----------------------------------
    logic F15_CK; //A4_a LS32

    assign F15_CK = CK0n | Hn[0]; //OR gate measured 25ns


    logic a15_qa, a15_qb, a15_qc;

    logic PLOAD_SRIGHTn; //b15_o12
    logic RL_Sel; //b15_o15 
    logic AB_Sel; //b15_o17
    logic AB_Seln;
    logic G15_CE; //b15_o19;

    logic e15_1, e15_4; 
    logic G15_BE_CK; //e15_2; 
    logic G15_AE_CK; //0;

    //LD, LC, HD8
    logic a3_1;
    assign a3_1 = ~(CK1 & Hn[0] & H[1]);
    assign LC = a3_1; //*** OUTPUT ****

    // ttl_7474 #(.BLOCKS(1), .DELAY_RISE(16), .DELAY_FALL(16)) b3_2
    // (.Clear_bar(1'b1), .Preset_bar(1'b1), .D(a3_1), .Clk(CK0), .Q(LD));
    DFF_pseudoAsyncClrPre #(.W(1)) b3_2 (
        .clk(clk),
        .rst(~VIDEO_RSTn),
        .din(a3_1),
        .q(LD),
        .qn(),
        .set(1'b0),    // active high
        .clr(1'b0),    // active high
        .cen(CK0) // signal whose edge will trigger the FF
    );

    logic B3_1_Q;
    // ttl_7474 #(.BLOCKS(1), .DELAY_RISE(16), .DELAY_FALL(16)) b3_1
    // (.Clear_bar(1'b1), .Preset_bar(1'b1), .D(H[8]), .Clk(H[3]), .Q(B3_1_Q));
    DFF_pseudoAsyncClrPre #(.W(1)) b3_1 (
        .clk(clk),
        .rst(~VIDEO_RSTn),
        .din(H[8]),
        .q(B3_1_Q),
        .qn(),
        .set(1'b0),    // active high
        .clr(1'b0),    // active high
        .cen(H[3]) // signal whose edge will trigger the FF
    );
    assign HD8 = B3_1_Q; //*** OUTPUT ***

    //VFLGn, LA
    logic a3_2;
    assign a3_2 = ~(&H[2:0]); 
    //assign a3_2 = (|H[2:0]); //HACK: to delay a3_2 one H0 cycle, zero when all H[2:0] equal to zero, RELATED TO BACKGROUND LEFT OFFSET???
    
    logic C3_2_Q; //C3_2_Qn;
    // ttl_7474 #(.BLOCKS(1), .DELAY_RISE(16), .DELAY_FALL(16)) c3_2
    // (.Clear_bar(1'b1), .Preset_bar(1'b1), .D(a3_2), .Clk(CK1n), .Q(C3_2_Q)); //.Q_bar(C3_2_Qn) check on schematic that is not used
    DFF_pseudoAsyncClrPre #(.W(1)) c3_2 (
        .clk(clk),
        .rst(~VIDEO_RSTn),
        .din(a3_2),
        .q(C3_2_Q),
        .qn(),
        .set(1'b0),    // active high
        .clr(1'b0),    // active high
        .cen(CK1n) // signal whose edge will trigger the FF
    );

    logic b4_2;
    assign b4_2 = CK1n | C3_2_Q; //25
    
    assign LA = C3_2_Q; // **** OUTPUT ****

    logic C3_1_Q, C3_1_Qn;
    // ttl_7474 #(.BLOCKS(1), .DELAY_RISE(16), .DELAY_FALL(16)) c3_1
    // (.Clear_bar(b4_2), .Preset_bar(1'b1), .D(1'b1), .Clk(VLK), .Q(C3_1_Q), .Q_bar(C3_1_Qn));
    DFF_pseudoAsyncClrPre #(.W(1)) c3_1 (
        .clk(clk),
        .rst(~VIDEO_RSTn),
        .din(1'b1),
        .q(C3_1_Q),
        .qn(C3_1_Qn),
        .set(1'b0),    // active high
        .clr(~b4_2),    // active high
        .cen(VLK) // signal whose edge will trigger the FF
    );

    assign VFLGn = C3_1_Q; // **** OUTPUT ****

    //********************
    //***   AE Logic   ***
    //********************
    logic F15_AE_Q, F15_AE_Qn;
    logic G15_AE_Q, G15_AE_Qn;

    assign e15_1 = ~(AE & F15_AE_Q); //NAND 15E measured 7.5ns delay
    
    // ttl_74107a #(.BLOCKS(1), .DELAY_RISE(16), .DELAY_FALL(16))
    // f15ae (.CLRn(G15_AE_Qn), .J(AE), .K(e15_1), .Clk(F15_CK), .Q(F15_AE_Q), .Qn(F15_AE_Qn));
    ttl_74107a_sync #(.BLOCKS(1))
    f15ae (.Reset_n(VIDEO_RSTn), .CLRn(G15_AE_Qn), .J(AE), .K(e15_1), .Clk(clk), .Cen(F15_CK), .Q(F15_AE_Q), .Qn(F15_AE_Qn));

    // ttl_7474 #(.BLOCKS(1), .DELAY_RISE(16), .DELAY_FALL(16)) g15ae
    // (.Clear_bar(AE), .Preset_bar(1'b1), .D(1'b1), .Clk(G15_AE_CK), .Q(G15_AE_Q), .Q_bar(G15_AE_Qn));
    DFF_pseudoAsyncClrPre #(.W(1)) g15ae (
        .clk(clk),
        .rst(~VIDEO_RSTn),
        .din(1'b1),
        .q(G15_AE_Q),
        .qn(G15_AE_Qn),
        .set(1'b0),    // active high
        .clr(~AE),    // active high
        .cen(G15_AE_CK) // signal whose edge will trigger the FF
    );
    
    assign G15_AE_CK = ~(AB_Seln & G15_CE); //AB_Sel=0 A

    //********************
    //***   BE Logic   ***
    //********************
    logic F15_BE_Q, F15_BE_Qn;
    logic G15_BE_Q, G15_BE_Qn;

    assign e15_4 = ~(BE & F15_BE_Q); //NAND 15E
    
    // ttl_74107a #(.BLOCKS(1), .DELAY_RISE(16), .DELAY_FALL(16))
    // f15be (.CLRn(G15_BE_Qn), .J(BE), .K(e15_4), .Clk(F15_CK), .Q(F15_BE_Q), .Qn(F15_BE_Qn));
    ttl_74107a_sync #(.BLOCKS(1))
    f15be (.Reset_n(VIDEO_RSTn), .CLRn(G15_BE_Qn), .J(BE), .K(e15_4), .Clk(clk), .Cen(F15_CK), .Q(F15_BE_Q), .Qn(F15_BE_Qn));

    // ttl_7474 #(.BLOCKS(1), .DELAY_RISE(16), .DELAY_FALL(16)) g15be
    // (.Clear_bar(BE), .Preset_bar(1'b1), .D(1'b1), .Clk(G15_BE_CK), .Q(G15_BE_Q), .Q_bar(G15_BE_Qn));
    DFF_pseudoAsyncClrPre #(.W(1)) g15be (
        .clk(clk),
        .rst(~VIDEO_RSTn),
        .din(1'b1),
        .q(G15_BE_Q),
        .qn(G15_BE_Qn),
        .set(1'b0),    // active high
        .clr(~BE),    // active high
        .cen(G15_BE_CK) // signal whose edge will trigger the FF
    );

    assign G15_BE_CK = ~(AB_Sel  & G15_CE); //AB_Sel=1 B

    //*************************************************
    //*** CPU A & B AND VIDEO RAM CONTROL SIGNALS   ***
    //*************************************************
    assign AB_Seln = ~AB_Sel;
    assign A_B = AB_Sel; //LS367 buffer
    pal16r6_15B_sync b15(
        //inputs
        .Reset_n(VIDEO_RSTn),
        .clk(clk),
        .Cen(CK0), 
        .F15_BE_Qn(F15_BE_Qn), //BE
        .C3A_Q(C3_1_Q), 
        .C3A_Qn(C3_1_Qn), 
        .F15_AE_Qn(F15_AE_Qn), //AE
        .A15_QA(a15_qa), 
        .A15_QB(a15_qb), 
        .A15_QC(a15_qc), 
        //outputs
        .PLOAD_RSHIFTn(PLOAD_SRIGHTn), //12
        .VDG(VDG),  //output //14
        .RL_Sel(RL_Sel),  //15
        .VLK(VLK),  //output //16
        .AB_Sel(AB_Sel), //o17 <- ~i4_reg //17
        .V_C(V_C),  //output //18
        .G15_CE(G15_CE)); //o19 <- ~i7 //19
    // S1 S0 Dsr
    //  0  1   1  Shift Righ    {Dsr,q0, q1, q2} -> {Q3,Q2,Q1,Q0}
    //  1  1   1  Parallel Load {D3,D2,D1,D0} -> {Q3,Q2,Q1,Q0}
    ttl_74194_sync a15
        (.CR_n(1'b1), .Reset_n(VIDEO_RSTn), .CP(clk), .Cen(CK0), .S0(1'b1), .S1(PLOAD_SRIGHTn), // S1 comes from 15B PAL16R6 pin 12
        .Dsl(1'b1), .Dsr(1'b1), //  
        .D0(1'b0), .D1(1'b0), .D2(1'b0), .D3(1'b0),
        .Q0(a15_qa), .Q1(a15_qb), .Q2(a15_qc));
    //--

    //VWE, VOE
    logic VRDn;
    assign VRDn = ~VRD; 
    assign VWE = VRDn | VDG; //*** OUTPUT ***
    assign VOE = VRD  & V_C; //*** OUTPUT *** Fix
    //--

    //BWA, RLA, RLB, WBA, WBB
    assign BWA = ~(F15_AE_Q & F15_BE_Q & AB_Seln); //*** OUTPUT ***
    assign RLA = ~(AB_Sel  | RL_Sel);              //*** OUTPUT ***
    assign RLB = ~(AB_Seln | RL_Sel);              //*** OUTPUT ***
    assign WBA =  (AB_Sel  | VWE);                 //*** OUTPUT ***
    assign WBB =  (AB_Seln | VWE);                 //*** OUTPUT ***
    //--
endmodule