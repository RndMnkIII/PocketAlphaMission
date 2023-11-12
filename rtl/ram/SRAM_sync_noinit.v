//SRAM_sync_noinit.v
//Asynchronous static RAM of variable size with initialization file
//Author: @RndMnkIII
//Date: 15/03/22
`default_nettype none
`timescale 1ns/1ps

//default 8x1K ram size
module SRAM_sync_noinit #(parameter DATA_WIDTH = 8, ADDR_WIDTH = 10)(
    input wire clk,
    input wire [ADDR_WIDTH-1:0] ADDR,
    input wire [DATA_WIDTH-1:0] DATA,
    (* direct_enable = 1 *) input wire cen,
    input wire we,
    output reg [DATA_WIDTH-1:0] Q
    );

    (* ramstyle = "no_rw_check" *) reg [DATA_WIDTH-1:0] mem[0:(2**ADDR_WIDTH)-1];
    
    always @(posedge clk) begin
        Q <=  mem[ADDR];

        if(cen && we) begin
            mem[ADDR] <= DATA;
        end
    end

endmodule