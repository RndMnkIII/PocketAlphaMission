//SRAM_dual_sync_init.v
//Dual port static synchronous RAM of variable size with initialization file
//Author: @RndMnkIII
//Date: 15/03/22
`default_nettype none
`timescale 1ns/1ps

//default 8x1K ram size
module SRAM_dual_sync_init #(parameter DATA_WIDTH = 8, ADDR_WIDTH = 10, DATA_HEX_FILE="dump.hex")(
    input wire clk0,
    input wire clk1,
    input wire [ADDR_WIDTH-1:0] ADDR0,
    input wire [ADDR_WIDTH-1:0] ADDR1,
    input wire [DATA_WIDTH-1:0] DATA0,
    input wire [DATA_WIDTH-1:0] DATA1,
    (* direct_enable = 1 *) input wire cen0,
    (* direct_enable = 1 *) input wire cen1,
    input wire we0,
    input wire we1,
    output reg [DATA_WIDTH-1:0] Q0,
    output reg [DATA_WIDTH-1:0] Q1
    );

    (* ramstyle = "no_rw_check" *) reg [DATA_WIDTH-1:0] mem[0:(2**ADDR_WIDTH)-1];
    
    initial begin
        $readmemh(DATA_HEX_FILE, mem);
    end
    
    always @(posedge clk0) begin
        if (cen0) begin
            Q0 <=  mem[ADDR0];

            if(we0) begin
                mem[ADDR0] <= DATA0;
            end
        end
    end

    always @(posedge clk1) begin
        if (cen1) begin
            Q1 <=  mem[ADDR1];

            if(we1) begin
                mem[ADDR1] <= DATA1;
            end
        end
    end
endmodule