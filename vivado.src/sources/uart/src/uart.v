`timescale 1ns / 1ps

`include "uart.vh"

module uart
    #(
        parameter DATA_BITS = `DEFAULT_UART_DATA_BITS,
        parameter SB_TICKS  = `DEFAULT_UART_SB_TICKS,
        parameter DVSR_BIT  = `DEFAULT_UART_DVSR_BIT,
        parameter DVSR      = `DEFAULT_UART_DVSR,
        parameter FIFO_SIZE = `DEFAULT_UART_FIFO_SIZE
    )
    (
        input  wire                     clk,
        input  wire                     reset,
        input  wire                     rd_uart,
        input  wire                     wr_uart,
        input  wire                     rx,
        input  wire [DATA_BITS - 1 : 0] w_data,
        output wire                     tx_full,
        output wire                     rx_empty,
        output wire                     tx,
        output wire [DATA_BITS - 1 : 0] r_data
    );
    
    wire                     tick;
    wire                     rx_done_tick;
    wire                     tx_done_tick;
    wire                     tx_empty;
    wire                     tx_fifo_not_empty;
    wire [DATA_BITS - 1 : 0] tx_fifo_out;
    wire [DATA_BITS - 1 : 0] rx_data_out;
    
    uart_brg
    #(
      .BAUDRATE_PRECISION (DVSR_BIT),
      .BAUDRATE_PERIOD    (DVSR)
    )
    baud_gen_unit
    (
      .clk       (clk),
      .reset     (reset),
      .baud_tick (tick),
      .baud_rate ()
    );
    
    uart_rx
    #(
      .DATA_BITS (DATA_BITS),
      .SB_TICKS  (SB_TICKS)
    )
    uart_rx_unit
    (
      .clk          (clk),
      .reset        (reset),
      .rx           (rx),
      .s_tick       (tick),
      .rx_done_tick (rx_done_tick),
      .dout         (rx_data_out)
    );
    
    uart_tx
    #(
      .DATA_BITS (DATA_BITS),
      .SB_TICKS  (SB_TICKS)
    )
    uart_tx_unit
    (
      .clk          (clk),
      .reset        (reset),
      .tx_start     (tx_fifo_not_empty),
      .s_tick       (tick),
      .tx_done_tick (tx_done_tick),
      .tx           (tx),
      .din          (tx_fifo_out)
    );
 
    fifo
    #(
      .FIFO_SIZE  (FIFO_SIZE),
      .WORD_WIDTH (DATA_BITS)
    )
    fifo_rx_unit
    (
      .clk    (clk),
      .reset  (reset),
      .w_data (rx_data_out),
      .wr     (rx_done_tick),
      .rd     (rd_uart),
      .r_data (r_data),
      .full   (),
      .empty  (rx_empty)
    );
    
    fifo
    #(
      .FIFO_SIZE  (FIFO_SIZE),
      .WORD_WIDTH (DATA_BITS)
    )
    fifo_tx_unit
    (
      .clk    (clk),
      .reset  (reset),
      .w_data (w_data),
      .wr     (wr_uart),
      .rd     (tx_done_tick),
      .r_data (tx_fifo_out),
      .full   (tx_full),
      .empty  (tx_empty)
    );
    
    assign tx_fifo_not_empty = ~tx_empty;
    
endmodule
