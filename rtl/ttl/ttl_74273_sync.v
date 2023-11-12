//ttl_74273_sync.v
// Octal D flip-flop with reset; positive-edge-triggered
`default_nettype none
`timescale 1ns/1ps
module ttl_74273_sync
(
    input wire RESETn,
    input wire CLRn,
    input wire Clk,
    input wire Cen /* synthesis syn_direct_enable = 1 */,
    input wire [7:0] D,
    output wire [7:0] Q
);
    //------------------------------------------------//
    reg [7:0] Q_current;
    reg last_cen;
    
    always @(posedge Clk)
    begin
        
        if (!RESETn) begin
            Q_current <= 0;
            last_cen <= 1'b1;
        end
        else 
        begin
            last_cen <= Cen;
            if (!CLRn) Q_current <= 0;
            else if(Cen && !last_cen) Q_current <= D; //detect rising edge of Cen
        end
    end
    //------------------------------------------------//
    assign Q = Q_current;
endmodule