// 4-bit binary full adder with fast carry
`default_nettype none
`timescale 1ns/10ps

//Check SN74LS283 TI datasheet for C4, Sum delays
module ttl_74283_nodly #(parameter WIDTH = 4)
(
  input wire [WIDTH-1:0] A,
  input wire [WIDTH-1:0] B,
  input wire C_in,
  output wire [WIDTH-1:0] Sum,
  output wire C_out
);

//------------------------------------------------//
reg [WIDTH-1:0] Sum_computed;
reg C_computed;

always @(*)
begin
  {C_computed, Sum_computed} = {1'b0, A} + {1'b0, B} + C_in;
end
//------------------------------------------------//

//from SN74LS283 Datasheet
assign Sum = Sum_computed;
assign C_out = C_computed;

endmodule