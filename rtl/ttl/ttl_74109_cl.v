// Dual J-/K flip-flop with clear; positive-edge-triggered

// Note:  Clear_bar is asynchronous as specified in datasheet for this device,
//ignored Preset_bar, for implementations that don't use the Preset input
`default_nettype none
`timescale 1ns/1ns

module ttl_74109_cl #(parameter BLOCKS = 2, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input wire [BLOCKS-1:0] Clear_bar,
  input wire [BLOCKS-1:0] J,
  input wire [BLOCKS-1:0] Kn,
  input wire [BLOCKS-1:0] Clk,
  output wire [BLOCKS-1:0] Q,
  output wire [BLOCKS-1:0] Q_bar
);

//------------------------------------------------//
reg [BLOCKS-1:0] Q_current;

generate
  genvar i;
  for (i = 0; i < BLOCKS; i = i + 1)
  begin: gen_blocks
    initial Q_current[i] = 1'b0; //supposition
    always @(posedge Clk[i] or negedge Clear_bar[i])
    begin
      if (!Clear_bar[i])
        Q_current[i] <= 1'b0; //CLEAR
      else
      begin
          if (!J[i] && !Kn[i])
            Q_current[i] <= 1'b0; //set low
          else if (J[i] && !Kn[i])
            Q_current[i] <= ~Q_current[i]; //toggle
          else if (J[i] && Kn[i])
            Q_current[i] <= 1'b1; //set high
          // else
          //   Q_current[i] <= Q_current[i]; //hold value
      end
    end
  end
endgenerate
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Q = Q_current;
assign #(DELAY_RISE, DELAY_FALL) Q_bar = ~Q_current;

endmodule