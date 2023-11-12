// 74LS107A: Dual J-/K flip-flop with clear; negative-edge-triggered
// Inputs              Outputs
//----------------------------
// CLRn CLK  J  K      Q   Qn
// L    X    X  X      L   H
// H    F    L  L      Q0  Q0n
// H    F    H  L      H   L
// H    F    L  H      L   H
// H    F    H  H      Toggle
// H    H    X  X      Q0  Q0n

//Switching characteristics
//Parameter From  To     Typ   Max 
// tPLH     CLRn  Qn     16ns  25ns 
// tPHL     CLRn  Q      25ns  40ns
// tPLH     CLK   Q,Qn   16ns  25ns
// tPHL     CLK   Q,Qn   25ns  40ns

//<START_TEMPLATE>
//ttl_74107a #(.BLOCKS(1)) <NAME> (.CLRn(), .J(), .K(), .Clk(), .Q(), .Qn());
//<END_TEMPLATE>
//
//Author: @RndMnkIII. 11/03/2022. Data from TI SN74LS107A Datasheet
`default_nettype none
`timescale 1ns/1ps

module ttl_74107a_sync #(parameter BLOCKS = 2)
(
  input wire [BLOCKS-1:0] Reset_n,
  input wire [BLOCKS-1:0] CLRn,
  input wire [BLOCKS-1:0] J,
  input wire [BLOCKS-1:0] K,
  input wire [BLOCKS-1:0] Clk,
  input wire [BLOCKS-1:0] Cen,
  output wire [BLOCKS-1:0] Q,
  output wire [BLOCKS-1:0] Qn
);

//------------------------------------------------//
reg [BLOCKS-1:0] Q_current;
reg last_cen;

generate
    genvar i;
    for (i = 0; i < BLOCKS; i = i + 1)
    begin: gen_blocks
        initial Q_current[i] = 1'b0; //supposition
        always @(posedge Clk[i])

        begin
            if (!Reset_n[i]) begin
                Q_current[i] <= 1'b0; //CLEAR
                last_cen <= 1'b1;
            end
            else begin
                last_cen <= Cen;
                if (!CLRn[i]) begin
                    Q_current[i] <= 1'b0; //CLEAR
                end
                else if (!Cen && last_cen) begin //detect falling edge of Cen
                    if (!J[i] && K[i])
                        Q_current[i] <= 1'b0; //set low
                    else if (J[i] && K[i])
                        Q_current[i] <= ~Q_current[i]; //toggle
                    else if (J[i] && ~K[i])
                        Q_current[i] <= 1'b1; //set high
                    // else J=K=L
                    //   Q_current[i] <= Q_current[i]; //hold value
                end
            end
        end
    end
endgenerate
//------------------------------------------------//

assign Q = Q_current;
assign Qn = ~Q_current;

endmodule