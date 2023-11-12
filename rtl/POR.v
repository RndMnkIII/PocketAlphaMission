//POR.v
`timescale 1ns / 1ps
module POR(
      input reset_a,
      input clk,    
      output reset_s
);
 reg q0,q1,q2;
 
always@(posedge clk, negedge reset_a)
begin
 if (!reset_a) 
 begin
     q0 <= 1'b0;
     q1 <= 1'b0;
     q2 <= 1'b0;
 end    
 else 
 begin
     q0 <= reset_a;
     q1 <= q0;
     q2 <= q1;
 end    
end

assign reset_s = !(q0 & q1 & q2);
endmodule