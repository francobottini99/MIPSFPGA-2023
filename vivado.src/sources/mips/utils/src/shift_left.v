`timescale 1ns / 1ps

`include "shift_left.vh"

module shift_left
    #(
        parameter BUS_SIZE   = `DEFAULT_SHIFT_LEFT_BUS_SIZE,
        parameter SHIFT_LEFT = `DEFAULT_SHIFT_LEFT
    )
    (
        input  wire [BUS_SIZE - 1 : 0] in,
        output wire [BUS_SIZE - 1 : 0] out
    );

    assign out = in << SHIFT_LEFT;

endmodule