//ttl_74l164.v
//SN74LS164 Serial-In Parallel-Out Shift Register (8-bits)
// @RndMnkIII 15/10/2021.
// Based on On Semiconductor SN74LS164 Datasheet
// MRn to Q propagation delay (typ): 24ns
// clock to Q propagation delay (typ): (21+17)/2 = 19ns
//                   ---------------
//        A       ->| 1          14 |--  VCC
//        B       ->| 2          13 |->  Q7
//        Q0      ->| 3          12 |->  Q6
//        Q1      ->| 4          11 |->  Q5
//        Q2      ->| 5          10 |->  Q4
//        Q3      ->| 6          9  |O<- /MR        _
//        GND     --| 7          8  |<-  CP (CLK) _| |_
//                   ---------------
`default_nettype none
`timescale 1ns/1ps

module ttl_74164_sync (
    input wire A, B, //serial input data
    input wire Reset_n,
    input wire clk,
    //(*direct_enable*) input wire Cen,
    input wire Cen,
    input wire MRn, //Master Reset (async)
    output reg Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7
);
    wire serdata;
    assign serdata = A & B;
    reg last_cen;

    always @(posedge clk) begin
        if (!Reset_n) begin
            Q0 <= 1'b0;
            Q1 <= 1'b0;
            Q2 <= 1'b0;
            Q3 <= 1'b0;
            Q4 <= 1'b0;
            Q5 <= 1'b0;
            Q6 <= 1'b0;
            Q7 <= 1'b0;
            last_cen <= 1'b1;
        end else begin
            last_cen <= Cen;
            
            if (!MRn) begin
                Q0 <= 1'b0;
                Q1 <= 1'b0;
                Q2 <= 1'b0;
                Q3 <= 1'b0;
                Q4 <= 1'b0;
                Q5 <= 1'b0;
                Q6 <= 1'b0;
                Q7 <= 1'b0;
            end else if (Cen && !last_cen) begin
                Q0 <= serdata;
                Q1 <= Q0;
                Q2 <= Q1;
                Q3 <= Q2;
                Q4 <= Q3;
                Q5 <= Q4;
                Q6 <= Q5;
                Q7 <= Q6;
            end
        end
    end
endmodule