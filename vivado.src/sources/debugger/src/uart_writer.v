`timescale 1ns / 1ps

`include "uart_writer.vh"

module uart_writer
    #(
        parameter UART_BUS_SIZE = `DEFAULT_UART_WRITER_BUS_SIZE,
        parameter IN_BUS_SIZE   = `DEFAULT_UART_WRITER_IN_BUS_SIZE
    )
    (
        input  wire                         i_clk,
        input  wire                         i_reset,
        input  wire                         i_uart_full,
        input  wire                         i_start_wr,
        input  wire [IN_BUS_SIZE - 1 : 0]   i_wr_data,
        output wire                         o_uart_wr,
        output wire                         o_wr_end,
        output wire [UART_BUS_SIZE - 1 : 0] o_uart_data_wr
    );

    localparam UART_WR_BUFFER_POINTER_SIZE = $clog2(IN_BUS_SIZE / UART_BUS_SIZE);

    reg [1 : 0]                           state, state_next;
    reg                                   uart_wr, uart_wr_next;
    reg [UART_BUS_SIZE - 1 : 0]           uart_data_wr, uart_data_wr_next;
    reg [UART_WR_BUFFER_POINTER_SIZE : 0] uart_wr_buffer_pointer, uart_wr_buffer_pointer_next;
    reg                                   wr_end, wr_end_next;
    
    always @(posedge i_clk) 
    begin
        if (i_reset)
            begin
                state                  <= `UART_WRITER_STATE_IDLE;
                uart_wr_buffer_pointer <= `CLEAR(UART_WR_BUFFER_POINTER_SIZE);
                uart_data_wr           <= `CLEAR(UART_BUS_SIZE);
                uart_wr                <= `LOW; 
                wr_end                 <= `LOW;
            end
        else
            begin
                state                  <= state_next;
                uart_wr_buffer_pointer <= uart_wr_buffer_pointer_next;
                uart_data_wr           <= uart_data_wr_next;
                uart_wr                <= uart_wr_next;
                wr_end                 <= wr_end_next;
            end
    end
    
    always @(*)
    begin
        state_next                  = state;
        uart_wr_buffer_pointer_next = uart_wr_buffer_pointer;
        uart_data_wr_next           = uart_data_wr;
        uart_wr_next                = uart_wr;
        wr_end_next                 = wr_end;
    
        case (state)
            `UART_WRITER_STATE_IDLE:
            begin
                if (i_start_wr)
                    begin
                        wr_end_next = `LOW;
                        state_next = `UART_WRITER_STATE_WR_IDLE;
                    end
            end

            `UART_WRITER_STATE_WR_IDLE:
            begin     
                if (uart_wr_buffer_pointer < IN_BUS_SIZE / UART_BUS_SIZE)
                    begin
                        if (!i_uart_full)
                            begin
                                uart_data_wr_next = i_wr_data[uart_wr_buffer_pointer * UART_BUS_SIZE +: UART_BUS_SIZE];
                                uart_wr_next      = `HIGH;
                                state_next        = `UART_WRITER_STATE_WR;
                            end
                    end
                else
                    begin
                        uart_wr_buffer_pointer_next = `CLEAR(UART_WR_BUFFER_POINTER_SIZE);
                        wr_end_next                 = `HIGH;
                        state_next                  = `UART_WRITER_STATE_IDLE;
                    end
            end

            `UART_WRITER_STATE_WR:
            begin
                state_next                  = `UART_WRITER_STATE_WR_IDLE;
                uart_wr_next                = `LOW;
                uart_wr_buffer_pointer_next = uart_wr_buffer_pointer + 1;
            end

        endcase
    end
    
    assign o_uart_wr      = uart_wr;
    assign o_uart_data_wr = uart_data_wr;
    assign o_wr_end       = wr_end;

endmodule