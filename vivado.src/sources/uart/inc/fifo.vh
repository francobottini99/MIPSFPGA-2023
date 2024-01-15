`ifndef __FIFO_VH__
`define __FIFO_VH__
    `define DEFAULT_FIFO_SIZE         64
    `define DEFAULT_FIFO_WORD_WIDTH   8
    
    `define FIFO_STATE_READ           2'b01
    `define FIFO_STATE_WRITE          2'b10
    `define FIFO_STATE_READ_AND_WRITE 2'b11
`endif // __FIFO_VH__