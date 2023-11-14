//------------------------------------------------------------------------------
// SPDX-License-Identifier: MIT
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2023, OpenGateware authors and contributors
//------------------------------------------------------------------------------
//
// Copyright (c) 2023, Marcus Andrade <marcus@opengateware.org>
// Copyright (c) 2022, Analogue Enterprises Limited
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
// Platform Specific top-level
// Instantiated by the real top-level: apf_top
//------------------------------------------------------------------------------

`default_nettype none

module core_top
    #(
         //! ------------------------------------------------------------------------
         //! System Configuration Parameters
         //! ------------------------------------------------------------------------
         // Memory
         parameter USE_SDRAM    = 0,       //! Enable SDRAM
         parameter USE_SRAM     = 0,       //! Enable SRAM
         parameter USE_CRAM0    = 0,       //! Enable Cellular RAM #1
         parameter USE_CRAM1    = 0,       //! Enable Cellular RAM #2
         // Video
         parameter BPP_R        = 8,       //! Bits Per Pixel Red
         parameter BPP_G        = 8,       //! Bits Per Pixel Green
         parameter BPP_B        = 8,       //! Bits Per Pixel Blue
         // Audio
         parameter AUDIO_DW     = 16,      //! Audio Bits
         parameter AUDIO_S      = 1,       //! Signed Audio
         parameter STEREO       = 0,       //! Stereo Output
         parameter AUDIO_MIX    = 0,       //! [0] No Mix | [1] 25% | [2] 50% | [3] 100% (mono)
         parameter MUTE_PAUSE   = 1,       //! Mute Audio on Pause
         // Gamepad/Joystick
         parameter JOY_PADS     = 2,       //! Total Number of Gamepads
         parameter JOY_ALT      = 0,       //! 2 Players Alternate
         // Data I/O - [MPU -> FPGA]
         parameter DIO_MASK     = 4'h0,    //! Upper 4 bits of address
         parameter DIO_AW       = 27,      //! Address Width
         parameter DIO_DW       = 8,       //! Data Width (8 or 16 bits)
         parameter DIO_DELAY    = 4,       //! Number of clock cycles to delay each write output
         parameter DIO_HOLD     = 1,       //! Number of clock cycles to hold the ioctl_wr signal high
         // HiScore I/O - [MPU <-> FPGA]
         parameter HS_AW        = 16,      //! Max size of game RAM address for highscores
         parameter HS_SW        = 8,       //! Max size of capture RAM For highscore data (default 8 = 256 bytes max)
         parameter HS_CFG_AW    = 2,       //! Max size of RAM address for highscore.dat entries (default 4 = 16 entries max)
         parameter HS_CFG_LW    = 2,       //! Max size of length for each highscore.dat entries (default 1 = 256 bytes max)
         parameter HS_CONFIG    = 2,       //! Dataslot index for config transfer
         parameter HS_DATA      = 3,       //! Dataslot index for save data transfer
         parameter HS_NVM_SZ    = 32'd93,  //! Number bytes required for Save
         parameter HS_MASK      = 4'h1,    //! Upper 4 bits of address
         parameter HS_WR_DELAY  = 4,       //! Number of clock cycles to delay each write output
         parameter HS_WR_HOLD   = 1,       //! Number of clock cycles to hold the nvram_wr signal high
         parameter HS_RD_DELAY  = 4,       //! Number of clock cycles it takes for a read to complete
         // Save I/O - [MPU <-> FPGA]
         parameter SIO_MASK     = 4'h1,    //! Upper 4 bits of address
         parameter SIO_AW       = 27,      //! Address Width
         parameter SIO_DW       = 8,       //! Data Width (8 or 16 bits)
         parameter SIO_WR_DELAY = 4,       //! Number of clock cycles to delay each write output
         parameter SIO_WR_HOLD  = 1,       //! Number of clock cycles to hold the nvram_wr signal high
         parameter SIO_RD_DELAY = 4,       //! Number of clock cycles it takes for a read to complete
         parameter SIO_SAVE_IDX = 2        //! Dataslot index for save data transfer
     ) (
         //! --------------------------------------------------------------------
         //! Clock Inputs 74.25mhz.
         //! Not Phase Aligned, Treat These Domains as Asynchronous
         //! --------------------------------------------------------------------
         input wire          clk_74a, // mainclk1
         input wire          clk_74b, // mainclk1

         //! --------------------------------------------------------------------
         //! Cartridge Interface
         //! --------------------------------------------------------------------
         // switches between 3.3v and 5v mechanically
         // output enable for multibit translators controlled by pic32
         // GBA AD[15:8]
         inout  wire   [7:0] cart_tran_bank2,
         output wire         cart_tran_bank2_dir,
         // GBA AD[7:0]
         inout  wire   [7:0] cart_tran_bank3,
         output wire         cart_tran_bank3_dir,
         // GBA A[23:16]
         inout  wire   [7:0] cart_tran_bank1,
         output wire         cart_tran_bank1_dir,
         // GBA [7] PHI#
         // GBA [6] WR#
         // GBA [5] RD#
         // GBA [4] CS1#/CS#
         //     [3:0] unwired
         inout  wire   [7:4] cart_tran_bank0,
         output wire         cart_tran_bank0_dir,
         // GBA CS2#/RES#
         inout  wire         cart_tran_pin30,
         output wire         cart_tran_pin30_dir,
         // when GBC cart is inserted, this signal when low or weak will pull GBC /RES low with a special circuit
         // the goal is that when unconfigured, the FPGA weak pullups won't interfere.
         // thus, if GBC cart is inserted, FPGA must drive this high in order to let the level translators
         // and general IO drive this pin.
         output wire         cart_pin30_pwroff_reset,
         // GBA IRQ/DRQ
         inout  wire         cart_tran_pin31,
         output wire         cart_tran_pin31_dir,

         //! --------------------------------------------------------------------
         //! Infrared
         //! --------------------------------------------------------------------
         input  wire         port_ir_rx,
         output wire         port_ir_tx,
         output wire         port_ir_rx_disable,

         //! --------------------------------------------------------------------
         //! GBA link port
         //! --------------------------------------------------------------------
         inout  wire         port_tran_si,
         output wire         port_tran_si_dir,
         inout  wire         port_tran_so,
         output wire         port_tran_so_dir,
         inout  wire         port_tran_sck,
         output wire         port_tran_sck_dir,
         inout  wire         port_tran_sd,
         output wire         port_tran_sd_dir,

         //! --------------------------------------------------------------------
         //! CellularRAM #0, 4Mx16 x2 [16 Mbyte] PSRAM (AS1C8M16PL-70BIN)
         //! --------------------------------------------------------------------
         output wire [21:16] cram0_a,       // Address bus
         inout  wire  [15:0] cram0_dq,      // Bidirectional data bus
         input  wire         cram0_wait,    // Wait
         output wire         cram0_clk,     // Clock
         output wire         cram0_adv_n,   // Address valid
         output wire         cram0_cre,     // Control register enable
         output wire         cram0_ce0_n,   // First Chip enable
         output wire         cram0_ce1_n,   // Second Chip enable
         output wire         cram0_oe_n,    // Output enable
         output wire         cram0_we_n,    // Write enable
         output wire         cram0_ub_n,    // Upper byte enable. DQ[15:8]
         output wire         cram0_lb_n,    // Lower byte enable. DQ[7:0]

         //! --------------------------------------------------------------------
         //! CellularRAM #1, 4Mx16 x2 [16 Mbyte] PSRAM (AS1C8M16PL-70BIN)
         //! --------------------------------------------------------------------
         output wire [21:16] cram1_a,       // Address bus
         inout  wire  [15:0] cram1_dq,      // Bidirectional data bus
         input  wire         cram1_wait,    // Wait
         output wire         cram1_clk,     // Clock
         output wire         cram1_adv_n,   // Address valid
         output wire         cram1_cre,     // Control register enable
         output wire         cram1_ce0_n,   // First Chip enable
         output wire         cram1_ce1_n,   // Second Chip enable
         output wire         cram1_oe_n,    // Output enable
         output wire         cram1_we_n,    // Write enable
         output wire         cram1_ub_n,    // Upper byte enable. DQ[15:8]
         output wire         cram1_lb_n,    // Lower byte enable. DQ[7:0]

         //! --------------------------------------------------------------------
         //! SDRAM, 32Mx16 [64 Mbyte] (AS4C32M16MSA-6BIN)
         //! --------------------------------------------------------------------
         output wire  [12:0] dram_a,        // Address bus
         output wire   [1:0] dram_ba,       // Bank select (single bits)
         inout  wire  [15:0] dram_dq,       // Bidirectional data bus
         output wire   [1:0] dram_dqm,      // High/low byte mask
         output wire         dram_clk,      // Clock
         output wire         dram_cke,      // Clock enable
         output wire         dram_ras_n,    // Select row address
         output wire         dram_cas_n,    // Select column address
         output wire         dram_we_n,     // Write enable

         //! --------------------------------------------------------------------
         //! SRAM, 128Kx16 [256 Kbyte] (AS6C2016-55BIN)
         //! --------------------------------------------------------------------
         output wire  [16:0] sram_a,        // Address bus
         inout  wire  [15:0] sram_dq,       // Bidirectional data bus
         output wire         sram_oe_n,     // Output enable
         output wire         sram_we_n,     // Write enable
         output wire         sram_ub_n,     // Upper Byte Mask
         output wire         sram_lb_n,     // Lower Byte Mask

         //! --------------------------------------------------------------------
         //! VBlank driven by dock for sync in a certain mode
         //! --------------------------------------------------------------------
         input  wire         vblank,

         //! --------------------------------------------------------------------
         //! I/O to 6515D breakout USB UART
         //! --------------------------------------------------------------------
         output wire         dbg_tx,
         input  wire         dbg_rx,

         //! --------------------------------------------------------------------
         //! I/O pads near jtag connector user can solder to
         //! --------------------------------------------------------------------
         output wire         user1,
         input  wire         user2,

         //! --------------------------------------------------------------------
         //! RFU internal i2c bus
         //! --------------------------------------------------------------------
         inout  wire         aux_sda,
         output wire         aux_scl,

         //! --------------------------------------------------------------------
         //! RFU, do not use !!!
         //! --------------------------------------------------------------------
         output wire         vpll_feed,

         //! --------------------------------------------------------------------
         //! Logical Connections ////////////////////////////////////////////////
         //! --------------------------------------------------------------------

         //! --------------------------------------------------------------------
         //! Video Output to Scaler
         //! --------------------------------------------------------------------
         output wire  [23:0] video_rgb,
         output wire         video_rgb_clock,
         output wire         video_rgb_clock_90,
         output wire         video_hs,
         output wire         video_vs,
         output wire         video_de,
         output wire         video_skip,

         //! --------------------------------------------------------------------
         //! Audio
         //! --------------------------------------------------------------------
         output wire         audio_mclk,
         output wire         audio_lrck,
         output wire         audio_dac,
         input  wire         audio_adc,

         //! --------------------------------------------------------------------
         //! Bridge Bus Connection (synchronous to clk_74a)
         //! --------------------------------------------------------------------
         output wire         bridge_endian_little,
         input  wire  [31:0] bridge_addr,
         input  wire         bridge_rd,
         output reg   [31:0] bridge_rd_data,
         input  wire         bridge_wr,
         input  wire  [31:0] bridge_wr_data,

         //! --------------------------------------------------------------------
         //! Controller Data
         //! --------------------------------------------------------------------
         input  wire  [31:0] cont1_key,
         input  wire  [31:0] cont2_key,
         input  wire  [31:0] cont3_key,
         input  wire  [31:0] cont4_key,
         input  wire  [31:0] cont1_joy,
         input  wire  [31:0] cont2_joy,
         input  wire  [31:0] cont3_joy,
         input  wire  [31:0] cont4_joy,
         input  wire  [15:0] cont1_trig,
         input  wire  [15:0] cont2_trig,
         input  wire  [15:0] cont3_trig,
         input  wire  [15:0] cont4_trig
     );

    //! ------------------------------------------------------------------------
    //! Infrared
    //! ------------------------------------------------------------------------
    // not using the IR port, so turn off both the LED, and
    // disable the receive circuit to save power
    assign port_ir_tx         = 0;
    assign port_ir_rx_disable = 1;

    //! ------------------------------------------------------------------------
    //! Bridge endianness
    //! ------------------------------------------------------------------------
    assign bridge_endian_little = 0;

    //! ------------------------------------------------------------------------
    //! Cartridge Slot
    //! ------------------------------------------------------------------------
    // cart is unused, so set all level translators accordingly
    // directions are 0:IN, 1:OUT
    assign cart_tran_bank3         = 8'hZZ;
    assign cart_tran_bank3_dir     = 1'b0;
    assign cart_tran_bank2         = 8'hZZ;
    assign cart_tran_bank2_dir     = 1'b0;
    assign cart_tran_bank1         = 8'hZZ;
    assign cart_tran_bank1_dir     = 1'b0;
    assign cart_tran_bank0         = 4'hF;
    assign cart_tran_bank0_dir     = 1'b1;
    assign cart_tran_pin30         = 1'b0;  // reset or cs2, we let the hw control it by itself
    assign cart_tran_pin30_dir     = 1'bZ;
    assign cart_pin30_pwroff_reset = 1'b0;  // hardware can control this
    assign cart_tran_pin31         = 1'bZ;  // input
    assign cart_tran_pin31_dir     = 1'b0;  // input

    //! ------------------------------------------------------------------------
    //! GB/GBA Link Port
    //! ------------------------------------------------------------------------
    // link port is input only
    assign port_tran_so      = 1'bZ;
    assign port_tran_so_dir  = 1'b0; // SO is output only
    assign port_tran_si      = 1'bZ;
    assign port_tran_si_dir  = 1'b0; // SI is input only
    assign port_tran_sck     = 1'bZ;
    assign port_tran_sck_dir = 1'b0; // clock direction can change
    assign port_tran_sd      = 1'bZ;
    assign port_tran_sd_dir  = 1'b0; // SD is input and not used

    //! ------------------------------------------------------------------------
    //! MISC
    //! ------------------------------------------------------------------------
    assign dbg_tx    = 1'bZ;
    assign user1     = 1'bZ;
    assign aux_scl   = 1'bZ;
    assign vpll_feed = 1'bZ;

    //! Tie off the memory the pins not being used /////////////////////////////
    generate
    //! ------------------------------------------------------------------------
    //! Cellular RAM
    //! ------------------------------------------------------------------------
        if(USE_CRAM0 == 0) begin
            assign cram0_a     = 'h0;
            assign cram0_dq    = {16{1'bZ}};
            assign cram0_clk   = 0;
            assign cram0_adv_n = 1;
            assign cram0_cre   = 0;
            assign cram0_ce0_n = 1;
            assign cram0_ce1_n = 1;
            assign cram0_oe_n  = 1;
            assign cram0_we_n  = 1;
            assign cram0_ub_n  = 1;
            assign cram0_lb_n  = 1;
        end

        if(USE_CRAM1 == 0) begin
            assign cram1_a     = 'h0;
            assign cram1_dq    = {16{1'bZ}};
            assign cram1_clk   = 0;
            assign cram1_adv_n = 1;
            assign cram1_cre   = 0;
            assign cram1_ce0_n = 1;
            assign cram1_ce1_n = 1;
            assign cram1_oe_n  = 1;
            assign cram1_we_n  = 1;
            assign cram1_ub_n  = 1;
            assign cram1_lb_n  = 1;
        end

    //! ------------------------------------------------------------------------
    //! SDRAM
    //! ------------------------------------------------------------------------
        if(USE_SDRAM == 0) begin
            assign dram_a     = 'h0;
            assign dram_ba    = 'h0;
            assign dram_dq    = {16{1'bZ}};
            assign dram_dqm   = 'h0;
            assign dram_clk   = 'h0;
            assign dram_cke   = 'h0;
            assign dram_ras_n = 'h1;
            assign dram_cas_n = 'h1;
            assign dram_we_n  = 'h1;
        end

    //! ------------------------------------------------------------------------
    //! SRAM
    //! ------------------------------------------------------------------------
        if(USE_SRAM == 0) begin
            assign sram_a    = 'h0;
            assign sram_dq   = {16{1'bZ}};
            assign sram_oe_n = 1;
            assign sram_we_n = 1;
            assign sram_ub_n = 1;
            assign sram_lb_n = 1;
        end
    endgenerate

    //! ------------------------------------------------------------------------
    //! Host/Target Command Handler
    //! ------------------------------------------------------------------------
    wire        reset_n;  // driven by host commands, can be used as core-wide reset
    wire [31:0] cmd_bridge_rd_data;

    // bridge host commands
    // synchronous to clk_74a
    wire        status_boot_done  = pll_core_locked_s;
    wire        status_setup_done = pll_core_locked_s; // rising edge triggers a target command
    wire        status_running    = reset_n;           // we are running as soon as reset_n goes high

    wire        dataslot_requestread;
    wire [15:0] dataslot_requestread_id;
    wire        dataslot_requestread_ack = 1;
    wire        dataslot_requestread_ok  = 1;

    wire        dataslot_requestwrite;
    wire [15:0] dataslot_requestwrite_id;
    wire [31:0] dataslot_requestwrite_size;
    wire        dataslot_requestwrite_ack = 1;
    wire        dataslot_requestwrite_ok  = 1;

    wire        dataslot_update;
    wire [15:0] dataslot_update_id;
    wire [31:0] dataslot_update_size;

    wire        dataslot_allcomplete;

    wire [31:0] rtc_epoch_seconds;
    wire [31:0] rtc_date_bcd;
    wire [31:0] rtc_time_bcd;
    wire        rtc_valid;

    wire        savestate_supported;
    wire [31:0] savestate_addr;
    wire [31:0] savestate_size;
    wire [31:0] savestate_maxloadsize;

    wire        savestate_start;
    wire        savestate_start_ack;
    wire        savestate_start_busy;
    wire        savestate_start_ok;
    wire        savestate_start_err;

    wire        savestate_load;
    wire        savestate_load_ack;
    wire        savestate_load_busy;
    wire        savestate_load_ok;
    wire        savestate_load_err;

    wire        osnotify_inmenu;

    // bridge target commands
    // synchronous to clk_74a
    reg         target_dataslot_read;
    reg         target_dataslot_write;
    reg         target_dataslot_getfile;    // require additional param/resp structs to be mapped
    reg         target_dataslot_openfile;   // require additional param/resp structs to be mapped

    wire        target_dataslot_ack;
    wire        target_dataslot_done;
    wire  [2:0] target_dataslot_err;

    reg  [15:0] target_dataslot_id;
    reg  [31:0] target_dataslot_slotoffset;
    reg  [31:0] target_dataslot_bridgeaddr;
    reg  [31:0] target_dataslot_length;

    wire [31:0] target_buffer_param_struct; // to be mapped/implemented when using some Target commands
    wire [31:0] target_buffer_resp_struct;  // to be mapped/implemented when using some Target commands

    // bridge data slot access
    // synchronous to clk_74a
    wire  [9:0] datatable_addr;
    wire        datatable_wren;
    wire [31:0] datatable_data;
    wire [31:0] datatable_q;

    core_bridge_cmd icb
                    (
                        .clk                        ( clk_74a                    ),
                        .reset_n                    ( reset_n                    ),

                        .bridge_endian_little       ( bridge_endian_little       ),
                        .bridge_addr                ( bridge_addr                ),
                        .bridge_rd                  ( bridge_rd                  ),
                        .bridge_rd_data             ( cmd_bridge_rd_data         ),
                        .bridge_wr                  ( bridge_wr                  ),
                        .bridge_wr_data             ( bridge_wr_data             ),

                        .status_boot_done           ( status_boot_done           ),
                        .status_setup_done          ( status_setup_done          ),
                        .status_running             ( status_running             ),

                        .dataslot_requestread       ( dataslot_requestread       ),
                        .dataslot_requestread_id    ( dataslot_requestread_id    ),
                        .dataslot_requestread_ack   ( dataslot_requestread_ack   ),
                        .dataslot_requestread_ok    ( dataslot_requestread_ok    ),

                        .dataslot_requestwrite      ( dataslot_requestwrite      ),
                        .dataslot_requestwrite_id   ( dataslot_requestwrite_id   ),
                        .dataslot_requestwrite_size ( dataslot_requestwrite_size ),
                        .dataslot_requestwrite_ack  ( dataslot_requestwrite_ack  ),
                        .dataslot_requestwrite_ok   ( dataslot_requestwrite_ok   ),

                        .dataslot_update            ( dataslot_update            ),
                        .dataslot_update_id         ( dataslot_update_id         ),
                        .dataslot_update_size       ( dataslot_update_size       ),

                        .dataslot_allcomplete       ( dataslot_allcomplete       ),

                        .rtc_epoch_seconds          ( rtc_epoch_seconds          ),
                        .rtc_date_bcd               ( rtc_date_bcd               ),
                        .rtc_time_bcd               ( rtc_time_bcd               ),
                        .rtc_valid                  ( rtc_valid                  ),

                        .savestate_supported        ( savestate_supported        ),
                        .savestate_addr             ( savestate_addr             ),
                        .savestate_size             ( savestate_size             ),
                        .savestate_maxloadsize      ( savestate_maxloadsize      ),

                        .savestate_start            ( savestate_start            ),
                        .savestate_start_ack        ( savestate_start_ack        ),
                        .savestate_start_busy       ( savestate_start_busy       ),
                        .savestate_start_ok         ( savestate_start_ok         ),
                        .savestate_start_err        ( savestate_start_err        ),

                        .savestate_load             ( savestate_load             ),
                        .savestate_load_ack         ( savestate_load_ack         ),
                        .savestate_load_busy        ( savestate_load_busy        ),
                        .savestate_load_ok          ( savestate_load_ok          ),
                        .savestate_load_err         ( savestate_load_err         ),

                        .osnotify_inmenu            ( osnotify_inmenu            ),

                        .target_dataslot_read       ( target_dataslot_read       ),
                        .target_dataslot_write      ( target_dataslot_write      ),
                        .target_dataslot_getfile    ( target_dataslot_getfile    ),
                        .target_dataslot_openfile   ( target_dataslot_openfile   ),

                        .target_dataslot_ack        ( target_dataslot_ack        ),
                        .target_dataslot_done       ( target_dataslot_done       ),
                        .target_dataslot_err        ( target_dataslot_err        ),

                        .target_dataslot_id         ( target_dataslot_id         ),
                        .target_dataslot_slotoffset ( target_dataslot_slotoffset ),
                        .target_dataslot_bridgeaddr ( target_dataslot_bridgeaddr ),
                        .target_dataslot_length     ( target_dataslot_length     ),

                        .target_buffer_param_struct ( target_buffer_param_struct ),
                        .target_buffer_resp_struct  ( target_buffer_resp_struct  ),

                        .datatable_addr             ( datatable_addr             ),
                        .datatable_wren             ( datatable_wren             ),
                        .datatable_data             ( datatable_data             ),
                        .datatable_q                ( datatable_q                )
                    );

    //! END OF APF /////////////////////////////////////////////////////////////

    //! ////////////////////////////////////////////////////////////////////////
    //! @ System Modules
    //! ////////////////////////////////////////////////////////////////////////

    //! ------------------------------------------------------------------------
    //! APF Bridge Read Data
    //! ------------------------------------------------------------------------
    wire [31:0] int_bridge_rd_data;
    wire [31:0] nvm_bridge_rd_data, nvm_bridge_rd_data_s;

    // Synchronize nvm_bridge_rd_data into clk_74a domain before usage
    synch_3 #(32) sync_nvm(nvm_bridge_rd_data, nvm_bridge_rd_data_s, clk_74a);

    always_comb begin
        casex(bridge_addr)
            32'h10000000: begin bridge_rd_data <= nvm_bridge_rd_data_s; end // HiScore/NVRAM/SRAM Save
            32'hF0000000: begin bridge_rd_data <= int_bridge_rd_data;   end // Reset
            32'hF0000010: begin bridge_rd_data <= int_bridge_rd_data;   end // Service Mode Switch
            32'hF1000000: begin bridge_rd_data <= int_bridge_rd_data;   end // DIP Switches
            32'hF2000000: begin bridge_rd_data <= int_bridge_rd_data;   end // Modifiers
            32'hF3000000: begin bridge_rd_data <= int_bridge_rd_data;   end // A/V Filters
            32'hF4000000: begin bridge_rd_data <= int_bridge_rd_data;   end // Extra DIP Switches
            32'hF8xxxxxx: begin bridge_rd_data <= cmd_bridge_rd_data;   end // APF Bridge (Reserved)
            32'hFA000000: begin bridge_rd_data <= int_bridge_rd_data;   end // Status Low  [31:0]
            32'hFB000000: begin bridge_rd_data <= int_bridge_rd_data;   end // Status High [63:32]
            default:      begin bridge_rd_data <= 0;                    end
        endcase
    end

    //! ------------------------------------------------------------------------
    //! Pause Core (Analogue OS Menu/Module Request)
    //! ------------------------------------------------------------------------
    wire pause_core, pause_req;

    pause_crtl core_pause
               (
                   .clk_sys    ( clk_sys         ),
                   .os_inmenu  ( osnotify_inmenu ),
                   .pause_req  ( pause_req       ),
                   .pause_core ( pause_core      )
               );

    //! ------------------------------------------------------------------------
    //! Interact: Dip Switches, Modifiers, Filters and Reset
    //! ------------------------------------------------------------------------
    wire  [7:0] dip_sw0, dip_sw1, dip_sw2, dip_sw3;
    wire  [7:0] ext_sw0, ext_sw1, ext_sw2, ext_sw3;
    wire  [7:0] mod_sw0, mod_sw1, mod_sw2, mod_sw3;
    wire  [3:0] scnl_sw, smask_sw, afilter_sw, vol_att;
    wire [63:0] status;
    wire [15:0] nvram_size;
    wire        reset_sw, svc_sw;

    interact pocket_interact
             (
                 // Clocks and Reset
                 .clk_74a          ( clk_74a            ),
                 .clk_sync         ( clk_sys            ),
                 .reset_n          ( reset_n            ),
                 // Pocket Bridge
                 .bridge_addr      ( bridge_addr        ),
                 .bridge_wr        ( bridge_wr          ),
                 .bridge_wr_data   ( bridge_wr_data     ),
                 .bridge_rd        ( bridge_rd          ),
                 .bridge_rd_data   ( int_bridge_rd_data ),
                 // Service Mode Switch
                 .svc_sw           ( svc_sw             ),
                 // DIP Switches
                 .dip_sw0          ( dip_sw0            ),
                 .dip_sw1          ( dip_sw1            ),
                 .dip_sw2          ( dip_sw2            ),
                 .dip_sw3          ( dip_sw3            ),
                 // Extra DIP Switches
                 .ext_sw0          ( ext_sw0            ),
                 .ext_sw1          ( ext_sw1            ),
                 .ext_sw2          ( ext_sw2            ),
                 .ext_sw3          ( ext_sw3            ),
                 // Modifiers
                 .mod_sw0          ( mod_sw0            ),
                 .mod_sw1          ( mod_sw1            ),
                 .mod_sw2          ( mod_sw2            ),
                 .mod_sw3          ( mod_sw3            ),
                 // Status (Legacy Support)
                 .status           ( status             ),
                 // Filters Switches
                 .scnl_sw          ( scnl_sw            ),
                 .smask_sw         ( smask_sw           ),
                 .afilter_sw       ( afilter_sw         ),
                 .vol_att          ( vol_att            ),
                 // High Score NVRAM
                 .nvram_size       ( nvram_size         ),
                 // Reset Switch
                 .reset_sw         ( reset_sw           )
             );

    //! ------------------------------------------------------------------------
    //! Audio
    //! ------------------------------------------------------------------------
    wire [AUDIO_DW-1:0] core_snd_l, core_snd_r; // Audio Mono/Left/Right

    audio_mixer #(.DW(AUDIO_DW),.MUTE_PAUSE(MUTE_PAUSE),.STEREO(STEREO)) pocket_audio_mixer
                (
                    // Clocks and Reset
                    .clk_74b    ( clk_74b    ),
                    .clk_sys    ( clk_sys    ),
                    .reset      ( reset_sw   ),
                    // Controls
                    .afilter_sw ( afilter_sw ),
                    .vol_att    ( vol_att    ),
                    .mix        ( AUDIO_MIX  ),
                    .pause_core ( pause_core ),
                    // Audio From Core
                    .is_signed  ( AUDIO_S    ),
                    .core_l     ( core_snd_l ),
                    .core_r     ( core_snd_r ),
                    // I2S
                    .audio_mclk ( audio_mclk ),
                    .audio_lrck ( audio_lrck ),
                    .audio_dac  ( audio_dac  )
                );

    //! ------------------------------------------------------------------------
    //! Video
    //! ------------------------------------------------------------------------
    wire       [2:0] video_preset;     // Video Preset Configuration
    wire [BPP_R-1:0] core_r;           // Video Red
    wire [BPP_G-1:0] core_g;           // Video Green
    wire [BPP_B-1:0] core_b;           // Video Blue
    wire             core_hs, core_hb; // Horizontal Sync/Blank
    wire             core_vs, core_vb; // Vertical Sync/Blank
    wire             core_de;          // Display Enable

    assign core_de = ~(core_hb | core_vb);


    wire [23:0] s_video_rgb;
    wire        s_video_hs, s_video_vs, s_video_de;
    

    scanlines scanlines_h
              (
                  .clk_vid        ( clk_vid     ),
                  .scnl_sw        ( scnl_sw),

                  .core_rgb       ( {core_r,core_g,core_b} ),
                  .core_vs        ( core_vs    ),
                  .core_hs        ( core_hs    ),
                  .core_de        ( core_de    ),

                  .scnl_rgb        ( s_video_rgb ),
                  .scnl_vs        ( s_video_vs  ),
                  .scnl_hs        ( s_video_hs  ),
                  .scnl_de        ( s_video_de  )
              );

    video_mixer #(.RW(BPP_R),.GW(BPP_G),.BW(BPP_B)) pocket_video_mixer
                (
                    // Clocks
                    .clk_74a                  ( clk_74a                  ),
                    .clk_sys                  ( clk_sys                  ),
                    .clk_vid                  ( clk_vid                  ),
                    .clk_vid_90deg            ( clk_vid_90deg            ),
                    // Input Controls
                    .video_preset             ( video_preset             ),
                    .scnl_sw                  ( scnl_sw                  ),
                    .smask_sw                 ( smask_sw                 ),
                    // Input Video from Core
                    .core_r                   ( s_video_rgb[23:16]       ),
                    .core_g                   ( s_video_rgb[15:8]        ),
                    .core_b                   ( s_video_rgb[7:0]         ),
                    .core_vs                  ( s_video_vs                  ),
                    .core_hs                  ( s_video_hs                  ),
                    .core_de                  ( s_video_de                  ),
                    // Output to Display
                    .video_rgb                ( video_rgb                ),
                    .video_vs                 ( video_vs                 ),
                    .video_hs                 ( video_hs                 ),
                    .video_de                 ( video_de                 ),
                    .video_rgb_clock          ( video_rgb_clock          ),
                    .video_rgb_clock_90       ( video_rgb_clock_90       ),
                    // Pocket Bridge Slots
                    .dataslot_requestwrite    ( dataslot_requestwrite    ), // [i]
                    .dataslot_requestwrite_id ( dataslot_requestwrite_id ), // [i]
                    .dataslot_allcomplete     ( dataslot_allcomplete     ), // [i]
                    // MPU -> FPGA (MPU Write to FPGA)
                    // Pocket Bridge
                    .bridge_endian_little     ( bridge_endian_little     ), // [i]
                    .bridge_addr              ( bridge_addr              ), // [i]
                    .bridge_wr                ( bridge_wr                ), // [i]
                    .bridge_wr_data           ( bridge_wr_data           )  // [i]
                );

    // video_mixer #(.RW(BPP_R),.GW(BPP_G),.BW(BPP_B)) pocket_video_mixer
    //             (
    //                 // Clocks
    //                 .clk_74a                  ( clk_74a                  ),
    //                 .clk_sys                  ( clk_sys                  ),
    //                 .clk_vid                  ( clk_vid                  ),
    //                 .clk_vid_90deg            ( clk_vid_90deg            ),
    //                 // Input Controls
    //                 .video_preset             ( video_preset             ),
    //                 .scnl_sw                  ( scnl_sw                  ),
    //                 .smask_sw                 ( smask_sw                 ),
    //                 // Input Video from Core
    //                 .core_r                   ( core_r                   ),
    //                 .core_g                   ( core_g                   ),
    //                 .core_b                   ( core_b                   ),
    //                 .core_vs                  ( core_vs                  ),
    //                 .core_hs                  ( core_hs                  ),
    //                 .core_de                  ( core_de                  ),
    //                 // Output to Display
    //                 .video_rgb                ( video_rgb                ),
    //                 .video_vs                 ( video_vs                 ),
    //                 .video_hs                 ( video_hs                 ),
    //                 .video_de                 ( video_de                 ),
    //                 .video_rgb_clock          ( video_rgb_clock          ),
    //                 .video_rgb_clock_90       ( video_rgb_clock_90       ),
    //                 // Pocket Bridge Slots
    //                 .dataslot_requestwrite    ( dataslot_requestwrite    ), // [i]
    //                 .dataslot_requestwrite_id ( dataslot_requestwrite_id ), // [i]
    //                 .dataslot_allcomplete     ( dataslot_allcomplete     ), // [i]
    //                 // MPU -> FPGA (MPU Write to FPGA)
    //                 // Pocket Bridge
    //                 .bridge_endian_little     ( bridge_endian_little     ), // [i]
    //                 .bridge_addr              ( bridge_addr              ), // [i]
    //                 .bridge_wr                ( bridge_wr                ), // [i]
    //                 .bridge_wr_data           ( bridge_wr_data           )  // [i]
    //             );

    //! ------------------------------------------------------------------------
    //! Data I/O
    //! ------------------------------------------------------------------------
    wire              ioctl_download;
    wire       [15:0] ioctl_index;
    wire              ioctl_wr;
    wire [DIO_AW-1:0] ioctl_addr;
    wire [DIO_DW-1:0] ioctl_data;

    data_io #(.MASK(DIO_MASK),.AW(DIO_AW),.DW(DIO_DW),.DELAY(DIO_DELAY),.HOLD(DIO_HOLD)) pocket_data_io
            (
                // Clocks and Reset
                .clk_74a                  ( clk_74a                  ),
                .clk_memory               ( clk_sys                  ),
                // Pocket Bridge Slots
                .dataslot_requestwrite    ( dataslot_requestwrite    ), // [i]
                .dataslot_requestwrite_id ( dataslot_requestwrite_id ), // [i]
                .dataslot_allcomplete     ( dataslot_allcomplete     ), // [i]
                // MPU -> FPGA (MPU Write to FPGA)
                // Pocket Bridge
                .bridge_endian_little     ( bridge_endian_little     ), // [i]
                .bridge_addr              ( bridge_addr              ), // [i]
                .bridge_wr                ( bridge_wr                ), // [i]
                .bridge_wr_data           ( bridge_wr_data           ), // [i]
                // Controller Interface
                .ioctl_download           ( ioctl_download           ), // [o]
                .ioctl_index              ( ioctl_index              ), // [o]
                .ioctl_wr                 ( ioctl_wr                 ), // [o]
                .ioctl_addr               ( ioctl_addr               ), // [o]
                .ioctl_data               ( ioctl_data               )  // [o]
            );

    //! ------------------------------------------------------------------------
    //! Gamepad/Analog Stick
    //! ------------------------------------------------------------------------
    // Player 1
    // - DPAD
    wire       p1_up,     p1_down,   p1_left,   p1_right;
    wire       p1_btn_y,  p1_btn_x,  p1_btn_b,  p1_btn_a;
    wire       p1_btn_l1, p1_btn_l2, p1_btn_l3;
    wire       p1_btn_r1, p1_btn_r2, p1_btn_r3;
    wire       p1_select, p1_start;
    // - Analog
    wire       j1_up,     j1_down,   j1_left,   j1_right;
    wire [7:0] j1_lx,     j1_ly,     j1_rx,     j1_ry;

    // Player 2
    // - DPAD
    wire       p2_up,     p2_down,   p2_left,   p2_right;
    wire       p2_btn_y,  p2_btn_x,  p2_btn_b,  p2_btn_a;
    wire       p2_btn_l1, p2_btn_l2, p2_btn_l3;
    wire       p2_btn_r1, p2_btn_r2, p2_btn_r3;
    wire       p2_select, p2_start;
    // - Analog
    wire       j2_up,     j2_down,   j2_left,   j2_right;
    wire [7:0] j2_lx,     j2_ly,     j2_rx,     j2_ry;

    // Single Player or Alternate 2 Players for Arcade
    wire m_start1, m_start2;
    wire m_coin1,  m_coin2, m_coin;
    wire m_up,     m_down,  m_left, m_right;
    wire m_btn1,   m_btn2,  m_btn3, m_btn4;
    wire m_btn5,   m_btn6,  m_btn7, m_btn8;

    gamepad #(.JOY_PADS(JOY_PADS),.JOY_ALT(JOY_ALT)) pocket_gamepad
            (
                .clk_sys   ( clk_sys   ),
                // Pocket PAD Interface
                .cont1_key ( cont1_key ), .cont1_joy ( cont1_joy ),
                .cont2_key ( cont2_key ), .cont2_joy ( cont2_joy ),
                .cont3_key ( cont3_key ), .cont3_joy ( cont3_joy ),
                .cont4_key ( cont4_key ), .cont4_joy ( cont4_joy ),
                // Player 1
                .p1_up     ( p1_up     ), .p1_down   ( p1_down   ),
                .p1_left   ( p1_left   ), .p1_right  ( p1_right  ),
                .p1_y      ( p1_btn_y  ), .p1_x      ( p1_btn_x  ),
                .p1_b      ( p1_btn_b  ), .p1_a      ( p1_btn_a  ),
                .p1_l1     ( p1_btn_l1 ), .p1_r1     ( p1_btn_r1 ),
                .p1_l2     ( p1_btn_l2 ), .p1_r2     ( p1_btn_r2 ),
                .p1_l3     ( p1_btn_l3 ), .p1_r3     ( p1_btn_r3 ),
                .p1_se     ( p1_select ), .p1_st     ( p1_start  ),
                .j1_up     ( j1_up     ), .j1_down   ( j1_down   ),
                .j1_left   ( j1_left   ), .j1_right  ( j1_right  ),
                .j1_lx     ( j1_lx     ), .j1_ly     ( j1_ly     ),
                .j1_rx     ( j1_rx     ), .j1_ry     ( j1_ry     ),
                // .j1_up     ( {1'b0}), .j1_down   ( {1'b0}  ),
                // .j1_left   ( {1'b0}), .j1_right  ( {1'b0}  ),
                // .j1_lx     ( {1'b0}), .j1_ly     ( {1'b0}  ),
                // .j1_rx     ( {1'b0}), .j1_ry     ( {1'b0}  ),
                //Player 2
                .p2_up     ( p2_up     ), .p2_down   ( p2_down   ),
                .p2_left   ( p2_left   ), .p2_right  ( p2_right  ),
                .p2_y      ( p2_btn_y  ), .p2_x      ( p2_btn_x  ),
                .p2_b      ( p2_btn_b  ), .p2_a      ( p2_btn_a  ),
                .p2_l1     ( p2_btn_l1 ), .p2_r1     ( p2_btn_r1 ),
                .p2_l2     ( p2_btn_l2 ), .p2_r2     ( p2_btn_r2 ),
                .p2_l3     ( p2_btn_l3 ), .p2_r3     ( p2_btn_r3 ),
                .p2_se     ( p2_select ), .p2_st     ( p2_start  ),
                .j2_up     ( j2_up     ), .j2_down   ( j2_down   ),
                .j2_left   ( j2_left   ), .j2_right  ( j2_right  ),
                .j2_lx     ( j2_lx     ), .j2_ly     ( j2_ly     ),
                .j2_rx     ( j2_rx     ), .j2_ry     ( j2_ry     ),
                // .j2_up     ( {1'b0}), .j2_down   ( {1'b0}),
                // .j2_left   ( {1'b0}), .j2_right  ( {1'b0}),
                // .j2_lx     ( {1'b0}), .j2_ly     ( {1'b0}),
                // .j2_rx     ( {1'b0}), .j2_ry     ( {1'b0}),
                // Single Player or Alternate 2 Players for Arcade
                .m_coin    ( m_coin    ),                           // Coinage P1 or P2
                .m_up      ( m_up      ), .m_down    ( m_down    ), // Up/Down
                .m_left    ( m_left    ), .m_right   ( m_right   ), // Left/Right
                .m_btn1    ( m_btn1    ), .m_btn4    ( m_btn4    ), // Y/X
                .m_btn2    ( m_btn2    ), .m_btn3    ( m_btn3    ), // B/A
                .m_btn5    ( m_btn5    ), .m_btn6    ( m_btn6    ), // L1/R1
                .m_btn7    ( m_btn7    ), .m_btn8    ( m_btn8    ), // L2/R2
                .m_coin1   ( m_coin1   ), .m_coin2   ( m_coin2   ), // P1/P2 Coin
                .m_start1  ( m_start1  ), .m_start2  ( m_start2  )  // P1/P2 Start
            );

    //! ------------------------------------------------------------------------
    //! HiScore NVRAM/SRAM Save I/O
    //! ------------------------------------------------------------------------
    wire [HS_AW-1:0] hs_address;
    wire       [7:0] hs_data_out;
    wire       [7:0] hs_data_in;
    wire             hs_write_en;

    hiscore_io #(
                   // HiScore NVRAM
                   .HS_AW       ( HS_AW       ),
                   .HS_SW       ( HS_SW       ),
                   .HS_CFG_AW   ( HS_CFG_AW   ),
                   .HS_CFG_LW   ( HS_CFG_LW   ),
                   .HS_CONFIG   ( HS_CONFIG   ),
                   .HS_DATA     ( HS_DATA     ),
                   // MPU <-> FPGA (Data I/O)
                   .HS_MASK     ( HS_MASK     ),
                   .HS_WR_DELAY ( HS_WR_DELAY ),
                   .HS_WR_HOLD  ( HS_WR_HOLD  ),
                   .HS_RD_DELAY ( HS_RD_DELAY )
               ) pocket_hiscore_io (
                   .clk_74a                  ( clk_74a                  ), // [i]
                   .clk_memory               ( clk_sys                  ), // [i]
                   .pll_core_locked          ( pll_core_locked_s        ), // [i]
                   .reset_sw                 ( reset_sw                 ), // [i]
                   .pause_core               ( pause_core               ), // [i]
                   // Bridge Data Slots
                   .dataslot_requestwrite    ( dataslot_requestwrite    ), // [i]
                   .dataslot_requestwrite_id ( dataslot_requestwrite_id ), // [i]
                   .dataslot_requestread     ( dataslot_requestread     ), // [i]
                   .dataslot_requestread_id  ( dataslot_requestread_id  ), // [i]
                   .dataslot_allcomplete     ( dataslot_allcomplete     ), // [i]
                   // Bridge Write/Read to/From FPGA)
                   .bridge_endian_little     ( bridge_endian_little     ), // [i]
                   .bridge_addr              ( bridge_addr              ), // [i]
                   .bridge_wr                ( bridge_wr                ), // [i]
                   .bridge_wr_data           ( bridge_wr_data           ), // [i]
                   .bridge_rd                ( bridge_rd                ), // [i]
                   .bridge_rd_data           ( nvm_bridge_rd_data       ), // [o]
                   // Pocket Bridge Data Tables
                   .datatable_addr           ( datatable_addr           ), // [o]
                   .datatable_wren           ( datatable_wren           ), // [o]
                   .datatable_data           ( datatable_data           ), // [o]
                   // HiScore NVRAM Size
                   .nvram_size               ( HS_NVM_SZ                ), // [o] Address in game RAM to read/write score data
                   // HiScore Interface
                   .hs_address               ( hs_address               ), // [o] Address in game RAM to read/write score data
                   .hs_data_out              ( hs_data_out              ), // [i] Incoming data from game RAM
                   .hs_data_in               ( hs_data_in               ), // [o] Data to send to game RAM
                   .hs_write_en              ( hs_write_en              ), // [o] Write to game RAM (active high)
                   .hs_pause                 ( pause_req                )  // [o] Pause core CPU to prepare for/relax after RAM access
               );

    //! ------------------------------------------------------------------------
    //! Clocks
    //! ------------------------------------------------------------------------
    wire pll_core_locked, pll_core_locked_s;
    wire clk_sys;       //! Core : 53.600Mhz
    wire clk_vid;       //! Video:  6.700Mhz
    wire clk_vid_90deg; //! Video:  6.700Mhz @ 90deg Phase Shift

    core_pll core_pll
             (
                 .refclk   ( clk_74a         ),
                 .rst      ( 0               ),

                 .outclk_0 ( clk_sys         ),
                 .outclk_1 ( clk_vid         ),
                 .outclk_2 ( clk_vid_90deg   ),

                 .locked   ( pll_core_locked )
             );

    // Synchronize pll_core_locked into clk_74a domain before usage
    synch_3 sync_lck(pll_core_locked, pll_core_locked_s, clk_74a);

    //! ------------------------------------------------------------------------
    //! @ IP Core RTL
    //! ------------------------------------------------------------------------
    wire  [3:0] R,G,B;

    // wire [15:0] PLAYER1 = ~{2'b00, m_up, m_down, m_right, m_left , svc_sw, 4'b0000, m_btn3, m_btn2, m_btn1, m_start1, m_coin};
    // wire [15:0] PLAYER2 = ~{2'b00, m_up, m_down, m_right, m_left , svc_sw, 4'b0000, m_btn3, m_btn2, m_btn1, m_start2, m_coin};
    wire [15:0] PLAYER1 = ~{2'b00, p1_up, p1_down, p1_right, p1_left , svc_sw, 4'b0000, p1_btn_a, p1_btn_b, p1_btn_y, p1_start, p1_select};
    wire [15:0] PLAYER2 = ~{2'b00, p2_up, p2_down, p2_right, p2_left , svc_sw, 4'b0000, p2_btn_a, p2_btn_b, p2_btn_y, p2_start, p2_select};

    //To enter service mode:  
    //tnk3: keep 1 pressed during boot
    //athena: keep 1 pressed during boot
    //ikari: keep 1 pressed during boot1985 aso: keep 1 pressed during boot
    SNK_TripleZ80 snk_TZ80_ASO
                  (
                      .i_clk         ( clk_sys            ), //53.6MHz
                      .RESETn        ( ~reset_sw          ),
                      // Control
                      .VIDEO_RSTn    ( ~reset_sw          ),
                      .pause_cpu     ( pause_core         ),
                      .DSW           ( {dip_sw1, dip_sw0} ),
                      //.DSW           ( ~{dip_sw1, dip_sw0} ),
                      .PLAYER1       ( PLAYER1            ),
                      .PLAYER2       ( PLAYER2            ),
                      .GAME          ( mod_sw0            ), //default ASO (ASO,Alpha Mission, Arian Mission)
                      // Rom interface
                      .ioctl_addr    ( ioctl_addr[24:0]   ),
                      .ioctl_wr      ( ioctl_wr           ),
                      .ioctl_data    ( ioctl_data         ),
                      .layer_ena_dbg ( layer_ena_dbg      ),
                      // Output
                      .R             ( R                  ),
                      .G             ( G                  ),
                      .B             ( B                  ),
                      .HBLANK        ( core_hb            ),
                      .VBLANK        ( core_vb            ),
                      .HSYNC         ( core_hs            ),
                      .VSYNC         ( core_vs            ),
                      .CE_PIXEL      (                    ),
                      .snd           ( core_snd_l         )
                  );

    //color LUT for 4bit component to 8bit non-linear scale conversion (from LT Spice calculated values)
    logic [7:0] R8B, G8B, B8B;

    RGB4bit_LUT R_LUT(.COL_4BIT(R), .COL_8BIT(core_r));
    RGB4bit_LUT G_LUT(.COL_4BIT(G), .COL_8BIT(core_g));
    RGB4bit_LUT B_LUT(.COL_4BIT(B), .COL_8BIT(core_b));

    //Debug enable/disable Graphics layers
    reg   [2:0] layer_ena_dbg = 3'b111;

    always @(posedge clk_sys) begin
        // layer_ena_dbg[0] <= ~status[16]; //SIDE
        // layer_ena_dbg[1] <= ~status[17]; //BACK1
        // layer_ena_dbg[2] <= ~status[18]; //FRONT
        layer_ena_dbg[0] <= mod_sw0[0]; //SIDE
        layer_ena_dbg[1] <= mod_sw0[1]; //BACK1
        layer_ena_dbg[2] <= mod_sw0[2]; //FRONT
    end

endmodule
