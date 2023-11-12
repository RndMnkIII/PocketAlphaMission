//AlphaMissionCoreClocks_Cen.v
//Author: @RndMnkIII
//Date: 10/03/2022
//clk_i   53.6MHz
//clk_i_n 53.6MHz shifted 180 degrees.
`default_nettype none
`timescale 1ns/1ps

module AlphaMissionCoreClocks_Cen (
    input wire  i_clk,
    output wire clk_13p4_cen,
    output wire clk_13p4,
    output wire clk_13p4b_cen,
    output wire clk_13p4b,
    output wire clk_6p7_cen,
    output wire clk_6p7b_cen,
    output wire clk_3p35_cen,
    output wire clk_3p35b_cen,
    output wire clk_4_cen,
    output wire clk_4b_cen
);
    reg ck_stb1=1'b0;
    reg ck_stb2=1'b0;
    reg ck_stb3=1'b0;
    reg ck_stb4=1'b0;
    reg ck_stb5=1'b0;
    reg ck_stb6=1'b0;
    reg ck_stb7=1'b0;
    reg ck_stb8=1'b0;

    //--------- 13.4 MHz ---------
    reg	[3:0] counter1=4'h4; //16'hC000
    reg clk_13p4_r = 0;
    reg [3:0] counter2=4'hC; //16'h4000
    reg clk_13p4b_r = 0;

    //-------- 6.7 MHz ---------
    reg	[3:0] counter3=4'hE; //16'hE000
    reg [3:0] counter4=4'h6; //16'h6000
    //-------- 3.35 MHz---------
    reg	[3:0] counter5=4'hF; //16'hF000
    reg [3:0] counter6=4'h7; //16'h7000
    //---3---- 4 MHz ------------
    reg	[15:0] counter7=16'd63583;
    reg [15:0] counter8=16'd30815;

    //--------- 13.4 MHz ---------
    always @(negedge i_clk) begin
            { ck_stb1, counter1 } <= counter1 + 4'h4; //13.4MHz
    end

    assign clk_13p4_cen = ck_stb1;

    always @(posedge i_clk)
        if (clk_13p4_cen || clk_13p4b_cen) begin
            clk_13p4_r <= ~clk_13p4_r;
            clk_13p4b_r <= ~clk_13p4b_r;
        end 
    assign clk_13p4 = clk_13p4_r;
    assign clk_13p4b = clk_13p4b_r;

    always @(negedge i_clk) begin
            { ck_stb2, counter2 } <= counter2 + 4'h4    ; //13.4MHz 180degrees shifted
    end

    assign clk_13p4b_cen = ck_stb2;

    //--------- 6.7 MHz ----------
    always @(negedge i_clk) begin
            { ck_stb3, counter3 } <= counter3 + 4'h2; //6.7MHz
    end

    always @(negedge i_clk) begin
            { ck_stb4, counter4 } <= counter4 + 4'h2; //6.7MHz 180 degrees shifted
    end
    
    assign clk_6p7_cen = ck_stb3;
    assign clk_6p7b_cen = ck_stb4;

    //--------- 3.35 MHz ---------
    always @(negedge i_clk) begin
            { ck_stb5, counter5 } <= counter5 + 4'h1; //3.35MHz
    end

    always @(negedge i_clk) begin
            { ck_stb6, counter6 } <= counter6 + 4'h1; //3.35MHz 180 degrees shifted
    end

    assign clk_3p35_cen = ck_stb5;
    assign clk_3p35b_cen = ck_stb6;
    //--------- 4 MHz ------------
    always @(negedge i_clk) begin
            { ck_stb7, counter7 } <= counter7 + 16'd4891;//4MHz
    end

    always @(negedge i_clk) begin
            { ck_stb8, counter8 } <= counter8 + 16'd4891;//4MHz 180 degrees shifted
    end

    assign clk_4_cen = ck_stb7;
    assign clk_4b_cen = ck_stb8;
endmodule
