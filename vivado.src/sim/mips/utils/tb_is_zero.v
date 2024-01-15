`timescale 1ns / 1ps

`include "tb.vh"

module tb_is_zero;

    parameter BUS_SIZE = 32;

    reg  [BUS_SIZE - 1 : 0] in_data;
    wire                    is_zero_result;

    is_zero 
    #(
        .BUS_SIZE (BUS_SIZE)
    ) dut 
    (
        .in      (in_data),
        .is_zero (is_zero_result)
    );

    initial 
    begin
        in_data = { BUS_SIZE {`LOW} };
        #10;
        if (is_zero_result !== `HIGH)
            $display("TEST 1 ERROR.");
        else
            $display("TEST 1 PASS.");

        in_data = { { (BUS_SIZE - 1) {`LOW} }, `HIGH };
        #10;
        if (is_zero_result !== `LOW) 
            $display("TEST 2 ERROR.");
        else
            $display("TEST 2 PASS.");

        $finish;
    end

endmodule