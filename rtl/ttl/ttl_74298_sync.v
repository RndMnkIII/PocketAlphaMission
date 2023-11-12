//ttl_74298_sync.v
// Quad 2-input multiplexer with storage
// Implemented schematic from SN74LS298 TI datasheet
// @RndMnkIII 15/03/2022
`include "helper.v"
`default_nettype none
`timescale 1ns/1ns

module ttl_74298_sync
(
  input wire VIDEO_RSTn,
  input wire clk,
  input wire Cen,
  input wire WS,
  input wire [3:0] A,
  input wire [3:0] B,
  output wire [3:0] Q
);

    wire WSn;
    wire WSnn;
    assign WSn = ~WS;
    assign WSnn = ~WSn;

    wire [3:0] andA;
    wire [3:0] andB;
    wire [3:0] norAB;
    wire [3:0] not_norAB;

    genvar i;
    generate
        for (i=0; i < 4; i=i+1) begin : ls928_gen
            assign andA[i] = A[i] & WSn;
            assign andB[i] = B[i] & WSnn;
            assign norAB[i] = ~(andA[i] | andB[i]);
            assign not_norAB[i] = ~norAB[i];

            SR_FF_sync u0 (.VIDEO_RSTn(VIDEO_RSTn), .clk(clk), .Cen(Cen), .S(not_norAB[i]), .R(norAB[i]), .Q(Q[i])); //dont uses clkn, detects falling edge of Cen
        end
    endgenerate
endmodule

module SR_FF_sync //detects falling edge of Cen
(
    input wire VIDEO_RSTn,
    input wire clk,
    input wire Cen,
    input wire S,
    input wire R,

    output wire Q,
    output wire Qn
);
	reg Qr;
    reg last_cen;
    
	always @(posedge clk) begin
        if(!VIDEO_RSTn) begin
            Qr <= 1'b0;
            last_cen <= 1'b1;
        end
        else
        begin
            last_cen <= Cen;

            if(!Cen && last_cen) begin //detects falling edge on Cen
                case({S,R})
                    2'b00: Qr <= Qr;
                    2'b01: Qr <= 1'b0;
                    2'b10: Qr <= 1'b1;
                    2'b11: Qr <= 1'bx;
                endcase
            end
        end
    end
    assign Q  =  Qr;
    assign Qn = ~Qr;
endmodule