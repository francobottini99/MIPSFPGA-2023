`timescale 1ns / 1ps

`include "mux.vh"

module mux
    #(
        parameter CHANNELS = `DEFAULT_MUX_CHANNELS,
        parameter BUS_SIZE = `DEFAULT_MUX_BUS_SIZE
    )
    (
        input  wire [$clog2(CHANNELS) - 1 : 0]    selector,
        input  wire [CHANNELS * BUS_SIZE - 1 : 0] data_in,
        output wire [BUS_SIZE - 1 : 0]            data_out 
    );

    assign data_out = selector !== { $clog2(CHANNELS) {1'bx} } ? data_in >> BUS_SIZE * selector : { BUS_SIZE {1'bz} };      

endmodule