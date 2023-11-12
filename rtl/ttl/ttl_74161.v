// 4-bit modulo 16 binary counter with parallel load, 
//Asynchronous Master Reset (MRn) ->161A
//Synchronous Reset (SRn) -> LS161
`default_nettype none
`timescale 1ns/1ns

module ttl_74161 #(parameter WIDTH = 4, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input wire Clear_bar,
  input wire Load_bar,
  input wire ENT,
  input wire ENP,
  input wire [WIDTH-1:0] D,
  input wire Clk,
  output wire RCO,
  output wire [WIDTH-1:0] Q
);

//------------------------------------------------//
wire RCO_current;
reg [WIDTH-1:0] Q_current;
wire [WIDTH-1:0] Q_next;

assign Q_next = Q_current + 1;

always @(posedge Clk or negedge Clear_bar)
begin
  if (!Clear_bar)
  begin
    Q_current <= {WIDTH{1'b0}};
  end
  else
  begin
    if (!Load_bar)
    begin
      Q_current <= D;
    end

    if (Load_bar && ENT && ENP)
    begin
      Q_current <= Q_next;
    end
  end
end

// output
assign RCO_current = ENT && (&Q_current);

//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) RCO = RCO_current;
assign #(DELAY_RISE, DELAY_FALL) Q = Q_current;

endmodule