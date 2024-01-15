`timescale 1ns / 1ps

`include "memory_printer.vh"

module memory_printer
    #(
        parameter UART_BUS_SIZE        = `DEFAULT_MEMORY_PRINTER_UART_BUS_SIZE,
        parameter DATA_OUT_BUS_SIZE    = `DEFAULT_MEMORY_PRINTER_OUT_BUS_SIZE,
        parameter MEMORY_SLOT_SIZE     = `DEFAULT_MEMORY_PRINTER_MEMORY_SLOT_SIZE,
        parameter MEMORY_DATA_BUS_SIZE = `DEFAULT_MEMORY_PRINTER_MEMORY_DATA_BUS_SIZE
    )
    (
        input  wire                                i_clk,
        input  wire                                i_reset,
        input  wire                                i_wr_end,
        input  wire                                i_start,  
        input  wire [MEMORY_DATA_BUS_SIZE - 1 : 0] i_memory_conntent,
        input  wire [UART_BUS_SIZE - 1 : 0]        i_clk_cicle,
        output wire                                o_start_wr,
        output wire                                o_end,
        output wire [DATA_OUT_BUS_SIZE - 1 : 0]    o_data_wr
    );

    localparam MEMORY_POINTER_SIZE = $clog2(MEMORY_DATA_BUS_SIZE / MEMORY_SLOT_SIZE);

    reg [1 : 0]                     state, state_next;
    reg                             start_wr, start_wr_next;
    reg [DATA_OUT_BUS_SIZE - 1 : 0] data_wr, data_wr_next;
    reg [MEMORY_POINTER_SIZE : 0]   memory_pointer, memory_pointer_next;
    reg                              _end, end_next;
    
    always @(posedge i_clk) 
    begin
        if (i_reset)
            begin
                state          <= `MEMORY_PRINTER_STATE_IDLE;
                memory_pointer <= `CLEAR(MEMORY_POINTER_SIZE);
                data_wr        <= `CLEAR(DATA_OUT_BUS_SIZE);
                start_wr       <= `LOW;
                _end           <= `LOW;
            end
        else
            begin
                state          <= state_next;
                memory_pointer <= memory_pointer_next;
                data_wr        <= data_wr_next;
                start_wr       <= start_wr_next;
                _end           <= end_next;
            end
    end
    
    always @(*)
    begin
        state_next          = state;
        memory_pointer_next = memory_pointer;
        data_wr_next        = data_wr;
        start_wr_next       = start_wr;
        end_next            = _end;
    
        case (state)
    
            `MEMORY_PRINTER_STATE_IDLE:
            begin          
                if (i_start) 
                    begin
                        state_next = `MEMORY_PRINTER_STATE_PRINT;
                        end_next = `LOW;
                    end
            end

            `MEMORY_PRINTER_STATE_PRINT:
            begin
                if (memory_pointer < MEMORY_DATA_BUS_SIZE / MEMORY_SLOT_SIZE)
                    begin
                        data_wr_next        = {`DEBUGGER_MEM_PREFIX, i_clk_cicle , { { (UART_BUS_SIZE - MEMORY_POINTER_SIZE - 1) { 1'b0 } }, memory_pointer }, i_memory_conntent[memory_pointer * MEMORY_SLOT_SIZE +: MEMORY_SLOT_SIZE] };
                        memory_pointer_next = memory_pointer + 1;
                        start_wr_next       = `HIGH;
                        state_next          = `MEMORY_PRINTER_STATE_WAIT_WR_TRANSITION;
                    end
                else
                    begin
                        end_next            = `HIGH;
                        memory_pointer_next = `CLEAR(MEMORY_POINTER_SIZE);
                        state_next          = `MEMORY_PRINTER_STATE_IDLE;
                    end
            end

            `MEMORY_PRINTER_STATE_WAIT_WR_TRANSITION:
            begin
                state_next = `MEMORY_PRINTER_STATE_WAIT_WR;
            end

            `MEMORY_PRINTER_STATE_WAIT_WR:
            begin
                start_wr_next = `LOW;

                if (i_wr_end)
                    state_next = `MEMORY_PRINTER_STATE_PRINT;
            end

        endcase
    end

    assign o_start_wr            = start_wr;
    assign o_data_wr             = data_wr;
    assign o_end                 = _end;

endmodule