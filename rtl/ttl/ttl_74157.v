// Quad 2-input multiplexer
`include "helper.v"
`default_nettype none
`timescale 1ns/1ns

module ttl_74157 #(parameter BLOCKS = 4, WIDTH_IN = 2, WIDTH_SELECT = $clog2(WIDTH_IN),
                   DELAY_RISE = 12, DELAY_FALL = 13)
(
  input wire Enable_bar,
  input wire [WIDTH_SELECT-1:0] Select,
  input wire [BLOCKS*WIDTH_IN-1:0] A_2D,
  output wire [BLOCKS-1:0] Y
);

//------------------------------------------------//
wire [WIDTH_IN-1:0] A [0:BLOCKS-1];
reg [BLOCKS-1:0] computed;
integer i;

always @(*)
begin
  for (i = 0; i < BLOCKS; i=i+1)
  begin
    if (!Enable_bar)
      computed[i] = A[i][Select];
    else
      computed[i] = 1'b0;
  end
end
//------------------------------------------------//

`ASSIGN_UNPACK_ARRAY(BLOCKS, WIDTH_IN, A, A_2D)
assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule