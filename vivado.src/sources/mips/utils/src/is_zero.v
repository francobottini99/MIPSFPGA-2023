`timescale 1ns / 1ps

`include "is_zero.vh"

module is_zero
    #(
        parameter BUS_SIZE = `DEFAULT_IS_ZERO_BUS_SIZE
    )
    (
        input  wire [BUS_SIZE - 1 : 0] in,
        output wire                    is_zero
    );

    assign is_zero = in == `CLEAR(BUS_SIZE);

endmodule