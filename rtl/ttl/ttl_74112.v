// Dual J-K flip-flop with set and clear; negative-edge-triggered

// Note: Preset_bar is synchronous, not asynchronous as specified in datasheet for this device,
//       in order to meet requirements for FPGA circuit design (see IceChips Technical Notes)
`default_nettype none
`timescale 1ns/1ns

module ttl_74112 #(parameter BLOCKS = 2, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input wire [BLOCKS-1:0] Preset_bar,
  input wire [BLOCKS-1:0] Clear_bar,
  input wire [BLOCKS-1:0] J,
  input wire [BLOCKS-1:0] K,
  input wire [BLOCKS-1:0] Clk,
  output wire [BLOCKS-1:0] Q,
  output wire [BLOCKS-1:0] Q_bar
);

//------------------------------------------------//
reg [BLOCKS-1:0] Q_current;
reg [BLOCKS-1:0] Preset_bar_previous;

generate
  genvar i;
  for (i = 0; i < BLOCKS; i = i + 1)
  begin: gen_blocks
    initial Q_current[i] = 1'b0; //supposition
    always @(negedge Clk[i] or negedge Clear_bar[i])
    begin
      if (!Clear_bar[i])
        Q_current[i] <= 1'b0;
      else if (!Preset_bar[i] && Preset_bar_previous[i])  // falling edge has occurred
        Q_current[i] <= 1'b1;
      else
      begin
        if (J[i] && !K[i] || !J[i] && K[i])
          Q_current[i] <= J[i];
        else if (J[i] && K[i])
          Q_current[i] <= ~Q_current[i];
        else
          Q_current[i] <= Q_current[i];

        Preset_bar_previous[i] <= Preset_bar[i];
      end
    end
  end
endgenerate
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Q = Q_current;
assign #(DELAY_RISE, DELAY_FALL) Q_bar = ~Q_current;

endmodule