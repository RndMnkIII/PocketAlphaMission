//SRAM_sync.v
//Asynchronous static RAM of variable size with initialization file
//Author: @RndMnkIII
//Date: 15/03/22
`default_nettype none
`timescale 1ns/1ps

//default 8x1K ram size
module SRAM_sync #(parameter DATA_WIDTH = 8, ADDR_WIDTH = 10)(
    input wire clk,
    input wire [ADDR_WIDTH-1:0] ADDR,
    input wire [DATA_WIDTH-1:0] DATA,
    (* direct_enable = 1 *) input wire CEn,
    input wire OEn,
    input wire WEn,
    output reg [DATA_WIDTH-1:0] Q
    );

    reg [DATA_WIDTH-1:0] mem[0:(2**ADDR_WIDTH)-1];
    reg [DATA_WIDTH-1:0] data_out;
    
    always @(posedge clk) begin
        if(!CEn) begin
            if(!OEn) begin
                Q <=  mem[ADDR];
            end
        end
        if(!CEn) begin
            if(!WEn) begin
                mem[ADDR] <= DATA;
            end
        end
    end

endmodule