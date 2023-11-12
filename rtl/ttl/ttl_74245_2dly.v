//ttl_74245_2dly.v
`default_nettype none
`timescale 1ns/1ns

module ttl_74245_2dly #(parameter DELAY_AB = 12, DELAY_BA = 12)
(
    input wire DIR,
    input wire Enable_bar,
    inout wire [7:0] A,
    inout wire [7:0] B
);
    assign #DELAY_BA A = (Enable_bar ||  DIR) ? 8'hzz : B; //B->A
    assign #DELAY_AB B = (Enable_bar || !DIR) ? 8'hzz : A; //A->B
endmodule
