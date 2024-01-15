`timescale 1ns / 1ps

`include "tb.vh"

module tb_is_not_equal;

    parameter BUS_SIZE = 32;

    reg  [BUS_SIZE - 1 : 0] in_a;
    reg  [BUS_SIZE - 1 : 0] in_b;
    wire                    is_not_equal_result;

    is_not_equal 
    #(
        .BUS_SIZE (BUS_SIZE)
    ) 
    dut 
    (
        .in_a         (in_a),
        .in_b         (in_b),
        .is_not_equal (is_not_equal_result)
    );

    initial 
    begin
        in_a = { BUS_SIZE {`LOW} };
        in_b = { BUS_SIZE {`LOW} };
        #10;
        if (is_not_equal_result !== `LOW)
            $display("TEST 1 ERROR.");
        else
            $display("TEST 1 PASS.");

        in_a = { { (BUS_SIZE - 1) {`LOW} }, `HIGH };
        in_b = { BUS_SIZE {`LOW} };
        #10;
        if (is_not_equal_result !== `HIGH) 
            $display("TEST 2 ERROR.");
        else
            $display("TEST 2 PASS.");

        $finish;
    end

endmodule