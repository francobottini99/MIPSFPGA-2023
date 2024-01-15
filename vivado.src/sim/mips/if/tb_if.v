`timescale 1ns / 1ps

`include "tb.vh"

module tb_if;

    localparam MEM_SIZE_IN_WORDS  = 40;
    localparam WORD_SIZE_IN_BYTES = 4;

    reg                               i_clk;
    reg                               i_reset;
    reg                               i_flush;
    reg                               i_halt;
    reg                               i_not_load;
    reg                               i_enable;
    reg                               i_next_pc_src;
    reg                               i_write_mem;
    reg                               i_clear_mem;
    reg  [`ARQUITECTURE_BITS - 1 : 0] i_instruction;
    reg  [`ARQUITECTURE_BITS - 1 : 0] i_next_not_seq_pc;
    reg  [`ARQUITECTURE_BITS - 1 : 0] i_next_seq_pc;
    wire                              o_full_mem;
    wire                              o_empty_mem;
    wire [`ARQUITECTURE_BITS - 1 : 0] o_instruction;
    wire [`ARQUITECTURE_BITS - 1 : 0] o_next_seq_pc;

    _if
    #(
        .PC_SIZE(`ARQUITECTURE_BITS),
        .WORD_SIZE_IN_BYTES(WORD_SIZE_IN_BYTES),
        .MEM_SIZE_IN_WORDS(MEM_SIZE_IN_WORDS)
    )
    dut
    (
        .i_clk             (i_clk),
        .i_reset           (i_reset),
        .i_halt            (i_halt),
        .i_not_load        (i_not_load),
        .i_enable          (i_enable),
        .i_next_pc_src     (i_next_pc_src),
        .i_write_mem       (i_write_mem),
        .i_instruction     (i_instruction),
        .i_next_not_seq_pc (i_next_not_seq_pc),
        .i_next_seq_pc     (i_next_seq_pc),
        .i_flush           (i_flush),
        .i_clear_mem       (i_clear_mem),
        .o_full_mem        (o_full_mem),
        .o_empty_mem       (o_empty_mem),
        .o_instruction     (o_instruction),
        .o_next_seq_pc     (o_next_seq_pc)
    );

    `CLK_TOGGLE(i_clk, `CLK_PERIOD)

    initial
    begin
        $srandom(9481596);

        i_reset = 1;
        i_halt = 0;
        i_not_load = 0;
        i_next_not_seq_pc = 0;
        i_next_seq_pc = 0;
        i_write_mem = 0;
        i_next_pc_src = 0;
        i_enable = 0;
        i_flush = 0;
        i_clear_mem = 0;
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_reset = 0;

        $display("\nTEST 0:");
        
        repeat(40)
        begin
                                        i_instruction = $urandom;
                                        i_write_mem = 1;
            `TICKS_DELAY_1(`CLK_PERIOD) i_write_mem = 0;
                                        $display("Write: %h", i_instruction);
        end
        
                                    i_instruction = { 32 { 1'b1 } };
                                    i_write_mem = 1;
        `TICKS_DELAY_1(`CLK_PERIOD) i_write_mem = 0;
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_enable = 1;

        $display("\nTEST 1:");

        repeat(10)
        begin
            `TICKS_DELAY_1(`CLK_PERIOD) $display("Read: %h", o_instruction); $display("PC: %h", o_next_seq_pc);
            i_next_seq_pc = i_next_seq_pc + 4;
        end

        $display("\nTEST 2:");
        
        `TICKS_DELAY_1(`CLK_PERIOD) i_enable = 0;

        repeat(5)
        begin
            `TICKS_DELAY_1(`CLK_PERIOD) $display("Read: %h", o_instruction); $display("PC: %h", o_next_seq_pc);
             i_next_seq_pc = i_next_seq_pc + 4;
        end

        $display("\nTEST 3:");

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_enable = 1;
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_halt = 1;
       
        repeat(5)
        begin
            `TICKS_DELAY_1(`CLK_PERIOD) $display("Read: %h", o_instruction); $display("PC: %h", o_next_seq_pc);
             i_next_seq_pc = i_next_seq_pc + 4;
        end

        $display("\nTEST 4:");
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_halt = 0;

        repeat(10)
        begin
            `TICKS_DELAY_1(`CLK_PERIOD) $display("Read: %h", o_instruction); $display("PC: %h", o_next_seq_pc);
             i_next_seq_pc = i_next_seq_pc + 4;
        end

        $display("\nTEST 5:");

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_not_load = 1;
        
        repeat(5)
        begin
            `TICKS_DELAY_1(`CLK_PERIOD) $display("Read: %h", o_instruction); $display("PC: %h", o_next_seq_pc);
             i_next_seq_pc = i_next_seq_pc + 4;
        end

        $display("\nTEST 6:");

        i_next_seq_pc = 0;

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_not_load = 0;
        
        repeat(10)
        begin
            `TICKS_DELAY_1(`CLK_PERIOD) $display("Read: %h", o_instruction); $display("PC: %h", o_next_seq_pc);
             i_next_seq_pc = i_next_seq_pc + 4;
        end
        
        $display("\nTEST 7:");
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_next_not_seq_pc = 20;
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_next_pc_src = 1;
        `TICKS_DELAY_1(`CLK_PERIOD)             i_next_pc_src = 0;
        
        repeat(5)
        begin
            `TICKS_DELAY_1(`CLK_PERIOD) $display("Read: %h", o_instruction); $display("PC: %h", o_next_seq_pc);
             i_next_seq_pc = i_next_seq_pc + 4;
        end

        $display("\nTEST 8:");
        
        i_next_seq_pc = 0;
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_clear_mem = 1;
        `TICKS_DELAY_1(`CLK_PERIOD)             i_clear_mem = 0;

        repeat(5)
        begin
            `TICKS_DELAY_1(`CLK_PERIOD) $display("Read: %h", o_instruction); $display("PC: %h", o_next_seq_pc);
             i_next_seq_pc = i_next_seq_pc + 4;
        end
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD)

        $finish;
    end

endmodule