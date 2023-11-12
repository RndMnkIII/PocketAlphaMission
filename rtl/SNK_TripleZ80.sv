//AlphaMissionCore.sv
//Author: @RndMnkIII
//Date: 10/03/2022
`default_nettype none
`timescale 1ns/1ps

module SNK_TripleZ80
(
    input wire RESETn,
    input wire VIDEO_RSTn,
    input wire pause_cpu,
    input wire i_clk, //53.6MHz
    input wire [15:0] PLAYER1,
    input wire [15:0] PLAYER2,
    input wire [7:0] GAME,
    input wire [15:0] DSW,
    output wire player_ctrl_clk,
    //hps_io rom interface
	input wire         [24:0] ioctl_addr,
	input wire         [7:0] ioctl_data,
	input wire               ioctl_wr,

    //layer dbg interfacee
    input wire [2:0] layer_ena_dbg, //0x4 Front layer enabled, 0x2 Back1 layer enabled, 0x1 Side layer enabled
    //output video signals
    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B,
	 output logic HBLANK,
	 output logic VBLANK,
	 output logic HSYNC,
	 output logic VSYNC,
    output logic [8:0] SCR_Y,
    output logic [8:0] SCR_X,
    output logic VBL,
    output logic SYNC,
    output logic VS,
    output logic HS,
    output logic DISP,
    output logic PIX_CLK,
	 output logic CE_PIXEL,

    //sound output
    output wire signed [15:0] snd,
    output wire sample
);
    logic VRD, AE, BE;
    
    logic CK0, CK0n, CK1, CK1n, LDn;
    logic HLDn;
    (* keep *) logic [8:0] H;
    (* keep *) logic [2:0] Hn;
    logic [8:0] FH;
    logic FCK;
    logic [7:0] Y;
    logic [7:0] X;
    logic [8:0] FV;
    logic VCKn;
    logic LT;
    logic VLK;
    logic VFLGn;
    logic VDG, V_C;
    logic VWE, VOE;
    logic BWA, A_B, RLA, RLB, WBA, WBB;
    logic LA, LC, LD, HD8;

    //CPU A data bus (tri-state)
    logic  [7:0] AD;
    
    //common buses
    logic [7:0] VD_out, VD_in;
    logic [11:0] VA;

    //Video Registers and CS 
    logic FRONT_VIDEO_CSn;
    logic SIDE_VRAM_CSn;
    logic DISC;
    logic MSB; //Video Attribs.
    logic FSX; //Front video scroll X
    logic FSY; //Fraont video scroll Y
    logic B1SX; //Back1 video scroll X
    logic B1SY; //Back1 video scroll Y
    logic SIDE_COLOR_BANK; //Unknown write registers
    logic BACK1_TILE_COLOR_BANK;
    logic BACK1_VRAM_CSn;

    //Video Attributes
    logic INV;  //Flip screen (invert)
    logic INVn; //Negated flip screen
    logic B1X8; //BACK1 tile layer scroll X MSB
    logic B1Y8; //BACK1 tile layer scroll Y MSB
    logic FX8;  //FRONT tile layer scroll X MSB
    logic FY8;  //FRONT tile layer scroll Y MSB
    
    //IO devices
    logic COIN;
    logic P1;
    logic P2;
    logic P1_P2;
    logic MCODE;
    logic DIP1;
    logic DIP2;

     logic clk_13p4_cen;
     logic clk_13p4;
     logic clk_13p4b_cen;
     logic clk_13p4b;
     logic clk_6p7_cen;
     logic clk_6p7b_cen;
     logic clk_3p35_cen;
     logic clk_3p35b_cen;
     logic clk_4_cen;
     logic clk_4b_cen;

    AlphaMissionCoreClocks_Cen amc_clk_cen(
        .i_clk(i_clk),
        .clk_13p4_cen(clk_13p4_cen),
        .clk_13p4(clk_13p4),
        .clk_13p4b_cen(clk_13p4b_cen),
        .clk_13p4b(clk_13p4b),
        .clk_6p7_cen(clk_6p7_cen),
        .clk_6p7b_cen(clk_6p7b_cen),
        .clk_3p35_cen(clk_3p35_cen),
        .clk_3p35b_cen(clk_3p35b_cen),
        .clk_4_cen(clk_4_cen),
        .clk_4b_cen(clk_4b_cen)
    );
    
    assign player_ctrl_clk = clk_3p35_cen;
	 assign CE_PIXEL = clk_6p7_cen; 

AlphaMissionCore_Clocks_Sync amc_clocks_sync(
    .clk(i_clk), //53.6
    .clk_13p4_cen(clk_13p4_cen), //CK0
    .clk_13p4(clk_13p4),
    .clk_13p4b_cen(clk_13p4b_cen), //CK0n
    .clk_13p4b(clk_13p4b),
    .clk_6p7_cen(clk_6p7_cen),
    .clk_6p7b_cen(clk_6p7b_cen),
    .reset(VIDEO_RSTn),
    .VIDEO_RSTn(VIDEO_RSTn),
    .INVn(INVn), //replace for INVn
    .FSX(FSX),
    .FX8(FX8), //replace for FX8
    .VD_in(VD_in),
    .VRD(VRD), //replace for VRD
    .AE(AE), //replace for AE
    .BE(BE), //replace for BE
    //output
    .CK0(CK0),
    .CK0n(CK0n),
    .HLDn(HLDn),
    .CK1(CK1),
    .CK1n(CK1n),
    .H(H),
    .Hn(Hn),
    .FH(FH),
    .FCK(FCK),
    .Y(Y),
    .X(X),
    .FV(FV),
    .VCKn(VCKn),
    .VBL(VBL),
    .DISP(DISP),
    .SYNC(SYNC),
	 .HBLANK(HBLANK),
	 .VBLANK(VBLANK),
    .HSYNC(HSYNC),
    .VSYNC(VSYNC),
    .LT(LT),
    //
    .VWE(VWE),
    .VOE(VOE),
    .BWA(BWA),
    .A_B(A_B),
    .RLA(RLA),
    .RLB(RLB),
    .WBA(WBA),
    .WBB(WBB),
    .VDG(VDG),
    .VLK(VLK),
    .V_C(V_C),
    .VFLGn(VFLGn),
    .HD8(HD8),
    .LC(LC),
    .LD(LD),
    .LA(LA)
);
    logic SND_BUSY;
    logic CPUA_WR;
    logic CPUA_RD;
    logic [7:0] CPUAD;

//    assign SND_BUSY = SND_BUSY_MUSIC & SND_BUSY_FX; //hack, duplicate sound hardware

    AlphaMissionCore_CPU_A_B_sync cpuA_B_sync
    (
        //inputs
        .VIDEO_RSTn(VIDEO_RSTn),
        .clk(i_clk),
        .pause_cpu(pause_cpu),
        .H0(H[0]),
        .Cen_p(clk_3p35_cen),
        .Cen_n(clk_3p35b_cen),
        .RESETn(VIDEO_RSTn),
        .PLAYER1(PLAYER1),
        .PLAYER2(PLAYER2),
        .DSW(DSW),
        .VBL(VBL),
        .BWA(BWA),
        .A_B(A_B),
        .RLA(RLA),
        .RLB(RLB),
        .WBA(WBA),
        .WBB(WBB),
        .VDG(VDG),
        //outputs
        .VRDn(VRD),
        .AE(AE), //cpuA Enable
        .BE(BE), //cpuB Enable
        
        //CPU A data bus
        .CPUAD(CPUAD),
        .CPUA_RD(CPUA_RD),
        .CPUA_WR(CPUA_WR),

        //common address bus
        .VA(VA),
        //common data bus
        .V_out(VD_in), //exchange buses
        .V_in(VD_out),
        
        //hps_io rom interface
        .ioctl_addr(ioctl_addr[19:0]),
        .ioctl_wr(ioctl_wr),
        .ioctl_data(ioctl_data),
        
        //IO devices
        .SND_BUSY(SND_BUSY),
        .COIN(COIN),
        .P1(P1),
        .P2(P2),
        .P1_P2(P1_P2),
        .MCODE(MCODE),
        .DIP1(DIP1),
        .DIP2(DIP2),

        //video devices
        .FRONT_VIDEO_CSn(FRONT_VIDEO_CSn),
        .SIDE_VRAM_CSn(SIDE_VRAM_CSn),
        .DISC(DISC),
        .MSB(MSB), //Video Attribs.
        .FSX(FSX), //Front video scroll X
        .FSY(FSY), //Fraont video scroll Y
        .B1SX(B1SX), //Back1 video scroll X
        .B1SY(B1SY), //Back1 video scroll Y
        .SIDE_COLOR_BANK(SIDE_COLOR_BANK), //0XCE00 cpuA write registers (Unknown meaning in MAME)
        .BACK1_TILE_COLOR_BANK(BACK1_TILE_COLOR_BANK),
        .BACK1_VRAM_CSn(BACK1_VRAM_CSn)
    );

	 //logic signed [15:0] snd_out;
    AlphaMissionCore_Sound_sync amc_snd_sync
    (
        .VIDEO_RSTn(VIDEO_RSTn),
        .clk(i_clk),
        .pause_cpu(pause_cpu),
        .CEN_p(clk_4_cen),
        .CEN_n(clk_4b_cen),
        .RESETn(VIDEO_RSTn),
        .data_in(CPUAD),
        .ioctl_addr(ioctl_addr[19:0]),
        .ioctl_wr(ioctl_wr),
        .ioctl_data(ioctl_data),
        .MCODE(MCODE),
        .SND_BUSY(SND_BUSY),
        .snd(snd),
        .sample(sample)
    );

    //Video Attributes
    logic [1:0] BACK1_TILE_BANK; //For Side ROM bank selector
    logic [3:0] BACK1_COLOR_BANK; //For Final Video Color Index bank selector
    //SIDE color BANK
    logic [2:0] SIDE_COL_BANK; //for Final Video
    logic [7:0] FY;
    AlphaMissionCore_Registers_sync amc_registers(
        .VIDEO_RSTn(VIDEO_RSTn),
        .reset(VIDEO_RSTn),
        //.reset(1'b1), //*** ONLY FOR DEBUGGING PURPOUSES ***
        .clk(i_clk),
        .MSB(MSB),
        .VD_in(VD_in), //VD data bus

        //Register MSB bits 5,4,3,1,0
        .INV(INV), //Flip screen, in real pcb two LS368 chained gates
        .INVn(INVn),
        .B1X8(B1X8),
        .FX8(FX8),
        .B1Y8(B1Y8),
        .FY8(FY8),

        .BACK1_TILE_COLOR_BANK(BACK1_TILE_COLOR_BANK),
        //Register BACK1_TILE_COLOR_BANK bits 5,4, 3,2,1,0
        .BACK1_TILE_BANK(BACK1_TILE_BANK),
        .BACK1_COLOR_BANK(BACK1_COLOR_BANK),

        .SIDE_COLOR_BANK(SIDE_COLOR_BANK),
        //Register SIDE_COLOR_BANK bits 2,1,0
        .SIDE_COL_BANK(SIDE_COL_BANK),
        .FSY(FSY),
        .FY(FY)
    );

    //Side Layer hardware
    logic [6:0] SD;
    assign SD[6:4] = SIDE_COL_BANK;

    logic SIDE_SELn;
    logic [7:0] side_vout;
    AlphaMissionCore_Side_sync amc_side_sync(
        .VIDEO_RSTn(VIDEO_RSTn),
        .clk(i_clk),
        .CK1(CK1),
    //Flip screen control
        .INV(INV),
        .INVn(INVn),

    //common video data bus
        .VD_in(VD_in),
        .VD_out(side_vout),
     //hps_io rom interface
        .ioctl_addr(ioctl_addr[19:0]),
        .ioctl_wr(ioctl_wr),
        .ioctl_data(ioctl_data),
    //Side SRAM address selector
        .V_C(V_C),
    //A address
        .SIDE_VRAM_CSn(SIDE_VRAM_CSn),
        .VA(VA[10:0]),
    //B address
        .VFLGn(VFLGn),
        .H8(H[8]),
        .Y(Y[7:3]), //Y[7:3] in schematics
        .X(X), 

    //side SRAM control
        .VRD(VRD),
        .VDG(VDG),
        .VOE(VOE),
        .VWE(VWE),

    //clocking
        .VLK(VLK),
        .H2n(Hn[2]),
        .H1n(Hn[1]),
        .H0n(Hn[0]),

    //side palette index color
        .SD(SD[3:0])
    );

    logic [7:0] B1D;
    assign B1D[7:4] = BACK1_COLOR_BANK;
    logic [7:0] back1_vout;
    AlphaMissionCore_Back1_sync amc_back1_sync(
        .VIDEO_RSTn(VIDEO_RSTn),
        .clk(i_clk),
        .CK1(CK1),
        .RESET(VIDEO_RSTn),
        //Flip screen control
        .INV(INV), //Flip screen, in real pcb two LS368 chained gates
        .INVn(INVn),
        //common video data bus
        .VD_in(VD_in),
        .VD_out(back1_vout),
        //hps_io rom interface
        .ioctl_addr(ioctl_addr[19:0]),
        .ioctl_wr(ioctl_wr),
        .ioctl_data(ioctl_data),
        //Registers
        .B1SY(B1SY),
        .B1SX(B1SX),
        //MSBs
        .B1Y8(B1Y8),
        .B1X8(B1X8),
        //VIDEO/CPU Selector
        .V_C(V_C),
        //B address
        .H8(H[8]),
        .Y(Y[7:3]), //Y[7:3] in schematics
        .H2(H[2]),
        .H1(H[1]),
        .H0(H[0]),
        .X(X), 
        .VA(VA),
        .BACK1_VRAM_CSn(BACK1_VRAM_CSn),
        .B1_TILEBANK(BACK1_TILE_BANK), //from CPU_PCB 5A(15,12)
        
        //A address
        .VFLGn(VFLGn),

        //side SRAM control
        .VRD(VRD),
        .VDG(VDG),
        .VOE(VOE),
        .VWE(VWE),

        //clocking
        .CK1n(CK1n),
        .LA(LA),
        .VLK(VLK),
        //input wire H3

        //Back1 data color
        .B1D(B1D[3:0])
    );
    
    logic [7:0] FD;
    logic [8:0] FL_Y;
    logic [7:0] front_vout;
    AlphaMissionCore_Front_sync amc_front_sync(
        .VIDEO_RSTn(VIDEO_RSTn),
        .clk(i_clk),
        .CK1(CK1),
        //common video data bus
        .VD_in(VD_in),
        .VD_out(front_vout),
        //hps_io rom interface
        .ioctl_addr(ioctl_addr[19:0]),
        .ioctl_wr(ioctl_wr),
        .ioctl_data(ioctl_data),
        //Side SRAM address selector V/C
        .V_C(V_C),
        //B address
        .FRONT_VIDEO_CSn(FRONT_VIDEO_CSn),
        .VA(VA), //VA[11:0]
        //A address
        .VCKn(VCKn),
        //front SRAM control
        .VRD(VRD),
        .VDG(VDG),
        .VOE(VOE),
        .VWE(VWE),
        //clocking
        .FH(FH[8:4]),
        .FV(FV),
        .LC(LC),
        .VLK(VLK),
	    //.VLK(~VLK), //HACK, do not do nothing
        .FCK(FCK),
        //.FCK(~FCK), //HACK, mess sprites
        .H3(H[3]),
        .LD(LD),
        .CK0(CK0),
        //front data output
        .FD(FD),
        .FL_Y(FL_Y)
    );

    logic [7:0] LD_BUF;
    logic FYocho;
    assign FYocho = FY8;
    AlphaMissionCore_LineBuffer_sync amc_linebuf_sync(
        //inputs:
        .VIDEO_RSTn(VIDEO_RSTn),
        .clk(i_clk),
        .RESETn(VIDEO_RSTn),
        .FD(FD),
        .LT(LT),
        .VCKn(VCKn),
        .CK1(CK1),
        .CK1n(CK1n),
        .CK0(CK0),
        .CK0n(CK0n),
        .FCK(FCK),
        .LD(LD),
        .FL_Y(FL_Y), //comes from FRONT output
        .HLD(HLDn),
        .FY8(FYocho),
        .FY(FY),
        .INVn(INVn),
        //output:
        .LD_BUF(LD_BUF)
    );

    //Video out multiplexer
        assign VD_out = ( (!VDG && !SIDE_VRAM_CSn)   ? side_vout  : (
                          (!VDG && !BACK1_VRAM_CSn)  ? back1_vout : (
                          (!VDG && !FRONT_VIDEO_CSn) ? front_vout : 8'hff ))); //default bus data works as tri-state pulled up data bus
    //

    AlphaMissionCore_FinalVideo_sync amc_video_mixer(
    //clocks
        .VIDEO_RSTn(VIDEO_RSTn),
        .clk(i_clk),
        .HD8(HD8),
        .H1(H[1]),
        .CK1(CK1),
        .CK1n(CK1n),
        //hps_io rom interface
        .ioctl_addr(ioctl_addr[19:0]),
        .ioctl_wr(ioctl_wr),
        .ioctl_data(ioctl_data),

        //dbg layer en/disable interface
        .layer_ena_dbg(layer_ena_dbg),
        //Graphics layers
        .LD(LD_BUF), //Line buffer
        //.LD(8'hff), //bypass
        .SD(SD), //Side layer
        .B1D(B1D), //Background layer
        //.B1D(8'hff), //Background layer

        //Final pixel color RGB triplet
        .DISP(DISP), //enable/disable pixel color
        //Final pixel color RGB triplet,
        .R(R),
        .G(G),
        .B(B)
    );

    assign SCR_X = X;
    assign SCR_Y = {H[8],Y[7:3],H[2:0]};
    assign PIX_CLK = CK1;
endmodule
