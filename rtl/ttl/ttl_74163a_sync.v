  // 4-bit modulo 16 binary counter with parallel load, 
//*** FOR SYNTHESIS ***
//Synchronous Reset (SRn) -> LS163A
//<START_TEMPLATE>
//ttl_74161a #(.DELAY_RISE(20), .DELAY_FALL(25)) <NAME> (.Clear_bar(), .Load_bar(), .ENT(), .ENP(), .D(), .Clk(), .RCO(), .Q());
//<END_TEMPLATE>
//
//tP_clk2tc = 19ns min, 25ns max
//tP_clk2q =  15ns min, 25ns max
//20,25
`default_nettype none
`timescale 1ns/1ps

module ttl_74163a_sync #(parameter WIDTH = 4)
(
  input wire Clk, //2
  input wire Rst_n,
  input wire Clear_bar, //1
  input wire Load_bar, //9
  input wire ENT, //7
  input wire ENP, //10
  input wire [WIDTH-1:0] D, //D 6, C 5, B 4, A 3 
  //(*direct_enable*) input wire Cen, //Clock enable signal and trigger
  input wire Cen, //Clock enable signal and trigger
  output wire RCO, //15
  output wire [WIDTH-1:0] Q //QD 11, QC 12, QB 13, QA 14
);

//------------------------------------------------//
wire RCO_current;
reg [WIDTH-1:0] Q_current;
wire [WIDTH-1:0] Q_next;
reg last_cen;
reg load_reg;

initial Q_current = {WIDTH{1'b0}};
//initial RCO_current = 1'b0;

assign Q_next = Q_current + 1;

always @(posedge Clk)
begin
  if (!Rst_n) begin
    Q_current <= {WIDTH{1'b0}};
    last_cen  <= 1;
    load_reg <= 1;
  end
  else begin
    last_cen <= Cen;
    load_reg <= Load_bar;
    if (!Clear_bar)  begin
      Q_current <= {WIDTH{1'b0}};
    end else
    begin
      if (!Load_bar && Cen && !last_cen) begin
        Q_current <= D;
      end
      else
      if (Load_bar && ENT && ENP && Cen && !last_cen) begin
        Q_current <= Q_next;
      end
    end
  end
end
  
// output
assign RCO_current = ENT && (&Q_current);
//------------------------------------------------//
assign RCO = RCO_current;
assign Q = Q_current;

endmodule