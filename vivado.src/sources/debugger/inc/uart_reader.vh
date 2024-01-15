`ifndef __UART_READER_VH__
`define __UART_READER_VH__
    `include "common.vh"

    `define DEFAULT_UART_READER_BUS_SIZE     8
    `define DEFAULT_UART_READER_OUT_BUS_SIZE `ARQUITECTURE_BITS

    `define UART_READER_STATE_IDLE    2'b00
    `define UART_READER_STATE_RD_IDLE 2'b01
    `define UART_READER_STATE_RD      2'b10

`endif // __UART_READER_VH__