//------------------------------------------------------------------------------
// SPDX-License-Identifier: MIT
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2023, OpenGateware authors and contributors
//------------------------------------------------------------------------------
//
// Autofire/Turbo Button Controller
//
// Copyright (c) 2023, Marcus Andrade <marcus@opengateware.org>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//------------------------------------------------------------------------------
//
// This module provides an "autofire" or "turbo" feature typically found in
// gaming controllers. When enabled, it automatically toggles the state of
// a button output at a user-defined rate, simulating rapid button presses
// without the need for manual input.
//
// Parameters:
// - CLK:        System clock frequency in Hz. Default value is 12MHz.
//
// Ports:
// - clk:        System clock input.
// - enable:     Control input to enable or disable the autofire feature.
// - rate:       User-defined rate input (0-63) indicating how many times per
//               second the `btn_out` should toggle its state.
// - btn_in:     Input representing the original state of the button.
// - btn_out:    Output representing the toggled state when autofire is enabled
//               or the original state when disabled.
//
// Operation:
// When `enable` is set to HIGH:
// - If `btn_in` is HIGH, `btn_out` will toggle at the defined rate.
// - If `btn_in` is LOW, `btn_out` remains LOW.
// When `enable` is set to LOW:
// - `btn_out` directly mirrors the `btn_in` state.
//
//------------------------------------------------------------------------------

`default_nettype none

module autofire
    #(
         parameter CLK = 12_000_000 //! Input clock frequency in Hz
     ) (
         // Clock and Reset
         input  logic       clk,    //! System Clock
         // Control
         input  logic       enable, //! Enable Autofire/Turbo
         input  logic [5:0] rate,   //! Times the autofire should toggle per second
         // Button In/Out
         input  logic       btn_in, //! Input  Button
         output logic       btn_out //! Output Button
     );

    logic [31:0] threshold;
    logic [31:0] counter   = 0;
    logic        btn_state = 0;

    always_ff @(posedge clk) begin : handleButton
        threshold = CLK / (2 * rate);
        if (enable) begin
            if (counter >= threshold) begin
                btn_state <= ~btn_state; // Toggle the state when we reach the threshold.
                counter   <= 0;          // Reset the counter.
            end
            else begin
                counter <= counter + 1;  // Increment the counter.
            end
        end
        else begin
            counter   <= 0;
            btn_state <= btn_in;         // Directly pass the button state if not in autofire mode.
        end
    end

    assign btn_out = btn_state;

endmodule
