`ifndef __ID_VH__
`define __ID_VH__
    `include "main_control.vh"
    `include "registers_bank.vh"
    `include "sig_extend.vh"
    `include "unsig_extend.vh"
    `include "pc.vh"

    `define DEFAULT_ID_BUS_SIZE         `ARQUITECTURE_BITS 
    `define DEFAULT_ID_INSTRUCTION_SIZE `ARQUITECTURE_BITS
`endif // __ID_VH__