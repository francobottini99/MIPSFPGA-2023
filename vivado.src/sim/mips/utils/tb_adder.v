`timescale 1ns / 1ps

`include "tb.vh"

module tb_adder;

    reg  [`ARQUITECTURE_BITS - 1 : 0] a;
    reg  [`ARQUITECTURE_BITS - 1 : 0] b;
    wire [`ARQUITECTURE_BITS - 1 : 0] sum;

    adder 
    #
    (
        .BUS_SIZE(`ARQUITECTURE_BITS)
    ) 
    dut 
    (
        .a(a),
        .b(b),
        .sum(sum)
    );

    initial 
    begin
        repeat (10) 
        begin
            $srandom(1658115);

            a = $random;
            b = $random;

            $display("Input: a = %h, b = %h", a, b);
            #10;
            
            if (sum !== a + b)
                $display("TEST ERROR: sum = %h, expected = %h", sum, a + b);
            else
                $display("TEST PASS: sum = %h", sum);
        end
        
        $finish;
    end

endmodule
