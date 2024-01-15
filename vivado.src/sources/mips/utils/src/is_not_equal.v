`timescale 1ns / 1ps

`include "is_not_equal.vh"

module is_not_equal
    #(
        parameter BUS_SIZE = `DEFAULT_IS_NOT_EQUAL_BUS_SIZE
    )
    (
        input  wire [BUS_SIZE - 1 : 0] in_a,
        input  wire [BUS_SIZE - 1 : 0] in_b,
        output wire                    is_not_equal
    );

    assign is_not_equal = in_a != in_b;

endmodule