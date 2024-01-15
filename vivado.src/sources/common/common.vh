`ifndef __COMMON_VH__
`define __COMMON_VH__
    `define ARQUITECTURE_BITS 32
    
    `define BYTE_SIZE 8    

    `define HIGH  1'b1
    `define LOW   1'b0
    `define UNDEF 1'bx

    `define CLEAR(len) { len {`LOW} }
    `define SET  (len) { len {`HIGH} }

    `define INSTRUCTION_HALT { `ARQUITECTURE_BITS {`HIGH} }
    `define INSTRUCTION_NOP  { `ARQUITECTURE_BITS {`LOW} }
`endif // __COMMON_VH__