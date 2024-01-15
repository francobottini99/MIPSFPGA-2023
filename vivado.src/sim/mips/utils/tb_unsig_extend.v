`timescale 1ns / 1ps

`include "tb.vh"

module tb_unsig_extend;

    localparam REG_IN_SIZE  = 16;
    localparam REG_OUT_SIZE = 32;

    reg  [REG_IN_SIZE - 1 : 0]  i_reg;
    wire [REG_OUT_SIZE - 1 : 0] o_reg;

    unsig_extend 
    #(
        .REG_IN_SIZE  (REG_IN_SIZE), 
        .REG_OUT_SIZE (REG_OUT_SIZE)
    ) 
    dut 
    (
        .i_reg (i_reg),
        .o_reg (o_reg)
    );

    initial 
    begin
        i_reg = 16'b0101010101010101;
        #10;
        if (o_reg !== 32'b00000000000000000101010101010101) 
            $display("TEST 1 ERROR.");
        else
            $display("TEST 1 PASS.");

        i_reg = 16'b1100101011111101;
        #10;
        if (o_reg !== 32'b100000000000000001100101011111101) 
            $display("TEST 2 ERROR.");
        else
            $display("TEST 2 PASS.");

        $finish;
    end

endmodule
