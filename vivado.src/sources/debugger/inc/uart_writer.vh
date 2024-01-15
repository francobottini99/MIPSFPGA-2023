`ifndef __UART_WRITER_VH__
`define __UART_WRITER_VH__
    `include "common.vh"

    `define DEFAULT_UART_WRITER_BUS_SIZE    8
    `define DEFAULT_UART_WRITER_IN_BUS_SIZE `ARQUITECTURE_BITS

    `define UART_WRITER_STATE_IDLE    2'b00
    `define UART_WRITER_STATE_WR_IDLE 2'b01
    `define UART_WRITER_STATE_WR      2'b10

`endif // __UART_WRITER_VH__