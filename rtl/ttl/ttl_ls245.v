//ttl_ls245.v
`default_nettype none
`timescale 1ns/1ns

module ttl_ls245(A, B, DIR, OEn);
inout wire [7:0] A;
inout wire [7:0] B;
input wire DIR;
input wire OEn;

    wire DIR_inv;
    wire OEn_inv;
    wire Abuf_en;
    wire Bbuf_en;
    wire [7:0] Abuf;
    wire [7:0] Bbuf;

    not notdir (DIR_inv, DIR);
    not notoen (OEn_inv, OEn);
    and and_a (Abuf_en, DIR, OEn_inv);
    and and_b (Bbuf_en, DIR_inv, OEn_inv);

    bufif1 #(25,27) bufA0 (Abuf[0], A[0], Abuf_en);
    bufif1 #(25,27) bufB0 (Bbuf[0], B[0], Bbuf_en);
    bufif1 #(25,27) bufA1 (Abuf[1], A[1], Abuf_en);
    bufif1 #(25,27) bufB1 (Bbuf[1], B[1], Bbuf_en);
    bufif1 #(25,27) bufA2 (Abuf[2], A[2], Abuf_en);
    bufif1 #(25,27) bufB2 (Bbuf[2], B[2], Bbuf_en);
    bufif1 #(25,27) bufA3 (Abuf[3], A[3], Abuf_en);
    bufif1 #(25,27) bufB3 (Bbuf[3], B[3], Bbuf_en);
    bufif1 #(25,27) bufA4 (Abuf[4], A[4], Abuf_en);
    bufif1 #(25,27) bufB4 (Bbuf[4], B[4], Bbuf_en);
    bufif1 #(25,27) bufA5 (Abuf[5], A[5], Abuf_en);
    bufif1 #(25,27) bufB5 (Bbuf[5], B[5], Bbuf_en);
    bufif1 #(25,27) bufA6 (Abuf[6], A[6], Abuf_en);
    bufif1 #(25,27) bufB6 (Bbuf[6], B[6], Bbuf_en);
    bufif1 #(25,27) bufA7 (Abuf[7], A[7], Abuf_en);
    bufif1 #(25,27) bufB7 (Bbuf[7], B[7], Bbuf_en);

    assign A[0] = Bbuf[0];
    assign B[0] = Abuf[0];
    assign A[1] = Bbuf[1];
    assign B[1] = Abuf[1];
    assign A[2] = Bbuf[2];
    assign B[2] = Abuf[2];
    assign A[3] = Bbuf[3];
    assign B[3] = Abuf[3];
    assign A[4] = Bbuf[4];
    assign B[4] = Abuf[4];
    assign A[5] = Bbuf[5];
    assign B[5] = Abuf[5];
    assign A[6] = Bbuf[6];
    assign B[6] = Abuf[6];
    assign A[7] = Bbuf[7];
    assign B[7] = Abuf[7];
endmodule