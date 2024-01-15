`timescale 1ns / 1ps

`include "debugger_control.vh"

module debugger_control
    #(
        parameter UART_BUS_SIZE          = `DEFAULT_DEBUGGER_CONTROL_UART_BUS_SIZE,
        parameter DATA_IN_BUS_SIZE       = `DEFAULT_DEBUGGER_CONTROL_IN_BUS_SIZE,
        parameter DATA_OUT_BUS_SIZE      = `DEFAULT_DEBUGGER_CONTROL_OUT_BUS_SIZE,
        parameter REGISTER_SIZE          = `DEFAULT_DEBUGGER_CONTROL_REGISTER_SIZE
    )
    (
        input  wire                             i_clk,
        input  wire                             i_reset,
        input  wire                             i_instruction_memory_empty,
        input  wire                             i_instruction_memory_full,
        input  wire                             i_mips_end_program,
        input  wire                             i_uart_rd_end,
        input  wire                             i_uart_wr_end,
        input  wire                             i_register_print_end,
        input  wire                             i_memory_print_end,
        input  wire [DATA_IN_BUS_SIZE - 1 : 0]  i_data_uart_rd,
        output wire [UART_BUS_SIZE - 1 : 0]     o_clk_cicle,
        output wire                             o_start_uart_wr,
        output wire                             o_start_uart_rd,
        output wire                             o_start_register_print,
        output wire                             o_start_memory_print,
        output wire                             o_mips_instruction_wr,
        output wire                             o_mips_flush,
        output wire                             o_mips_clear_program,
        output wire                             o_mips_enabled,
        output wire [DATA_OUT_BUS_SIZE - 1 : 0] o_data_wr,
        output wire [REGISTER_SIZE - 1 : 0]     o_mips_instruction,
        output wire [4 : 0]                     o_state
    );

    reg [4 : 0]                     state, state_next, return_state, return_state_next;
    reg                             mips_flush, mips_flush_next;
    reg                             mips_enabled, mips_enabled_next; 
    reg                             mips_clear_program, mips_clear_program_next;
    reg                             start_uart_rd, start_uart_rd_next;
    reg                             start_uart_wr, start_uart_wr_next;
    reg                             start_register_print, start_register_print_next;
    reg                             start_memory_print, start_memory_print_next;
    reg [DATA_OUT_BUS_SIZE - 1 : 0] data_wr, data_wr_next;
    reg                             mips_instruction_wr, mips_instruction_wr_next;
    reg [REGISTER_SIZE - 1 : 0]     mips_instruction, mips_instruction_next;
    reg                             execution_by_steps, execution_by_steps_next;
    reg                             execution_debug, execution_debug_next;
    reg [UART_BUS_SIZE - 1 : 0]     clk_counter, clk_counter_next;

    always @(posedge i_clk) 
    begin
        if (i_reset)
            begin
                state                  <= `DEBUGGER_CONTROL_STATE_IDLE;
                return_state           <= `DEBUGGER_CONTROL_STATE_IDLE;
                mips_flush             <= `LOW;
                mips_enabled           <= `LOW;
                mips_clear_program     <= `LOW;
                start_uart_rd          <= `LOW;
                start_uart_wr          <= `LOW;
                start_register_print   <= `LOW;
                start_memory_print     <= `LOW;
                mips_instruction_wr    <= `LOW;
                execution_by_steps     <= `LOW;
                execution_debug        <= `LOW;
                clk_counter            <= `CLEAR(UART_BUS_SIZE);
                mips_instruction       <= `CLEAR(REGISTER_SIZE);
                data_wr                <= `CLEAR(DATA_OUT_BUS_SIZE);
            end
        else
            begin
                state                  <= state_next;
                return_state           <= return_state_next;
                mips_flush             <= mips_flush_next;
                mips_enabled           <= mips_enabled_next;
                mips_clear_program     <= mips_clear_program_next;
                start_uart_rd          <= start_uart_rd_next;
                start_uart_wr          <= start_uart_wr_next;
                start_register_print   <= start_register_print_next;
                start_memory_print     <= start_memory_print_next;
                mips_instruction_wr    <= mips_instruction_wr_next;
                execution_by_steps     <= execution_by_steps_next;
                execution_debug        <= execution_debug_next;
                clk_counter            <= clk_counter_next;
                mips_instruction       <= mips_instruction_next;
                data_wr                <= data_wr_next;
            end
    end
    
    always @(*)
    begin
        state_next                  = state;
        return_state_next           = return_state;
        mips_flush_next             = mips_flush;
        mips_enabled_next           = mips_enabled;
        mips_clear_program_next     = mips_clear_program;
        start_uart_rd_next          = start_uart_rd;
        start_uart_wr_next          = start_uart_wr;
        start_register_print_next   = start_register_print;
        start_memory_print_next     = start_memory_print;
        mips_instruction_wr_next    = mips_instruction_wr;
        execution_by_steps_next     = execution_by_steps;
        execution_debug_next        = execution_debug;
        clk_counter_next            = clk_counter;
        mips_instruction_next       = mips_instruction;
        data_wr_next                = data_wr;
    
        case (state)
            /* ---------------------------------------------------- Estados de Espera ---------------------------------------------------- */

            `DEBUGGER_CONTROL_STATE_WAIT_RD:
            begin
                if (i_uart_rd_end)
                    state_next   = return_state;
            end

            `DEBUGGER_CONTROL_STATE_WAIT_RD_TRANSITION:
            begin
                start_uart_rd_next = `LOW;
                state_next         = `DEBUGGER_CONTROL_STATE_WAIT_RD;
            end

            `DEBUGGER_CONTROL_STATE_WAIT_WR:
            begin
                if (i_uart_wr_end)
                    state_next   = return_state;
            end

            `DEBUGGER_CONTROL_STATE_WAIT_WR_TRANSITION:
            begin
                start_uart_wr_next = `LOW;
                state_next         = `DEBUGGER_CONTROL_STATE_WAIT_WR;
            end

            /* ---------------------------------------------------- Comandos ---------------------------------------------------- */

            `DEBUGGER_CONTROL_STATE_UNKNOWN_CMD:
            begin
                data_wr_next       = {`DEBUGGER_ERROR_PREFIX, `DEBUGGER_NO_CICLE_MASK, `DEBUGGER_NO_ADDRESS_MASK, `DEBUGGER_ERROR_UNKNOWN_COMMAND};
                start_uart_wr_next = `HIGH;
                return_state_next  = return_state;
                state_next         = `DEBUGGER_CONTROL_STATE_WAIT_WR_TRANSITION;
            end

            `DEBUGGER_CONTROL_STATE_END_PROGRAM:
            begin
                data_wr_next       = {`DEBUGGER_INFO_PREFIX, `DEBUGGER_NO_CICLE_MASK, `DEBUGGER_NO_ADDRESS_MASK, `DEBUGGER_INFO_END_PROGRAM};
                start_uart_wr_next = `HIGH;
                return_state_next  = return_state;
                state_next         = `DEBUGGER_CONTROL_STATE_WAIT_WR_TRANSITION;
            end

            `DEBUGGER_CONTROL_STATE_EMPTY_PROGRAM:
            begin
                data_wr_next       = {`DEBUGGER_ERROR_PREFIX, `DEBUGGER_NO_CICLE_MASK, `DEBUGGER_NO_ADDRESS_MASK, `DEBUGGER_ERROR_NO_PROGRAM_LOAD};
                start_uart_wr_next = `HIGH;
                return_state_next  = return_state;
                state_next         = `DEBUGGER_CONTROL_STATE_WAIT_WR_TRANSITION;
            end

            `DEBUGGER_CONTROL_STATE_END_STEP:
            begin
                data_wr_next       = {`DEBUGGER_INFO_PREFIX, `DEBUGGER_NO_CICLE_MASK, `DEBUGGER_NO_ADDRESS_MASK, `DEBUGGER_INFO_END_STEP};
                start_uart_wr_next = `HIGH;
                return_state_next  = return_state;
                state_next         = `DEBUGGER_CONTROL_STATE_WAIT_WR_TRANSITION;
            end

            /* ---------------------------------------------------- Decodificación de Comandos ---------------------------------------------------- */

            `DEBUGGER_CONTROL_STATE_DECODE:
            begin
                case (i_data_uart_rd[7 : 0])
                    "L": 
                    begin
                        mips_flush_next         = `HIGH;
                        mips_clear_program_next = `HIGH;
                        return_state_next       = `DEBUGGER_CONTROL_STATE_LOAD_IDLE;
                        state_next              = `DEBUGGER_CONTROL_STATE_FLUSH;
                    end

                    "F": 
                    begin
                        mips_flush_next         = `HIGH;
                        mips_clear_program_next = `HIGH;
                        return_state_next       = `DEBUGGER_CONTROL_STATE_IDLE;
                        state_next              = `DEBUGGER_CONTROL_STATE_FLUSH;
                    end

                    "E":
                    begin
                        execution_by_steps_next = `LOW;
                        execution_debug_next    = `LOW;
                        mips_flush_next         = `HIGH;
                        return_state_next       = `DEBUGGER_CONTROL_STATE_RUN;
                        state_next              = `DEBUGGER_CONTROL_STATE_RESET;
                    end

                    "S":
                    begin
                        mips_flush_next           = `HIGH;
                        execution_by_steps_next   = `HIGH;
                        execution_debug_next      = `LOW;
                        start_register_print_next = `HIGH;
                        return_state_next         = `DEBUGGER_CONTROL_STATE_PRINT_REGISTERS_TRANSITION;
                        state_next                = `DEBUGGER_CONTROL_STATE_RESET;
                    end

                    "D":
                    begin
                        mips_flush_next           = `HIGH;
                        execution_by_steps_next   = `LOW;
                        execution_debug_next      = `HIGH;
                        start_register_print_next = `HIGH;
                        return_state_next         = `DEBUGGER_CONTROL_STATE_PRINT_REGISTERS_TRANSITION;
                        state_next                = `DEBUGGER_CONTROL_STATE_RESET;
                    end

                    default:
                    begin
                        return_state_next = `DEBUGGER_CONTROL_STATE_IDLE;
                        state_next        = `DEBUGGER_CONTROL_STATE_UNKNOWN_CMD;
                    end 
                endcase
            end

            `DEBUGGER_CONTROL_STATE_IDLE:
            begin
                clk_counter_next         = { { (UART_BUS_SIZE - 1) { `LOW } }, `HIGH };
                mips_enabled_next        = `LOW;
                mips_instruction_wr_next = `LOW;
                mips_flush_next          = `LOW;
                mips_clear_program_next  = `LOW;
                start_uart_rd_next       = `HIGH;
                return_state_next        = `DEBUGGER_CONTROL_STATE_DECODE;
                state_next               = `DEBUGGER_CONTROL_STATE_WAIT_RD_TRANSITION;
            end

            /* ---------------------------------------------------- Flush y Reset ---------------------------------------------------- */

            `DEBUGGER_CONTROL_STATE_FLUSH:
            begin
                mips_clear_program_next = `LOW;
                mips_flush_next         = `LOW;
                state_next              = return_state;
            end

            `DEBUGGER_CONTROL_STATE_RESET:
            begin
                mips_flush_next         = `LOW;
                state_next              = return_state;
            end

            /* ---------------------------------------------------- Cargar Programa ---------------------------------------------------- */
            
            `DEBUGGER_CONTROL_STATE_LOAD_IDLE:
            begin
                mips_instruction_wr_next = `LOW;

                if (mips_instruction == `INSTRUCTION_HALT)
                    begin
                        data_wr_next          = {`DEBUGGER_INFO_PREFIX, `DEBUGGER_NO_CICLE_MASK, `DEBUGGER_NO_ADDRESS_MASK, `DEBUGGER_INFO_LOAD_PROGRAM};
                        start_uart_wr_next    = `HIGH;
                        return_state_next     = `DEBUGGER_CONTROL_STATE_IDLE;
                        state_next            = `DEBUGGER_CONTROL_STATE_WAIT_WR_TRANSITION;
                        mips_instruction_next = `CLEAR(REGISTER_SIZE);
                    end
                else
                    begin
                        if (!i_instruction_memory_full)
                            begin
                                start_uart_rd_next = `HIGH;
                                return_state_next  = `DEBUGGER_CONTROL_STATE_LOAD;
                                state_next         = `DEBUGGER_CONTROL_STATE_WAIT_RD_TRANSITION;
                            end
                        else
                            begin
                                data_wr_next       = {`DEBUGGER_ERROR_PREFIX, `DEBUGGER_NO_CICLE_MASK, `DEBUGGER_NO_ADDRESS_MASK, `DEBUGGER_ERROR_INSTRUCTION_MEMORY_FULL};
                                start_uart_wr_next = `HIGH;
                                return_state_next  = `DEBUGGER_CONTROL_STATE_IDLE;
                                state_next         = `DEBUGGER_CONTROL_STATE_WAIT_WR_TRANSITION;
                            end
                    end
            end

            `DEBUGGER_CONTROL_STATE_LOAD:
            begin
                mips_instruction_next    = i_data_uart_rd;
                mips_instruction_wr_next = `HIGH;
                state_next               = `DEBUGGER_CONTROL_STATE_LOAD_IDLE;
            end

            /* ---------------------------------------------------- Ejecución del Programa ---------------------------------------------------- */

            `DEBUGGER_CONTROL_STATE_RUN_DECODE:
            begin
                case (i_data_uart_rd[7 : 0])
                    "S":
                    begin
                        state_next = `DEBUGGER_CONTROL_STATE_IDLE;
                    end

                    "N":
                    begin
                        state_next = `DEBUGGER_CONTROL_STATE_RUN_BY_STEPS;
                    end

                    default:
                    begin
                        return_state_next = `DEBUGGER_CONTROL_STATE_RUN_IDLE;
                        state_next        = `DEBUGGER_CONTROL_STATE_UNKNOWN_CMD;
                    end
                endcase
            end

            `DEBUGGER_CONTROL_STATE_RUN_WAIT_TRANSITION:
            begin
                start_uart_rd_next = `HIGH;
                return_state_next  = `DEBUGGER_CONTROL_STATE_RUN_DECODE;
                state_next         = `DEBUGGER_CONTROL_STATE_WAIT_RD_TRANSITION;
            end

            `DEBUGGER_CONTROL_STATE_RUN_IDLE:
            begin
                if (!i_mips_end_program)
                    begin
                        if (execution_by_steps)
                            begin
                                return_state_next  = `DEBUGGER_CONTROL_STATE_RUN_WAIT_TRANSITION;
                                state_next         = `DEBUGGER_CONTROL_STATE_END_STEP;
                            end
                        else if (execution_debug)
                            state_next = `DEBUGGER_CONTROL_STATE_RUN_BY_STEPS;
                        else
                            mips_enabled_next = `HIGH;
                    end
                else
                    begin
                        return_state_next = `DEBUGGER_CONTROL_STATE_IDLE;
                        state_next        = `DEBUGGER_CONTROL_STATE_END_PROGRAM;
                    end
            end

            `DEBUGGER_CONTROL_STATE_RUN_BY_STEPS:
            begin
                if (!i_instruction_memory_empty)
                    begin
                        mips_enabled_next         = `HIGH;
                        start_register_print_next = `HIGH;
                        state_next                = `DEBUGGER_CONTROL_STATE_PRINT_REGISTERS_TRANSITION;
                        clk_counter_next          = clk_counter + 1;
                    end
                else
                    begin
                        return_state_next = `DEBUGGER_CONTROL_STATE_IDLE;
                        state_next        = `DEBUGGER_CONTROL_STATE_EMPTY_PROGRAM;
                    end
            end

            `DEBUGGER_CONTROL_STATE_RUN:
            begin
                if (!i_instruction_memory_empty)
                    begin
                        if (i_mips_end_program)
                            begin
                                start_register_print_next = `HIGH;
                                state_next                = `DEBUGGER_CONTROL_STATE_PRINT_REGISTERS_TRANSITION;
                            end
                        else
                            begin
                                mips_enabled_next = `HIGH;
                                clk_counter_next  = clk_counter + 1;
                            end
                    end
                else
                    begin
                        return_state_next = `DEBUGGER_CONTROL_STATE_IDLE;
                        state_next        = `DEBUGGER_CONTROL_STATE_EMPTY_PROGRAM;
                    end
            end

            /* ---------------------------------------------------- Envia Registros y datos en Memoria ---------------------------------------------------- */
            
            `DEBUGGER_CONTROL_STATE_PRINT_REGISTERS_TRANSITION:
            begin
                mips_enabled_next         = `LOW;
                start_register_print_next = `LOW;
                state_next                = `DEBUGGER_CONTROL_STATE_PRINT_REGISTERS;
            end

            `DEBUGGER_CONTROL_STATE_PRINT_REGISTERS:
            begin
                if (i_register_print_end)
                    begin
                        start_memory_print_next  = `HIGH;
                        state_next               = `DEBUGGER_CONTROL_STATE_PRINT_MEMORY_DATA_TRANSITION;
                    end
            end

            `DEBUGGER_CONTROL_STATE_PRINT_MEMORY_DATA_TRANSITION:
            begin
                start_memory_print_next = `LOW;
                state_next              = `DEBUGGER_CONTROL_STATE_PRINT_MEMORY_DATA;
            end

            `DEBUGGER_CONTROL_STATE_PRINT_MEMORY_DATA:
            begin
                if (i_memory_print_end)
                    state_next = `DEBUGGER_CONTROL_STATE_RUN_IDLE;
            end

            /* ---------------------------------------------------------------------------------------------------------------------------- */

        endcase
    end

    assign o_mips_instruction     = mips_instruction;
    assign o_mips_instruction_wr  = mips_instruction_wr;
    assign o_mips_flush           = mips_flush;
    assign o_mips_clear_program   = mips_clear_program;
    assign o_mips_enabled         = mips_enabled;
    assign o_start_uart_wr        = start_uart_wr;
    assign o_start_uart_rd        = start_uart_rd;
    assign o_start_register_print = start_register_print;
    assign o_start_memory_print   = start_memory_print;
    assign o_data_wr              = data_wr;
    assign o_clk_cicle            = clk_counter;
    assign o_state                = state;

endmodule