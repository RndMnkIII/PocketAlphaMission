//Author: @RndMnkIII
//Date: 12/03/2022
`default_nettype none
`timescale 1ns/10ps
module DFF_pseudoAsyncClrPre #(parameter W=1 ) (
    input      wire          clk,
    input      wire          rst,
    input      wire [W-1:0]  din,
    output reg  [W-1:0]  q,
    output reg  [W-1:0]  qn,
    input      wire [W-1:0]  set,    
    input      wire [W-1:0]  clr,    
    input      wire [W-1:0]  cen 
);

reg  [W-1:0] last_edge;

generate
    genvar i;
    for (i=0; i < W; i=i+1) begin: flip_flop
        always @(posedge clk) begin
            if(rst) begin
                q[i]         <= 0;
                qn[i]        <= 1;
                last_edge[i] <= 1;
            end
            else begin
                last_edge[i] <= cen[i];
                if( clr[i] ) begin
                    q[i]  <= 1'b0;
                    qn[i] <= 1'b1;
                end else
                if( set[i] ) begin
                    q[i]  <= 1'b1;
                    qn[i] <= 1'b0;
                end else
                if( cen[i] && !last_edge[i] ) begin
                    q[i]  <=  din[i];
                    qn[i] <= ~din[i];
                end
            end
        end
    end
endgenerate

endmodule