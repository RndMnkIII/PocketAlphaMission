//74LS298
// Quad 2-input multiplexer with storage
// Implemented schematic from SN74LS298 TI datasheet
// @RndMnkIII 25/01/2022
`include "helper.v"
`default_nettype none
`timescale 1ns/1ps

module ttl_74298
(
  input wire WS,
  input wire clk,
  input wire [3:0] A,
  input wire [3:0] B,
  output wire [3:0] Q
);

    wire WSn;
    wire WSnn;
    wire clkn;
    assign WSn = ~WS;
    assign WSnn = ~WSn;
    assign clkn = ~clk;

    wire [3:0] andA;
    wire [3:0] andB;
    wire [3:0] norAB;
    wire [3:0] not_norAB;

    genvar i;
    generate
        for (i=0; i < 4; i=i+1) begin : ls298_gen
            assign andA[i] = A[i] & WSn;
            assign andB[i] = B[i] & WSnn;
            assign norAB[i] = ~(andA[i] | andB[i]);
            assign not_norAB[i] = ~norAB[i];

            SR_FF sr_ff_inst (.S(not_norAB[i]), .R(norAB[i]), .clk(clkn), .Q(Q[i]));
        end
    endgenerate
endmodule

module SR_FF #(parameter DELAY=18)
(
    input wire S,
    input wire R,
    input wire clk,
    output wire Q,
    output wire Qn
);
	reg Qr;
    
	always @(posedge clk)
	begin
        case({S,R})
            2'b00: Qr <= Qr;
            2'b01: Qr <= 1'b0;
            2'b10: Qr <= 1'b1;
            2'b11: Qr <= 1'bx;
        endcase
	end

    assign #DELAY Q  =  Qr;
    assign #DELAY Qn = ~Qr;
endmodule