//ttl_74374_sync.sv
// Octal D edge triggered FF
// function table, logic diagrams and switching characteristics
// extracted from TI 74LS374 Datasheet.
// Author: @RndMnkIII
// Date: 17/03/2022
`default_nettype none
`timescale 1ns/1ps

module ttl_74374_sync
(
    input  wire RESETn,
    input  wire Clk,
    input  wire Cen,
    input  wire OCn,
    input  wire [7:0] D,
    output wire [7:0] Q
);
    reg [7:0] Q_current;
    reg last_cen;
    
    always_ff @(posedge Clk) begin
        if (!RESETn) begin
            Q_current <= 0;
            last_cen <= 1'b1;
        end
        else begin
            last_cen <= Cen;

            if (Cen && !last_cen) Q_current <= D;
        end
    end

    //If OCn is disabled output is 8'hff (not 8'hzz)
    assign Q = (!OCn) ?  Q_current : 8'hff;
endmodule