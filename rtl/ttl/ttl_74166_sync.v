//ttl_74166_sync.v
// Parallel load 8-Bit Shift Register
// Implemented schematic from SN74LS166 TI datasheet
// @RndMnkIII 15/03/2022
//      Typ.
// tPHL 23ns (from clear)
// tPHL 20ns (from clock)
// tPLH 17ns (from clock)
//`include "helper.v"
`default_nettype none
`timescale 1ns/1ns

module ttl_74166_sync
(
  input wire Reset_n,
  input wire CLRn,
  input wire CLK,
  input wire CEN,
  input wire INH,
  input wire SH_LDn,
  input wire SER,
  input wire [7:0] D,
  output wire Q
);

    wire CLR;
    wire SH_LD;
    wire SH_LDnn;
    wire CLKn;

    assign CLR = ~CLRn;
    assign SH_LD = ~SH_LDn;
    assign SH_LDnn = ~SH_LD;
    assign CLKn = ~(~(CLK | INH));

    wire [7:0] andSER;
    wire [7:0] andSH_LD;
    wire [7:0] norSER_SHLD;
    wire [7:0] not_norSER_SHLD;
    wire  [7:0] SR_Q;

    assign andSER[0]   = SER  & SH_LDnn;
    assign andSH_LD[0] = D[0] & SH_LD;
    assign norSER_SHLD[0] = ~(andSER[0] | andSH_LD[0]);
    assign not_norSER_SHLD[0] = ~norSER_SHLD[0];
    srff u_init (.s(not_norSER_SHLD[0]),.r(norSER_SHLD[0]),.clk(CLKn),.rst(CLR), .q(SR_Q[0]));
    
    genvar i;
    generate
        for (i=1; i <= 7; i=i+1) 
        begin : ls166_sync_gen
            assign andSER[i]   = SR_Q[i-1] & SH_LDnn;
            assign andSH_LD[i] =    D[i]   & SH_LD;
            assign norSER_SHLD[i] = ~(andSER[i] | andSH_LD[i]);
            assign not_norSER_SHLD[i] = ~norSER_SHLD[i];
            SR_FlipFlop u0 (.s(not_norSER_SHLD[i]), .r(norSER_SHLD[i]), .Reset_n(Reset_n), .clk(CLK), .cen(CLKn),.rst(CLR), .q(SR_Q[i]));
        end
    endgenerate

    assign Q = SR_Q[7];
endmodule

//SR Flip Flop with async reset
module SR_FlipFlop(s,r,Reset_n,clk,cen,rst, q,qb);
    input wire s,r,Reset_n,clk,cen,rst;
    output wire q,qb;

    reg q_r;
    reg [1:0]sr;
    reg last_cen;

    always@(posedge clk) begin
        if(!Reset_n) begin
            q_r=1'b0;
            last_cen<= 1'b1;
        end
        else begin
            last_cen <= cen;
            sr={s,r};
            if(!rst) begin
                q_r<=1'b0;
            end 
            else begin
                if (cen && !last_cen) begin
                    case (sr)
                        2'd1:q_r<=1'b0;
                        2'd2:q_r<=1'b1;
                        2'd3:q_r<=1'b1;
                        default: q_r<=1'bx;
                    endcase
                end
            end
        end
    end

    assign q = q_r;
    assign qb = ~q_r;
endmodule