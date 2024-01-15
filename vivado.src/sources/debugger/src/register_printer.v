`timescale 1ns / 1ps

`include "register_printer.vh"

module register_printer
    #(
        parameter UART_BUS_SIZE          = `DEFAULT_REGISTER_PRINTER_UART_BUS_SIZE,
        parameter DATA_OUT_BUS_SIZE      = `DEFAULT_REGISTER_PRINTER_OUT_BUS_SIZE,
        parameter REGISTER_SIZE          = `DEFAULT_REGISTER_PRINTER_REGISTER_SIZE,
        parameter REGISTER_BANK_BUS_SIZE = `DEFAULT_REGISTER_PRINTER_REGISTER_BANK_BUS_SIZE
    )
    (
        input  wire                                  i_clk,
        input  wire                                  i_reset,
        input  wire                                  i_wr_end,
        input  wire                                  i_start,  
        input  wire [REGISTER_BANK_BUS_SIZE - 1 : 0] i_registers_conntent,
        input  wire [UART_BUS_SIZE - 1 : 0]          i_clk_cicle,
        output wire                                  o_start_wr,
        output wire                                  o_end,
        output wire [DATA_OUT_BUS_SIZE - 1 : 0]      o_data_wr
    );

    localparam REGISTER_POINTER_SIZE = $clog2(REGISTER_BANK_BUS_SIZE / REGISTER_SIZE);

    reg [1 : 0]                     state, state_next;
    reg                             start_wr, start_wr_next;
    reg [DATA_OUT_BUS_SIZE - 1 : 0] data_wr, data_wr_next;
    reg [REGISTER_POINTER_SIZE : 0] register_pointer, register_pointer_next;
    reg                             _end, end_next;

    always @(posedge i_clk) 
    begin
        if (i_reset)
            begin
                state            <= `REGISTER_PRINTER_STATE_IDLE;
                register_pointer <= `CLEAR(REGISTER_POINTER_SIZE);
                data_wr          <= `CLEAR(DATA_OUT_BUS_SIZE);
                start_wr         <= `LOW;
                _end             <= `LOW;
            end
        else
            begin
                state            <= state_next;
                register_pointer <= register_pointer_next;
                data_wr          <= data_wr_next;
                start_wr         <= start_wr_next;
                _end             <= end_next;
            end
    end
    
    always @(*)
    begin
        state_next            = state;
        register_pointer_next = register_pointer;
        data_wr_next          = data_wr;
        start_wr_next         = start_wr;
        end_next              = _end;

        case (state)
    
            `REGISTER_PRINTER_STATE_IDLE:
            begin          
                if (i_start)
                    begin
                        end_next   = `LOW;
                        state_next = `REGISTER_PRINTER_STATE_PRINT;
                    end
            end

            `REGISTER_PRINTER_STATE_PRINT:
            begin
                if (register_pointer < REGISTER_BANK_BUS_SIZE / REGISTER_SIZE)
                    begin
                        data_wr_next          = {`DEBUGGER_REG_PREFIX, i_clk_cicle, { { (UART_BUS_SIZE - REGISTER_POINTER_SIZE - 1) { 1'b0 } }, register_pointer } , i_registers_conntent[register_pointer * REGISTER_SIZE +: REGISTER_SIZE] };
                        register_pointer_next = register_pointer + 1;
                        start_wr_next         = `HIGH;
                        state_next            = `REGISTER_PRINTER_STATE_WAIT_WR_TRANSITION;
                    end
                else
                    begin
                        end_next              = `HIGH;
                        register_pointer_next = `CLEAR(REGISTER_POINTER_SIZE);
                        state_next            = `REGISTER_PRINTER_STATE_IDLE;
                    end
            end

            `REGISTER_PRINTER_STATE_WAIT_WR_TRANSITION:
            begin
                state_next = `REGISTER_PRINTER_STATE_WAIT_WR;
            end

            `REGISTER_PRINTER_STATE_WAIT_WR:
            begin
                start_wr_next = `LOW;

                if (i_wr_end)
                    state_next = `REGISTER_PRINTER_STATE_PRINT;
            end

        endcase
    end

    assign o_start_wr            = start_wr;
    assign o_data_wr             = data_wr;
    assign o_end                 = _end;

endmodule