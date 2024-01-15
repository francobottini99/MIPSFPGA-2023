`timescale 1ns / 1ps

`include "instruction_memory.vh"

module instruction_memory 
    #(
        parameter PC_BUS_SIZE        = `DEFAULT_INSTRUCTION_MEMORY_PC_SIZE,
        parameter WORD_SIZE_IN_BYTES = `DEFAULT_INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES,
        parameter MEM_SIZE_IN_WORDS  = `DEFAULT_INSTRUCTION_MEMORY_MEM_SIZE_IN_WORDS
    )
    (
        input  wire                                            i_clk,
        input  wire                                            i_reset,
        input  wire                                            i_clear,
        input  wire                                            i_instruction_write,
        input  wire [PC_BUS_SIZE - 1 : 0]                      i_pc,
        input  wire [WORD_SIZE_IN_BYTES * `BYTE_SIZE - 1 : 0]  i_instruction,
        output wire                                            o_full,
        output wire                                            o_empty,
        output wire [WORD_SIZE_IN_BYTES * `BYTE_SIZE - 1 : 0]  o_instruction
    );

    localparam WORD_SIZE_IN_BITS   = WORD_SIZE_IN_BYTES * `BYTE_SIZE;
    localparam MEM_SIZE_IN_BITS    = MEM_SIZE_IN_WORDS * WORD_SIZE_IN_BITS;
    localparam POINTER_SIZE        = $clog2(MEM_SIZE_IN_WORDS * WORD_SIZE_IN_BYTES);
    localparam MAX_POINTER_DIR     = MEM_SIZE_IN_WORDS * WORD_SIZE_IN_BYTES;

    reg [POINTER_SIZE - 1 : 0]     write_pointer;
    reg [MEM_SIZE_IN_BITS - 1 : 0] memory_buffer;

    always @(posedge i_clk) 
    begin
        if (i_reset || i_clear) 
            begin
                memory_buffer <= `CLEAR(MEM_SIZE_IN_BITS);
                write_pointer <= `CLEAR(POINTER_SIZE);
            end 
        else 
            begin
                if(i_instruction_write)
                    begin
                        memory_buffer[`BYTE_SIZE * write_pointer +: WORD_SIZE_IN_BITS] = i_instruction;
                        write_pointer                                                  = write_pointer + WORD_SIZE_IN_BYTES;
                    end
            end
    end

    assign o_instruction = memory_buffer[i_pc * `BYTE_SIZE +: WORD_SIZE_IN_BITS];
    assign o_full        = write_pointer == MAX_POINTER_DIR;
    assign o_empty       = write_pointer == `CLEAR(POINTER_SIZE);

endmodule
