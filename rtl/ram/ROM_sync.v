//ROM_sync.v
//Author: @RndMnkIII
//Date: 15/03/22
//Intel//Altera Version

`default_nettype none
`timescale 1ns/1ps

module ROM_sync_intel #(parameter DATA_WIDTH = 8, ADDR_WIDTH = 15, DATA_HEX_FILE="dump.hex")(
    input wire clk,
    (* direct_enable = 1 *) input wire Cen,
    input wire [ADDR_WIDTH-1:0] ADDR, 
    output reg [DATA_WIDTH-1:0] DATA);

    /* ramstyle = "no_rw_check" */ reg [DATA_WIDTH-1:0] romdata [0:(2**ADDR_WIDTH)-1];

    initial begin
        $readmemh(DATA_HEX_FILE, romdata);
    end

    always @(posedge clk) begin
        if(Cen) DATA <= romdata[ADDR];
    end
endmodule
