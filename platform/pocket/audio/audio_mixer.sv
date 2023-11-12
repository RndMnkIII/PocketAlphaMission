//------------------------------------------------------------------------------
// SPDX-License-Identifier: MIT
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2023, OpenGateware authors and contributors
//------------------------------------------------------------------------------
//
// Analogue Pocket Audio Mixer
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

`default_nettype none

module audio_mixer
    #(
         parameter DW           = 16,      //! Audio Data Width
         parameter STEREO       =  1,      //! Stereo Audio
         parameter MUTE_PAUSE   =  1,      //! Mute on Pause
         parameter AUDIO_FILTER =  0       //! Enable Audio Filters ROM
     ) (
         // Clocks and Reset
         input  logic          clk_74b,    //! Clock 74.25Mhz
         input  logic          clk_sys,    //! Core System Clock
         input  logic          reset,      //! Reset
         // Controls
         input  logic    [3:0] afilter_sw, //! Predefined Audio Filter Switch
         input  logic    [3:0] vol_att,    //! Volume ([0] Max | [7] Min)
         input  logic    [1:0] mix,        //! [0] No Mix | [1] 25% | [2] 50% | [3] 100% (mono)
         input  logic          pause_core, //! Mute Audio
         // Audio From Core
         input  logic          is_signed,  //! Signed Audio
         input  logic [DW-1:0] core_l,     //! Left  Channel Audio from Core
         input  logic [DW-1:0] core_r,     //! Right Channel Audio from Core
         // Pocket I2S
         output logic          audio_mclk, //! Serial Master Clock
         output logic          audio_lrck, //! Left/Right clock
         output logic          audio_dac   //! Serialized data
     );

    //! ------------------------------------------------------------------------
    //! Audio Clocks
    //! MCLK: 12.288MHz (256*Fs, where Fs = 48000Khz)
    //! SCLK:  3.072mhz (MCLK/4)
    //! ------------------------------------------------------------------------
    logic audio_sclk;

    mf_audio_pll audio_pll
                 (
                     .refclk   ( clk_74b    ),
                     .rst      ( 0          ),
                     .outclk_0 ( audio_mclk ),
                     .outclk_1 ( audio_sclk )
                 );

    //! ------------------------------------------------------------------------
    //! Pad core_l/core_r with zeros to maintain a consistent size of 16 bits
    //! ------------------------------------------------------------------------
    logic [15:0] core_al, core_ar;

    assign core_al =          DW == 16 ? core_l : {core_l, {16-DW{1'b0}}};
    assign core_ar = STEREO ? DW == 16 ? core_r : {core_r, {16-DW{1'b0}}} : core_al;

    //! ------------------------------------------------------------------------
    //! Synchronize audio with FIFO
    //! ------------------------------------------------------------------------
    logic [15:0] fifo_al, fifo_ar;

    audio_fifo audio_fifo
               (
                   // Clocks
                   .clk_sys    ( clk_sys    ),
                   .audio_mclk ( audio_mclk ),
                   // Core Audio
                   .core_al    ( core_al    ),
                   .core_ar    ( core_ar    ),
                   // Synced Audio
                   .audio_l    ( fifo_al    ),
                   .audio_r    ( fifo_ar    )
               );

    //! ------------------------------------------------------------------------
    //! Low Pass Filter
    //! ------------------------------------------------------------------------
    logic [31:0] aflt_rate;
    logic [39:0] acx;
    logic  [7:0] acx0, acx1, acx2;
    logic [23:0] acy0, acy1, acy2;

    generate
        if(AUDIO_FILTER == 1) begin
            arcade_filters arcade_filters
                           (
                               .clk        ( audio_mclk ),
                               .afilter_sw ( afilter_sw ),
                               .aflt_rate  ( aflt_rate  ),
                               .acx        ( acx        ),
                               .acx0       ( acx0       ),
                               .acx1       ( acx1       ),
                               .acx2       ( acx2       ),
                               .acy0       ( acy0       ),
                               .acy1       ( acy1       ),
                               .acy2       ( acy2       )
                           );
        end
        else begin
            assign aflt_rate =  32'd7056000; // Sampling Frequency
            assign acx       =  40'd4258969; // Base gain
            assign acx0      =   8'd3;       // gain scale for X0
            assign acx1      =   8'd3;       // gain scale for X1
            assign acx2      =   8'd1;       // gain scale for X2
            assign acy0      = -24'd6216759; // gain scale for Y0
            assign acy1      =  24'd6143386; // gain scale for Y1
            assign acy2      = -24'd2023767; // gain scale for Y2
        end
    endgenerate

    //! ------------------------------------------------------------------------
    //! Audio Filters
    //! ------------------------------------------------------------------------
    logic [15:0] audio_l, audio_r;
    logic        mute_audio;

    assign mute_audio = MUTE_PAUSE ? pause_core : 1'b0;

    audio_filters audio_filters
                  (
                      .clk       ( audio_mclk ),
                      .reset     ( reset      ),
                      // Controls
                      .att       ( {mute_audio, vol_att} ),
                      .mix       ( mix        ),
                      // Audio Filter
                      .flt_rate  ( aflt_rate  ),
                      .cx        ( acx        ),
                      .cx0       ( acx0       ),
                      .cx1       ( acx1       ),
                      .cx2       ( acx2       ),
                      .cy0       ( acy0       ),
                      .cy1       ( acy1       ),
                      .cy2       ( acy2       ),
                      // Audio from Core
                      .is_signed ( is_signed  ),
                      .core_l    ( fifo_al    ),
                      .core_r    ( fifo_ar    ),
                      // Filtered Audio Output
                      .audio_l   ( audio_l    ),
                      .audio_r   ( audio_r    )
                  );

    //! ------------------------------------------------------------------------
    //! Pocket I2S Output
    //! ------------------------------------------------------------------------
    pocket_i2s pocket_i2s
               (
                   // Serial Clock
                   .audio_sclk ( audio_sclk ), // [i]
                   // Audio Input
                   .audio_l    ( audio_l    ), // [i]
                   .audio_r    ( audio_r    ), // [i]
                   // Pocket I2S Interface
                   .audio_dac  ( audio_dac  ), // [o]
                   .audio_lrck ( audio_lrck )  // [o]
               );

endmodule
