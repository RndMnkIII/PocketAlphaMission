//AlphaMissionCore_Registers_sync.sv
//Author: @RndMnkIII
//Date: 15/03/2022
`default_nettype none
`timescale 1ns/1ps


module AlphaMissionCore_Registers_sync(
  input wire VIDEO_RSTn,
  input wire reset,
  input wire clk,
  input wire MSB,
  input wire [7:0] VD_in, //VD_in data bus

  //Register MSB bits 5,4,3,1,0
  output logic INV, //Flip screen, in real pcb two LS368 chained gates
  output logic INVn,
  output logic B1X8,
  output logic FX8,
  output logic B1Y8,
  output logic FY8,

  input wire BACK1_TILE_COLOR_BANK,
  //Register BACK1_TILE_COLOR_BANK bits 5,4, 3,2,1,0
  output logic [1:0] BACK1_TILE_BANK,
  output logic [3:0] BACK1_COLOR_BANK,

  input wire SIDE_COLOR_BANK,
  //Register SIDE_COLOR_BANK bits 2,1,0
  output logic [2:0] SIDE_COL_BANK,

  input wire FSY,
  output logic [7:0] FY
);
    logic b11_q2, b11_inv;

    reg [7:0] vdin_r;

     always @(posedge clk) begin
        vdin_r <= VD_in;
    end

    ttl_74174_sync b11
    (
        .Reset_n(reset),
        .Clk(clk),
        .Cen(MSB),
        .Clr_n(1'b1),
        .D(vdin_r[5:0]),
        .Q({b11_inv, B1X8, FX8, b11_q2, B1Y8, FY8})
    );

    //debug B1Y8
    // always @( posedge MSB) begin
    //     $display("MSB:%06b",VD_in[5:0]);
    // end
    assign INV = b11_inv; //add delay for two inverter buffer LS368 chained gates
    assign INVn = ~b11_inv; //add delay for one inverter buffer LS368 gate

    ttl_74174_sync a5
    (
        .Reset_n(reset),
        .Clk(clk),
        .Cen(BACK1_TILE_COLOR_BANK),
        .Clr_n(1'b1),
        .D(vdin_r[5:0]),
        .Q({BACK1_TILE_BANK,BACK1_COLOR_BANK})
    );

    logic a6_d5, a6_d4, a6_d3;
    ttl_74174_sync a6
    (
        .Reset_n(reset),
        .Clk(clk),
        .Cen(SIDE_COLOR_BANK),
        .Clr_n(1'b1),
        .D(vdin_r[5:0]),
        .Q({a6_d5, a6_d4, a6_d3, SIDE_COL_BANK})
    );

    ttl_74273_sync b8(.RESETn(reset), .CLRn(1'b1), .Clk(clk), .Cen(FSY), .D(vdin_r), .Q(FY));
endmodule