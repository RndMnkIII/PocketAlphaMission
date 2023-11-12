//ttl_74l164_half.v
//SN74LS164 Serial-In Parallel-Out Shift Register (4-bits)
// @RndMnkIII 15/10/2021.
// Based on On Semiconductor SN74LS164 Datasheet
// MRn to Q propagation delay (typ): 24ns
// clock to Q propagation delay (typ): (21+17)/2 = 19ns
//                   ---------------
//        A       ->| 1          14 |--  VCC
//        B       ->| 2          13 |->  Q7 *
//        Q0      ->| 3          12 |->  Q6 *
//        Q1      ->| 4          11 |->  Q5 *
//        Q2      ->| 5          10 |->  Q4 *
//        Q3      ->| 6          9  |O<- /MR        _
//        GND     --| 7          8  |<-  CP (CLK) _| |_
//                   ---------------
// * -> Don't supported on the half version
`default_nettype none
`timescale 1ns/1ns

module ttl_74164_half (
    input wire A, B, //serial input data
    input wire clk, //CP
    input wire MRn, //Master Reset (async)
    output reg Q0, Q1, Q2, Q3);

    localparam MRDLY = 24;
    localparam REGDLY = 19;

    wire serdata;
    assign serdata = A & B;

    always @(posedge clk, negedge MRn) begin
        if (!MRn) begin
            Q0 <= #MRDLY 1'b0;
            Q1 <= #MRDLY 1'b1;
            Q2 <= #MRDLY 1'b0;
            Q3 <= #MRDLY 1'b0;

        end else begin
            Q0 <= #REGDLY serdata;
            Q1 <= #REGDLY Q0;
            Q2 <= #REGDLY Q1;
            Q3 <= #REGDLY Q2;
        end
    end
endmodule