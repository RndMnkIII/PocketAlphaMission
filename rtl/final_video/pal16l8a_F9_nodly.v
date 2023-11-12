//pal16l8a_F9_nodly.v
//Author: @RndMnkIII
//Date: 15/03/2022
//Thanks to @caiusarcade for the ArianMission PLD dump.
//This PLD was simplified, cleaned and tested on real hardware (GAL16V8-25LP device)
`default_nettype none
`timescale 1ns/1ps

module pal16l8a_F9_nodly (
    //inputs
    input wire SLBD7, //2 I1
    input wire SLD7, //3 I2
    input wire SLD0, //4 I3
    input wire SLD1, //5 I4
    input wire SLD2, //6 I5
    input wire i7, //7 VCC I6
    input wire i8, //8 VCC I7
    input wire i9, //9 VCC I8
    input wire i11, //11 VCC I9
    input wire H1_SD30_r, //13 B1
    //outputs
    output wire COLBANK5, //12 B0
    output wire LAYER_SELA, //15 B3
    output wire LAYER_SELB, //16 B4
    output wire COLBANK3, //17 B5
    output wire COLBANK4 //18 B6
);
    // !COLBANK5 =>
    //     !H1_SD30_r & !SLD7 & !SLD0 & SLD1 & SLD2
    //   # !H1_SD30_r & !SLD0 & SLD1 & SLD2 & VCC & VCC & VCC
    //   # !H1_SD30_r & SLD1 & SLD2 & !VCC & VCC & VCC & VCC

    // !LAYER_SELA =>
    //     !H1_SD30_r & SLD1 & SLD2
    //   # !H1_SD30_r & SLD7 & !VCC
    //   # !H1_SD30_r & SLD7 & !VCC
    //   # !H1_SD30_r & SLD7 & !VCC

    // !LAYER_SELB =>
    //     !H1_SD30_r & SLD1 & SLD2 & VCC & VCC & VCC

    // !COLBANK3 =>
    //     !H1_SD30_r & !SLBD7
    //   # !H1_SD30_r & !SLD1
    //   # !H1_SD30_r & !SLD2
    //   # !H1_SD30_r & !VCC
    //   # !H1_SD30_r & !VCC
    //   # !H1_SD30_r & !VCC

    // !COLBANK4 =>
    //     !H1_SD30_r & SLBD7
    //   # !H1_SD30_r & !SLD1
    //   # !H1_SD30_r & !SLD2
    //   # !H1_SD30_r & !VCC
    //   # !H1_SD30_r & !VCC
    //   # !H1_SD30_r & !VCC

    wire H1_SD30_r_neg;
    wire SLBD7_neg;
    wire SLD7_neg;
    wire SLD0_neg;
    wire SLD1_neg;
    wire SLD2_neg;

    assign  H1_SD30_r_neg = ~H1_SD30_r;
    assign  SLBD7_neg     = ~SLBD7;
    assign  SLD7_neg      = ~SLD7;
    assign  SLD0_neg      = ~SLD0;
    assign  SLD1_neg      = ~SLD1;
    assign  SLD2_neg      = ~SLD2;

    //------------------------------------------------------
    // assign  COLBANK5   = ~((H1_SD30_r_neg & SLD7_neg & SLD0_neg & SLD1 & SLD2) | 
    //                                            (H1_SD30_r_neg &            SLD0_neg & SLD1 & SLD2) |
    //                                            (H1_SD30_r_neg &                       SLD1 & SLD2));
     assign  COLBANK5   = ~((H1_SD30_r_neg & SLD7_neg & SLD0_neg & SLD1 & SLD2) | 
                                               (H1_SD30_r_neg &             SLD0_neg & SLD1 & SLD2));                                              
    //------------------------------------------------------
    assign  LAYER_SELA = ~((H1_SD30_r_neg &                       SLD1 & SLD2));  
    //------------------------------------------------------
    assign  LAYER_SELB = ~((H1_SD30_r_neg &                       SLD1 & SLD2));
    //------------------------------------------------------
    assign  COLBANK3   = ~((H1_SD30_r_neg &  SLBD7_neg                         ) |
                                               (H1_SD30_r_neg &                         SLD1_neg   ) |
                                               (H1_SD30_r_neg &                         SLD2_neg   ));
    //------------------------------------------------------
    assign  COLBANK4   = ~((H1_SD30_r_neg &  SLBD7                             ) |
                                               (H1_SD30_r_neg &                         SLD1_neg   ) |
                                               (H1_SD30_r_neg &                         SLD2_neg   ));           
endmodule 