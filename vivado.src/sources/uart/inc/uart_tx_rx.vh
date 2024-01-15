`ifndef __UART__TX_RX_VH__
`define __UART__TX_RX_VH__
    `define DEFAULT_UART_DATA_BITS      8
    `define DEFAULT_UART_SB_TICKS       16
    
    `define UART_STATES_NUMBERS 4
    `define UART_STATE_IDLE     2'b00 
    `define UART_STATE_START    2'b01
    `define UART_STATE_DATA     2'b10
    `define UART_STATE_STOP     2'b11

    `define UART_STATE_REG_SIZE $clog2(`UART_STATES_NUMBERS)
    `define B_REG_SIZE     DATA_BITS
    `define N_REG_SIZE     $clog2(DATA_BITS)
    `define S_REG_SIZE     $clog2(SB_TICKS)
`endif // __UART__TX_RX_VH__