//ttl_74175_sync.v
//Quadruple D flip-flop with reset; positive-edge-triggered
`default_nettype none
`timescale 1ns/1ps

module ttl_74175_sync
( 
  input wire Reset_n,
  input wire Clk,
  //(*direct_enable*) input wire Cen,
  input wire Cen,
  input wire Clr_n,
  input wire  [3:0] D,
  output wire [3:0] Q,
  output wire [3:0] Q_bar
);
    //------------------------------------------------//
    reg [3:0] Q_current;
    reg last_cen;


    initial Q_current = 4'h0; //supposition

    always @(posedge Clk)
    begin
        if (!Reset_n) begin
            Q_current <= 4'h0;
            last_cen  <= 1'b1;
        end
        else
        begin
            last_cen <= Cen;

            if (!Clr_n)
                Q_current <= 4'h0;
            else if (Cen && !last_cen) //detect rising edge of Cen
                Q_current <= D;
            else
                Q_current <= Q_current;
        end
    end
    //------------------------------------------------//
    assign Q     =  Q_current;
    assign Q_bar = ~Q_current;
endmodule