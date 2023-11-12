`default_nettype none

// Purpose: Synchronous 4-bit up/down binary counter
// Western: 74sn169
// USSR: 555IE17/555ИЕ17
module counter_74169
(
  input wire clk,
  input wire Reset_n,
  input wire cen,
  input wire direction, // 1 = Up, 0 = Down
  input wire load_n,    // 1 = Count, 0 = Load
  input wire ent_n,
  input wire enp_n,
  input wire [3:0] P,

  output logic rco_n,    // Ripple Carry-out (RCO)
  output logic [3:0] Q   // 4-bit output
);
  localparam counter_74169_delay = 20; // Min propagation delay from datasheet

  reg rco = 1'b0;
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
              count <= P;
              rco <= 1'b1;
            end
            else if (~ent_n & ~enp_n) // Count only if both enable signals are active (low)
            begin
              if (direction)
              begin
                // Counting up
                if (count == 4'd15) count <= 4'd0;
                else count <= count + 1;
                rco <= ~count[0] & count[1] & count[2] & count[3] & ~ent_n;    // Counted till 14 ('b1110) and active (low) ent_n
              end
              else
              begin
                // Counting down
                if (count == 4'd0) count <= 4'd15;
                else count <= count - 1;
                rco <= count[0] & ~count[1] & ~count[2] & ~count[3] & ~ent_n; // Counted till 1 ('b0001) and active (low) ent_n
              end
            end
          end
      end
  end
  assign Q = count;
  assign rco_n = ~rco;

endmodule