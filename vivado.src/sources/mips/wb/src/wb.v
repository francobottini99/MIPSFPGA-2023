`timescale 1ns / 1ps

`include "wb.vh"

module wb
    #(
        parameter IO_BUS_SIZE   = `DEFAULT_WB_IO_BUS_SIZE
    )
    (
        input  wire                       i_mem_to_reg,
        input  wire [IO_BUS_SIZE - 1 : 0] i_alu_result,
        input  wire [IO_BUS_SIZE - 1 : 0] i_mem_result,
        output wire [IO_BUS_SIZE - 1 : 0] o_wb_data
    );

    mux 
    #(
        .CHANNELS (2), 
        .BUS_SIZE (IO_BUS_SIZE)
    ) 
    mux_wb_data
    (
        .selector (i_mem_to_reg),
        .data_in  ({i_alu_result, i_mem_result}),
        .data_out (o_wb_data)
    );

endmodule