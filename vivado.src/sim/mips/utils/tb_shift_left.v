`timescale 1ns / 1ps

`include "tb.vh"

module tb_shift_left;

    parameter BUS_SIZE   = 32;
    parameter SHIFT_LEFT = 2;

    reg  [BUS_SIZE - 1 : 0] in_data;
    wire [BUS_SIZE - 1 : 0] out_result;

    shift_left 
    #(
        .BUS_SIZE   (BUS_SIZE), 
        .SHIFT_LEFT (SHIFT_LEFT)
    ) 
    dut 
    (
        .in  (in_data),
        .out (out_result)
    );

    initial 
    begin
        in_data = 32'b11011011011011011011011011011011;
        #10;
        if (out_result !== 32'b01101101101101101101101101101100) 
            $display("TEST 1 ERROR.");
        else 
            $display("TEST 1 PASS.");

        in_data = 32'b00110011001100110011001100110011;
        #10;
        if (out_result !== 32'b11001100110011001100110011001100) 
            $display("TEST 2 ERROR.");
        else 
            $display("TEST 2 PASS.");

        in_data = 32'b11110000111100001111000011110000;
        #10;
        if (out_result !== 32'b11000011110000111100001111000000) 
            $display("TEST 3 ERROR.");
        else 
            $display("TEST 3 PASS.");

        $finish;
    end

endmodule