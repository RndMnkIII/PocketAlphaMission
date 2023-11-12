// ttl_74138_nodly.v
`default_nettype none
`timescale 1ns/10ps

module ttl_74138_nodly #(parameter WIDTH_OUT = 8, WIDTH_IN = $clog2(WIDTH_OUT))
(
  input wire Enable1_bar, //4 G2An
  input wire Enable2_bar, //5 G2Bn
  input wire Enable3, //6 G1
  input wire [WIDTH_IN-1:0] A, //3,2,1 C,B,A
  output wire [WIDTH_OUT-1:0] Y //7,9,10,11,12,13,14,15 Y[7:0]
);

//------------------------------------------------//
reg [WIDTH_OUT-1:0] computed;
integer i;

always @(*)
begin
  for (i = 0; i < WIDTH_OUT; i=i+1)
  begin
    if (!Enable1_bar && !Enable2_bar && Enable3 && i == A)
      computed[i] = 1'b0;
    else
      computed[i] = 1'b1;
  end
end
//------------------------------------------------//

assign Y = computed;

endmodule