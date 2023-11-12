//n9bit_counter.sv
//Author: @RndMnkIII
//Date: 14/05/2022
`default_nettype none
`timescale 1ns/1ps

module n9bit_counter
(
  input wire Reset_n,
  input wire clk,
  input wire cen,
  input wire direction, // 1 = Up, 0 = Down
  input wire load_n,    // 1 = Count, 0 = Load
  input wire ent_n,
  input wire enp_n,
  input wire [8:0] P,
  output logic [8:0] Q   // 4-bit output
);

logic [8:0] count = 0;
logic last_cen;

always @(posedge clk) begin
    if(!Reset_n) begin
        count <= 9'h0;
        last_cen<= 1'b1;
    end
    else begin
        last_cen <= cen;

        if (cen && !last_cen) begin //detect rising edge
            if (~load_n)
            begin
                count <=  P;
            end
            else if (~ent_n & ~enp_n) // Count only if both enable signals are active (low)
            begin
                if (direction)
                begin
                // Counting up
                if (count == 9'd511) count <= 9'd0;
                else count <=  count + 1;
                end
                else
                begin
                // Counting down
                if (count == 9'd0) count <= 9'd511;
                else count <=  count - 1;
                end
            end
        end
    end
end

assign Q = count;
endmodule