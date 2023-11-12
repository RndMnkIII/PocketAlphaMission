//ttl_74174_sync.v
// Hex D flip-flop with reset; positive-edge-triggered
`default_nettype none
`timescale 1ns/1ps

module ttl_74174_sync
( 
    input wire Reset_n,
    input wire Clk,
    //(*direct_enable*) input wire Cen,
    input wire Cen,
    input wire Clr_n,
    input wire [5:0] D,
    output wire [5:0] Q
);
    //------------------------------------------------//
    reg [5:0] Q_current;
    reg last_cen;

    initial Q_current = 6'h00; //supposition
    always @(posedge Clk)
    begin
        if (!Reset_n) begin
            Q_current = 6'h00;
            last_cen <= 1'b1;
        end
        else begin
            last_cen <= Cen;

            if (!Clr_n)
                Q_current <= 6'h00;
            else
            if (Cen && !last_cen) //detect rising edge of Cen
            begin
                Q_current <= D;
            end
            else begin
                Q_current <= Q_current;
            end
        end
    end
    //------------------------------------------------//
    assign Q = Q_current;
endmodule