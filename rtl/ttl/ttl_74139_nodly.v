// Dual 2-line to 4-line decoder/demultiplexer (inverted outputs)
//ttl_74139_nodly.v
//Author: @RndMnkIII
//Date: 15/03/22
`include "helper.v"
`default_nettype none
`timescale 1ns/1ns

module ttl_74139_nodly
(
  input wire Enable_bar,
  input wire [1:0] A_2D,
  output wire [3:0] Y_2D
);
  assign Y_2D[0] = ~(~Enable_bar & ~A_2D[1] & ~A_2D[0]); 
  assign Y_2D[1] = ~(~Enable_bar & ~A_2D[1] &  A_2D[0]);
  assign Y_2D[2] = ~(~Enable_bar &  A_2D[1] & ~A_2D[0]);
  assign Y_2D[3] = ~(~Enable_bar &  A_2D[1] &  A_2D[0]);
endmodule