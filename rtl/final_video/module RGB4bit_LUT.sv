//AlphaMissionCore.sv
//Author: @RndMnkIII
//Date: 04/02/2022

//LUT data calculated from LT Spice simulation recreating
//ASO schematics
//normalized and hex converted using the following python script:
// from matplotlib import pyplot as plt
// import numpy

// raw_values = numpy.array([4.948, 4.759, 4.486, 4.244, 3.902, 3.660, 3.388, 3.147, 2.586, 2.344, 2.072, 1.830, 1.488, 1.189, 0.922, 0.732])
// norm_values = []

// max_val = numpy.amax(raw_values)
// min_val = numpy.amin(raw_values)

// rango = max_val - min_val

// for valor in raw_values:
//     norm_val = (valor - min_val) / rango
//     norm_values.append(norm_val)

// byte_val = []

// for valor2 in norm_values:
//     print(hex(int(round(valor2 * 255.0))))
    
// plt.plot(norm_values)
// plt.show()
`default_nettype none
`timescale 1ns/1ns

module RGB4bit_LUT( 
    input wire   [3:0] COL_4BIT, 
    output logic [7:0] COL_8BIT
);
    reg [11:0] angle; 
    
    always_comb begin
    case (COL_4BIT) 
        4'h0: COL_8BIT = 8'h00;
        4'h1: COL_8BIT = 8'h0B;
        4'h2: COL_8BIT = 8'h1C;
        4'h3: COL_8BIT = 8'h2E;
        4'h4: COL_8BIT = 8'h42;
        4'h5: COL_8BIT = 8'h51;
        4'h6: COL_8BIT = 8'h62;
        4'h7: COL_8BIT = 8'h70;
        4'h8: COL_8BIT = 8'h92;
        4'h9: COL_8BIT = 8'hA1;
        4'hA: COL_8BIT = 8'hB1;
        4'hB: COL_8BIT = 8'hC0;
        4'hC: COL_8BIT = 8'hD4;
        4'hD: COL_8BIT = 8'hE3;
        4'hE: COL_8BIT = 8'hF4;
        4'hF: COL_8BIT = 8'hFF;
    endcase 
    end 
endmodule