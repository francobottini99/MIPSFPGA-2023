`timescale 1ns / 1ps

`include "tb.vh"

module tb_wb;

    localparam IO_BUS_SIZE   = 32;

    reg                                           i_mem_to_reg;
    reg  [IO_BUS_SIZE - 1 : 0]                    i_alu_result;
    reg  [IO_BUS_SIZE - 1 : 0]                    i_mem_result;
    wire [IO_BUS_SIZE - 1 : 0]                    o_wb_data;

    wb
    #(
        .IO_BUS_SIZE   (IO_BUS_SIZE)
    )
    dut
    (
        .i_mem_to_reg (i_mem_to_reg),
        .i_alu_result (i_alu_result),
        .i_mem_result (i_mem_result),
        .o_wb_data    (o_wb_data)
    );

    initial
    begin
        $srandom(95516515);

        i_alu_result = $urandom;
        i_mem_result = $urandom;
        i_mem_to_reg = 0;
        #10;
        if (o_wb_data !== i_mem_result)
            $display("ERROR: o_wb_data = %d, i_mem_result = %d", o_wb_data, i_mem_result);
        else
            $display("OK: o_wb_data = %d, i_mem_result = %d", o_wb_data, i_mem_result);

        i_mem_to_reg = 1;
        #10;
        if (o_wb_data !== i_alu_result)
            $display("ERROR: o_wb_data = %d, i_alu_result = %d", o_wb_data, i_alu_result);
        else
            $display("OK: o_wb_data = %d, i_alu_result = %d", o_wb_data, i_alu_result);

        $finish;
    end

endmodule