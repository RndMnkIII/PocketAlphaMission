//ttl_74169_sync.v
//Author: @RndMnkIII
//Date: 16/03/2022
`default_nettype none
`timescale 1ns/1ps

module ttl_74169_sync
(
  input wire Reset_n,
  input wire clk,
  input wire cen,
  input wire direction, // 1 = Up, 0 = Down
  input wire load_n,    // 1 = Count, 0 = Load
  input wire ent_n,
  input wire enp_n,
  input wire [3:0] P,

  output wire rco_n,    // Ripple Carry-out (RCO)
  output wire [3:0] Q   // 4-bit output
);

//reg rco = 1'b0;
reg [3:0] count = 0;
reg last_cen;

always @(posedge clk) begin
    if(!Reset_n) begin
        count <= 4'h0;
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
                if (count == 4'd15) count <= 4'd0;
                else count <=  count + 1;
                end
                else
                begin
                // Counting down
                if (count == 4'd0) count <= 4'd15;
                else count <=  count - 1;
                end
            end
        end
    end
end

assign Q = count;
//assign rco_n = ~rco;
assign rco_n = !load_n ? 1'b0: ~((&count) & ~ent_n); 

endmodule