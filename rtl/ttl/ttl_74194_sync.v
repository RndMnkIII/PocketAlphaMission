//ttl_74194_sync.v
//4-Bit Bidirectional Universal Shift Register (Synchronous Version)
`default_nettype none
`timescale 1ns/1ps

module ttl_74194_sync
(
    input wire CR_n,
    input wire Reset_n,
    input wire CP,
    //(*direct_enable*) input wire Cen,
    input wire Cen,
    input wire S0,S1,
    input wire Dsl,Dsr,
    input wire D0,D1,D2,D3,
    output wire Q0,Q1,Q2,Q3
);
 
	reg [0:3] q_reg=4'b0000;
    reg last_cen;
	wire [1:0] s_reg;

	assign s_reg={S1,S0};

	always @(posedge CP) begin 
        if(!Reset_n) begin
            q_reg<=4'b0000;
            last_cen <= 1'b1;
        end
        else begin
            last_cen <= Cen;

            if (!CR_n) begin
                q_reg<=4'b0000;
            end else begin
                if (Cen && !last_cen) begin
                    case (s_reg)
                        2'b00 :q_reg<=q_reg;
                        2'b01 :q_reg<={Dsr,q_reg[0:2]}; //Shift right
                        2'b10 :q_reg<={q_reg[1:3],Dsl}; //Shift left
                        2'b11 :q_reg<={D0,D1,D2,D3};
                        default:q_reg<=4'b0000;
                    endcase
                end
            end
        end
	end
	
	assign Q0=q_reg[0];
	assign Q1=q_reg[1];
	assign Q2=q_reg[2];
	assign Q3=q_reg[3];
endmodule