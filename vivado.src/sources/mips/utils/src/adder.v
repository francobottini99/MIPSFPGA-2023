`timescale 1ns / 1ps

`include "adder.vh"
    
module adder
    #(
        parameter BUS_SIZE = `DEFAULT_ADDER_BUS_SIZE
    )
    (
        input  wire [BUS_SIZE - 1 : 0] a,
        input  wire [BUS_SIZE - 1 : 0] b,
        output wire [BUS_SIZE - 1 : 0] sum
    );
    
    assign sum = a + b;

endmodule
