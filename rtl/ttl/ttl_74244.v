//ttl_74244.v
`default_nettype none
`timescale 1ns/1ns

//module ttl_74245 #(parameter DELAY_RISE = 12, DELAY_FALL = 12)
module ttl_74244 #(parameter DELAY_RISE = 12, DELAY_FALL = 12)
(
    input wire G1n,
    input wire G2n,
    input wire [3:0] A1,
    input wire [3:0] A2,
    output wire [3:0] Y1,
    output wire [3:0] Y2
);
    assign #(DELAY_RISE, DELAY_FALL) Y1 = (!G1n) ? A1 : 4'bzzzz;
    assign #(DELAY_RISE, DELAY_FALL) Y2 = (!G2n) ? A2 : 4'bzzzz;
endmodule
