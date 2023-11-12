//74LS166 Test Bench
`timescale 1ns/1ns

module ttl_74166_tb();
    reg clr;
    reg inh;
    reg sh_ldn;
    reg ser_in;
    reg [7:0] d_in;
    wire ser_out;
    integer i;

    //Clock
    reg clk = 0;
    always #50 clk = !clk;
  
    initial begin
        $dumpfile("dump.vcd"); $dumpvars(0,"ttl_74166_tb");
        inh = 1'b0;
        clr = 1'b1;
        ser_in = 1'b0;
        sh_ldn = 1'b1;
        d_in = 8'b00000000;

        
        //Clear
        #25;
        clr = 1'b0;
        #50;
        clr = 1'b1;

        //Serial in
        #50;
        ser_in = 1'b1;
        #125;
        ser_in = 1'b0;
        #50;
        //wait 7 clock cycles and check ser_out
        repeat (7) always @(posedge clk);

        //parallel load, check serial out
        #50;
        sh_ldn = 1'b0;
        d_in = 8'b10011010;

        //clock inhibition for 200ns
        #75;
        inh = 1'b1;
        #25;
        sh_ldn = 1'b1; //end of parallel load
        d_in = 8'b00000000;
        #175;
        inh = 1'b0;//end of clock inhibition
        #75;

        //wait serial out to finish
        repeat (10) always @(posedge clk);
        $finish;
    end
  
    ttl_74166 uut
        (
        .CLRn(clr),
        .CLK(clk),
        .INH(inh),
        .SH_LDn(sh_ldn),
        .SER(ser_in),
        .D(d_in),
        .Q(ser_out));
endmodule