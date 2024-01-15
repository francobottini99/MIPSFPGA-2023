`ifndef __PC_VH__
`define __PC_VH__
    `include "common.vh"
    
    `define DEFAULT_PC_SIZE `ARQUITECTURE_BITS

    `define NUMBER_OF_STATE_PC        3
    `define BITS_FOR_STATE_COUNTER_PC $clog2(`NUMBER_OF_STATE_PC)

    `define STATE_PC_IDLE        2'b00
    `define STATE_PC_NEXT        2'b01
    `define STATE_PC_PROGRAM_END 2'b10

`endif // __PC_VH__