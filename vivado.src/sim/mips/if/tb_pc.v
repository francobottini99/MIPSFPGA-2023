`timescale 1ns / 1ps

`include "tb.vh"

module tb_pc;

    reg                               i_clk;
    reg                               i_reset;
    reg                               i_flush;
    reg                               i_clear;
    reg                               i_halt;
    reg                               i_not_load;
    reg                               i_enable;
    reg  [`ARQUITECTURE_BITS - 1 : 0] i_next_pc;
    wire [`ARQUITECTURE_BITS - 1 : 0] o_pc;

    pc 
    #(
        .PC_SIZE(`ARQUITECTURE_BITS)
    ) 
    dut 
    (
        .i_clk      (i_clk),
        .i_reset    (i_reset),
        .i_flush    (i_flush),
        .i_clear    (i_clear),
        .i_halt     (i_halt),
        .i_not_load (i_not_load),
        .i_enable   (i_enable),
        .i_next_pc  (i_next_pc),
        .o_pc       (o_pc)
    );

    `CLK_TOGGLE(i_clk, `CLK_PERIOD)

    initial begin
        $srandom(383715157);

        i_reset = 1;
        i_halt = 0;
        i_not_load = 0;
        i_next_pc = 0;
        i_flush = 0;
        i_clear = 0;

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_reset = 0;
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_enable = 1;
        
        repeat(10)
        begin
            `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_next_pc = i_next_pc + 1;
        end
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD);
        if (o_pc != 10) $display("ERROR TEST 1"); else $display("PASS TEST 1");
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_enable = 0;

        repeat(10)
        begin
            `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_next_pc = i_next_pc + 1;
        end
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD);
        if (o_pc != 10) $display("ERROR TEST 2"); else $display("PASS TEST 2");
             
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_halt = 1;
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_enable = 1;

        repeat(5)
        begin
            `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_next_pc = i_next_pc + 1;
        end
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD);
        if (o_pc != 10) $display("ERROR TEST 3"); else $display("PASS TEST 3");
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_halt = 0;
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_flush = 1;
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_flush = 0;
        
        repeat(10)
        begin
            `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_next_pc = i_next_pc + 1;
        end
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD);
        if (o_pc != 35) $display("ERROR TEST 4"); else $display("PASS TEST 4");
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_not_load = 1;
        
        repeat(5)
        begin
            `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_next_pc = i_next_pc + 1;
        end
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD);
        if (o_pc != 35) $display("ERROR TEST 5"); else $display("PASS TEST 5");
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_not_load = 0;
        
        repeat(5)
        begin
            `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_next_pc = i_next_pc + 1;
        end
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD);
        if (o_pc != 45) $display("ERROR TEST 6"); else $display("PASS TEST 6");
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_halt = 1;
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD);

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD);
        if (o_pc != 45) $display("ERROR TEST 7"); else $display("PASS TEST 7");
        
        $finish;
    end

endmodule
