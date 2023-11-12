//AlphaMissionCore_Back1_sync.sv
//Author: @RndMnkIII
//Date: 16/03/2022
`default_nettype none
`timescale 1ns/1ps

module AlphaMissionCore_Back1_sync(
    input  wire VIDEO_RSTn,
    input wire clk,
    input wire CK1,
    input wire RESET,
    //Flip screen control
    input wire INV,
    input wire INVn,
    //common video data bus
    input wire [7:0] VD_in,
    output logic [7:0] VD_out,
    //hps_io rom interface
	input wire         [24:0] ioctl_addr,
	input wire         [7:0] ioctl_data,
	input wire               ioctl_wr,
    //Registers
    input wire B1SY,
    input wire B1SX,

    //MSBs
    input wire B1Y8,
    input wire B1X8,

    //VIDEO/CPU Selector
    input wire V_C,

    //B address
    input wire H8,
    input wire [4:0] Y, //Y[7:3] in schematics
    input wire H2,
    input wire H1,
    input wire H0,
    input wire [7:0] X, 

    input wire [11:0] VA,
    input wire BACK1_VRAM_CSn,
    input wire [1:0] B1_TILEBANK, //from CPU_PCB 5A(15,12)
    
    //A address
    input wire VFLGn,

    //side SRAM control
    input wire VRD,
    input wire VDG,
    input wire VOE,
    input wire VWE,

    //clocking
    input wire CK1n,
    input wire LA,
    input wire VLK,
    //input wire H3

    //Back1 data color
    output logic [3:0] B1D
);
    //Y Scroll Register, Adder section
    logic [2:0] XOR_YSR;
    logic [7:0] B1Y;
    assign XOR_YSR[2] = VD_in[2] ^ INVn;
    assign XOR_YSR[1] = VD_in[1] ^ INVn;
    assign XOR_YSR[0] = VD_in[0] ^ INVn;

    //*** Synchronous Hack ***
    reg [7:0] vdin_r;
    always @(posedge clk) begin
        vdin_r <= {VD_in[7:3],XOR_YSR};
    end

    ttl_74273_sync g2(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(B1SY), .D(vdin_r), .Q(B1Y)); //HACK

    logic [8:0] B1H;
    logic [2:0] B1Hn;
    logic c14_dum3;
    logic [1:0] c12_dum;
    //Y7~3 -> Y[4:0]
    ttl_74283_nodly c14 (.A({1'b1, B1Y[2:0]}),    .B({1'b1, H2,H1,H0}), .C_in(1'b0),     .Sum({c14_dum3,B1H[2:0]}),           .C_out()        );
    logic c13_cout;
    ttl_74283_nodly c13 (.A(B1Y[6:3]),            .B(Y[3:0]),           .C_in(1'b0),     .Sum(B1H[6:3]),                      .C_out(c13_cout));
    ttl_74283_nodly c12 (.A({2'b11,B1Y8,B1Y[7]}), .B({2'b11, H8,Y[4]}), .C_in(c13_cout), .Sum({c12_dum,B1H[8:7]}),            .C_out()        );

    assign B1Hn[0] = ~B1H[0];
    assign B1Hn[1] = ~B1H[1];
    assign B1Hn[2] = ~B1H[2];

    logic [8:0] B1HQ;
    //logic [2:0] d13_dum;
    logic [5:0] d13_q;
    ttl_74174_sync d13
    (
        .Reset_n(VIDEO_RSTn),
        .Clk(clk),
        .Cen(CK1n),
        .Clr_n(1'b1),
        .D({3'b111,B1Hn}),
        .Q(d13_q)
    );
    assign B1HQ[2:0] = d13_q[2:0];

    logic [5:0] d12_q;
    ttl_74174_sync d12
    (
        .Reset_n(VIDEO_RSTn),
        .Clk(clk),
        .Cen(CK1n),
        .Clr_n(1'b1),
        .D(B1H[8:3]),
        .Q(d12_q)
    );
    assign B1HQ[8:3] = d12_q[5:0];

    //X Scroll Register, Adder section
    reg [7:0] vdinX_r;
     always @(posedge clk) begin
        vdinX_r <= VD_in;
    end

    logic [7:0] B1X;
    ttl_74273_sync b12(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(B1SX), .D(vdinX_r), .Q(B1X)); //*** SYNCHRONOUS HACK ***
    logic [8:0] B1V;
    logic a12_cout;
    ttl_74283_nodly a12 (.A(B1X[3:0]),    .B(X[3:0]), .C_in(1'b0),         .Sum(B1V[3:0]), .C_out(a12_cout));
    logic a11_cout;
    ttl_74283_nodly a11 (.A(B1X[7:4]),    .B(X[7:4]), .C_in(a12_cout),     .Sum(B1V[7:4]), .C_out(a11_cout));
    assign B1V[8] = B1X8 ^ a11_cout;

    //2:1 Back1 SRAM bus addresses MUX
    //ttl_74157 A_2D({B3,A3,B2,A2,B1,A1,B0,A0})
    logic h12_CSn; //SRAM chip select signal
    logic [11:0] A;
    logic dum3,dum2,dum1;

    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) e12 (.Enable_bar(1'b0), .Select(V_C),
                .A_2D({VA[11],B1HQ[8],VA[10],B1HQ[7],VA[9],B1HQ[6],VA[8],B1HQ[5]}), .Y(A[11:8]));

    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) e13 (.Enable_bar(1'b0), .Select(V_C),
                .A_2D({VA[7],B1HQ[4],VA[6],B1HQ[3],VA[5],B1V[8],VA[4],B1V[7]}), .Y(A[7:4]));

    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) e14 (.Enable_bar(1'b0), .Select(V_C),
                .A_2D({VA[3],B1V[6],VA[2],B1V[5],VA[1],B1V[4],VA[0],B1V[3]}), .Y(A[3:0]));

    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) d2 (.Enable_bar(1'b0), .Select(V_C),
                .A_2D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,BACK1_VRAM_CSn,VFLGn}), .Y({dum3,dum2,dum1,h12_CSn}));

    logic BACK1_SEL;
    assign BACK1_SEL = ~(BACK1_VRAM_CSn | VDG);

    //data bus multiplexer from VD_in  
    logic [7:0] D, Din;
    assign Din = (BACK1_SEL && VRD) ?  VD_in : 8'hFF;

    //--- HM6264LP-15 8Kx8 150ns SRAM ---
    logic [7:0] back1_Q;
    logic [7:0] Dreg;
    logic h12_CS;

    assign h12_CS = ~h12_CSn;

    logic [12:0] h12_addr1;
    assign h12_addr1 = {1'b0,B1HQ[8:3],B1V[8:3]};

    SRAM_dual_sync #(.ADDR_WIDTH(13)) h12
    (
        .ADDR0({1'b0,VA[11:0]}), 
        .clk0(clk), 
        .cen0(~BACK1_VRAM_CSn), 
        .we0(~VWE), 
        .DATA0(Din), 
        .Q0(back1_Q),
        .ADDR1(h12_addr1), 
        .clk1(clk), 
        .cen1(~VFLGn), 
        .we1(1'b0), 
        .DATA1(8'hff),
        .Q1(Dreg)
    );

    assign D = (!VOE) ? back1_Q : 8'hff;
    assign VD_out = (BACK1_SEL && !VRD) ? D : 8'hff;

    //added delay using FF
    //ttl_74273_sync Dreg_dly(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(CK1), .D(D), .Q(Dreg));

    //Background tile ROM address generator
    logic [7:0] F12_Q;
    ttl_74273_sync f12(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(VLK), .D(Dreg), .Q(F12_Q));

    logic [7:0] F13_Q;
    ttl_74273_sync f13(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(LA), .D(F12_Q), .Q(F13_Q));

    logic [7:0] F14_Q;
    ttl_74273_sync f14(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(B1HQ[2]), .D(F13_Q), .Q(F14_Q));

    logic H14_A0;
    logic H14_A1;
    assign H14_A0 = B1HQ[1] ^ INV; //IC 11D Unit B
    assign H14_A1 = B1HQ[2] ^ INV; //IC 11D Unit A

    //MBM27256-25 250ns 32Kx8 P10 BACK1 ROM ---
    //hps_io rom load interface
    wire H14_D_cs = (ioctl_addr >= 25'h40_000) & (ioctl_addr < 25'h48_000);
    
    logic [7:0] H14_D;
    eprom_32K P10_H14
    (
        .ADDR({B1_TILEBANK, F14_Q[7:0], B1V[2:0], H14_A1, H14_A0}),
        .CLK(clk),
        .DATA(H14_D),
        .ADDR_DL(ioctl_addr),
        .CLK_DL(clk),
        .DATA_IN(ioctl_data),
        .CS_DL(H14_D_cs),
        .WR(ioctl_wr)
    );

    logic [7:0] G14_Q;
    ttl_74273_sync g14(.RESETn(VIDEO_RSTn), .CLRn(1'b1), .Clk(clk), .Cen(B1HQ[0]), .D(H14_D), .Q(G14_Q));

    logic G14_S;
    assign G14_S = B1HQ[0] ^ INV; //IC 11D Unit C
    ttl_74157 #(.DELAY_RISE(0), .DELAY_FALL(0)) a2 (.Enable_bar(1'b0), .Select(G14_S),
                .A_2D({G14_Q[7],G14_Q[3],G14_Q[6],G14_Q[2],G14_Q[5],G14_Q[1],G14_Q[4],G14_Q[0]}), .Y(B1D));
endmodule