`timescale 1ns / 1ps

`include "tb.vh"

module tb_instruction_memory;

    localparam PC_BUS_SIZE        = 32;
    localparam WORD_SIZE_IN_BYTES = 4;
    localparam MEM_SIZE_IN_WORDS  = 10;
    localparam POINTER_SIZE       = $clog2(MEM_SIZE_IN_WORDS * WORD_SIZE_IN_BYTES);

    reg                                            i_clk;
    reg                                            i_reset;
    reg                                            i_instruction_write;
    reg                                            i_clear;
    reg  [PC_BUS_SIZE - 1 : 0]                     i_pc;
    reg  [WORD_SIZE_IN_BYTES * `BYTE_SIZE - 1 : 0] i_instruction;
    wire [WORD_SIZE_IN_BYTES * `BYTE_SIZE - 1 : 0] o_instruction;

    instruction_memory 
    #(
        .WORD_SIZE_IN_BYTES (WORD_SIZE_IN_BYTES),
        .MEM_SIZE_IN_WORDS  (MEM_SIZE_IN_WORDS),
        .PC_BUS_SIZE        (PC_BUS_SIZE)
    ) 
    dut 
    (
        .i_clk               (i_clk),
        .i_reset             (i_reset),
        .i_instruction_write (i_instruction_write),
        .i_clear             (i_clear),
        .i_pc                (i_pc),
        .i_instruction       (i_instruction),
        .o_instruction       (o_instruction)
    );
    
    `CLK_TOGGLE(i_clk, `CLK_PERIOD)
    
    initial 
    begin
        $srandom(356815353);
        
        i_reset = 1;
        i_instruction_write = 0;
        i_pc = 0;
        i_clear = 0;

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_reset = 0;
        
        repeat(10)
        begin
                                                    i_instruction = $urandom;
            `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_instruction_write = 1;
            `TICKS_DELAY_1(`CLK_PERIOD)             i_instruction_write = 0;
                                                    $display("Write: %h", i_instruction);
        end
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_instruction = `INSTRUCTION_HALT;
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_instruction_write = 1;
        `TICKS_DELAY_1(`CLK_PERIOD)             i_instruction_write = 0;
        
        repeat(10)
        begin
            `TICKS_DELAY_1(`CLK_PERIOD)             $display("Read: %h", o_instruction);
            `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_pc = i_pc + 4;
        end

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_clear = 1;
        `TICKS_DELAY_1(`CLK_PERIOD)             i_clear = 0; i_pc = 0;
        
        $display("\nMEMORY CLEAR\n");
        
        repeat(10)
        begin
            `TICKS_DELAY_1(`CLK_PERIOD)             $display("Read: %h", o_instruction);
            `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_pc = i_pc + 4;
        end
        
        repeat(10)
        begin
                                                    i_instruction = $urandom;
            `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_instruction_write = 1;
            `TICKS_DELAY_1(`CLK_PERIOD)             i_instruction_write = 0;
                                                    $display("Write: %h", i_instruction);
        end
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_instruction = `INSTRUCTION_HALT;
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_instruction_write = 1;
        `TICKS_DELAY_1(`CLK_PERIOD)             i_instruction_write = 0; i_pc = 0;
        
        repeat(10)
        begin
            `TICKS_DELAY_1(`CLK_PERIOD)             $display("Read: %h", o_instruction);
            `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_pc = i_pc + 4;
        end

        $finish;
    end

endmodule
