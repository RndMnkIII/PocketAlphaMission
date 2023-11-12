//ttl_74373.sv
// Octal D transparent latch
// function table, logic diagrams and switching characteristics
// extracted from TI 74LS373 Datasheet.
//iverilog ttl_74373.v
`default_nettype none
`timescale 1ns/1ns
module ttl_74373 #(parameter DLY=12)
(
  input  wire OCn,
  input  wire C,
  input  wire [7:0] D,
  output wire [7:0] Q
);
    reg [7:0] Q_current;
    
    always_latch begin
        if (C && !OCn) //transparent mode
            Q_current = D;
    end
    //If OCn is disabled output is in high impedance state
    assign #DLY Q = (OCn) ? 8'hzz : Q_current;
endmodule