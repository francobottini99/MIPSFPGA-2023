`timescale 1ns / 1ps

`include "uart_reader.vh"

module uart_reader
    #(
        parameter UART_BUS_SIZE = `DEFAULT_UART_READER_BUS_SIZE,
        parameter OUT_BUS_SIZE  = `DEFAULT_UART_READER_OUT_BUS_SIZE
    )
    (
        input  wire                         i_clk,
        input  wire                         i_reset,
        input  wire                         i_uart_empty,
        input  wire                         i_start_rd,
        input  wire [UART_BUS_SIZE - 1 : 0] i_uart_data_rd,
        output wire                         o_uart_rd,
        output wire                         o_rd_end,
        output wire [OUT_BUS_SIZE - 1 : 0]  o_rd_data
    );

    localparam UART_RD_BUFFER_POINTER_SIZE = $clog2(OUT_BUS_SIZE / UART_BUS_SIZE);

    reg [1 : 0]                           state, state_next;
    reg                                   uart_rd, uart_rd_next;
    reg [OUT_BUS_SIZE - 1 : 0]            uart_rd_buffer, uart_rd_buffer_next;
    reg [UART_RD_BUFFER_POINTER_SIZE : 0] uart_rd_buffer_pointer, uart_rd_buffer_pointer_next;
    reg                                   rd_end, rd_end_next;

    always @(posedge i_clk) 
    begin
        if (i_reset)
            begin
                state                  <= `UART_READER_STATE_IDLE;
                uart_rd_buffer         <= `CLEAR(OUT_BUS_SIZE);
                uart_rd_buffer_pointer <= `CLEAR(UART_RD_BUFFER_POINTER_SIZE);
                uart_rd                <= `LOW;
                rd_end                 <= `LOW;
            end
        else
            begin
                state                  <= state_next;
                uart_rd_buffer         <= uart_rd_buffer_next;
                uart_rd_buffer_pointer <= uart_rd_buffer_pointer_next;
                uart_rd                <= uart_rd_next;
                rd_end                 <= rd_end_next;
            end
    end
    
    always @(*)
    begin
        state_next                  = state;
        uart_rd_buffer_next         = uart_rd_buffer;
        uart_rd_buffer_pointer_next = uart_rd_buffer_pointer;
        uart_rd_next                = uart_rd;
        rd_end_next                 = rd_end;

        case (state)

            `UART_READER_STATE_IDLE:
            begin
                if (i_start_rd)
                    begin
                        state_next  = `UART_READER_STATE_RD_IDLE;
                        rd_end_next = `LOW;
                    end
            end

            `UART_READER_STATE_RD_IDLE:
            begin
                if (uart_rd_buffer_pointer < OUT_BUS_SIZE / UART_BUS_SIZE)
                    begin
                        if (!i_uart_empty)
                            begin
                                uart_rd_buffer_next[uart_rd_buffer_pointer * UART_BUS_SIZE +: UART_BUS_SIZE] = i_uart_data_rd;
                                uart_rd_next                                                                 = `HIGH;
                                state_next                                                                   = `UART_READER_STATE_RD;
                            end
                    end
                else
                    begin
                        rd_end_next                 = `HIGH;
                        uart_rd_buffer_pointer_next = `CLEAR(UART_RD_BUFFER_POINTER_SIZE);
                        state_next                  = `UART_READER_STATE_IDLE;
                    end
            end

            `UART_READER_STATE_RD:
            begin
                state_next                  = `UART_READER_STATE_RD_IDLE;
                uart_rd_next                = `LOW;
                uart_rd_buffer_pointer_next = uart_rd_buffer_pointer + 1;
            end

        endcase
    end

    assign o_uart_rd = uart_rd;
    assign o_rd_end  = rd_end;
    assign o_rd_data = uart_rd_buffer;

endmodule