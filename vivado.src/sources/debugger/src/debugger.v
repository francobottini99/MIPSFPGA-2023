`timescale 1ns / 1ps

`include "debugger.vh"

module debugger
    #(
        parameter UART_BUS_SIZE          = `DEFAULT_DEBUGGER_UART_BUS_SIZE,
        parameter DATA_IN_BUS_SIZE       = `DEFAULT_DEBUGGER_IN_BUS_SIZE,
        parameter DATA_OUT_BUS_SIZE      = `DEFAULT_DEBUGGER_OUT_BUS_SIZE,
        parameter REGISTER_SIZE          = `DEFAULT_DEBUGGER_REGISTER_SIZE,
        parameter REGISTER_BANK_BUS_SIZE = `DEFAULT_DEBUGGER_REGISTER_BANK_BUS_SIZE,
        parameter MEMORY_SLOT_SIZE       = `DEFAULT_DEBUGGER_MEMORY_SLOT_SIZE,
        parameter MEMORY_DATA_BUS_SIZE   = `DEFAULT_DEBUGGER_MEMORY_DATA_BUS_SIZE
    )
    (
        input  wire                                  i_clk,
        input  wire                                  i_reset,
        input  wire                                  i_uart_empty,
        input  wire                                  i_uart_full,
        input  wire                                  i_instruction_memory_empty,
        input  wire                                  i_instruction_memory_full,
        input  wire                                  i_mips_end_program,
        input  wire [UART_BUS_SIZE - 1 : 0]          i_uart_data_rd,
        input  wire [REGISTER_BANK_BUS_SIZE - 1 : 0] i_registers_conntent,
        input  wire [MEMORY_DATA_BUS_SIZE - 1 : 0]   i_memory_conntent,
        output wire                                  o_uart_wr,
        output wire                                  o_uart_rd,
        output wire                                  o_mips_instruction_wr,
        output wire                                  o_mips_flush,
        output wire                                  o_mips_clear_program,
        output wire                                  o_mips_enabled,
        output wire [UART_BUS_SIZE - 1 : 0]          o_uart_data_wr,
        output wire [REGISTER_SIZE - 1 : 0]          o_mips_instruction,
        output wire [4 : 0]                          o_state
    );

    wire                             start_uart_rd;
    wire                             start_uart_wr;
    wire                             start_uart_wr_control;
    wire                             start_uart_wr_memory;
    wire                             start_uart_wr_printer;
    wire                             start_register_print;
    wire                             start_memory_print;
    wire                             end_uart_rd;
    wire                             end_uart_wr;
    wire                             end_register_print;
    wire                             end_memory_print;
    wire [UART_BUS_SIZE - 1 : 0]     clk_cicle;
    wire [DATA_IN_BUS_SIZE - 1 : 0]  data_uart_rd;
    wire [DATA_OUT_BUS_SIZE - 1 : 0] data_uart_wr;
    wire [DATA_OUT_BUS_SIZE - 1 : 0] data_uart_wr_control;
    wire [DATA_OUT_BUS_SIZE - 1 : 0] data_uart_wr_memory;
    wire [DATA_OUT_BUS_SIZE - 1 : 0] data_uart_wr_printer;

    assign start_uart_wr = start_uart_wr_control | start_uart_wr_memory | start_uart_wr_printer;

    reg  [DATA_OUT_BUS_SIZE - 1 : 0] reg_data_uart_wr;

    always @(posedge i_clk)
    begin
        if (i_reset)
            reg_data_uart_wr <= `CLEAR(DATA_OUT_BUS_SIZE);
        else
            begin
                if (start_uart_wr_control)
                    reg_data_uart_wr <= data_uart_wr_control;
                else if (start_uart_wr_memory)
                    reg_data_uart_wr <= data_uart_wr_memory;
                else if (start_uart_wr_printer)
                    reg_data_uart_wr <= data_uart_wr_printer;
            end
    end

    assign data_uart_wr = reg_data_uart_wr;

    uart_reader
    #(
        .UART_BUS_SIZE (UART_BUS_SIZE),
        .OUT_BUS_SIZE  (DATA_IN_BUS_SIZE)
    )
    uart_reader_unit
    (
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_uart_empty   (i_uart_empty),
        .i_start_rd     (start_uart_rd),
        .i_uart_data_rd (i_uart_data_rd),
        .o_uart_rd      (o_uart_rd),
        .o_rd_end       (end_uart_rd),
        .o_rd_data      (data_uart_rd)
    );

    uart_writer
    #(
        .UART_BUS_SIZE (UART_BUS_SIZE),
        .IN_BUS_SIZE   (DATA_OUT_BUS_SIZE)
    )
    uart_writer_unit
    (
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_uart_full    (i_uart_full),
        .i_start_wr     (start_uart_wr),
        .i_wr_data      (data_uart_wr),
        .o_uart_wr      (o_uart_wr),
        .o_wr_end       (end_uart_wr),
        .o_uart_data_wr (o_uart_data_wr)
    );

    register_printer
    #(
        .UART_BUS_SIZE          (UART_BUS_SIZE),
        .DATA_OUT_BUS_SIZE      (DATA_OUT_BUS_SIZE),
        .REGISTER_SIZE          (REGISTER_SIZE),
        .REGISTER_BANK_BUS_SIZE (REGISTER_BANK_BUS_SIZE)
    )
    register_printer_unit
    (
        .i_clk                (i_clk),
        .i_reset              (i_reset),
        .i_start              (start_register_print),
        .i_registers_conntent (i_registers_conntent),
        .i_clk_cicle          (clk_cicle),
        .i_wr_end             (end_uart_wr),
        .o_start_wr           (start_uart_wr_printer),
        .o_end                (end_register_print),
        .o_data_wr            (data_uart_wr_printer)
    );

    memory_printer
    #(
        .UART_BUS_SIZE        (UART_BUS_SIZE),
        .DATA_OUT_BUS_SIZE    (DATA_OUT_BUS_SIZE),
        .MEMORY_SLOT_SIZE     (MEMORY_SLOT_SIZE),
        .MEMORY_DATA_BUS_SIZE (MEMORY_DATA_BUS_SIZE)
    )
    memory_printer_unit
    (
        .i_clk             (i_clk),
        .i_reset           (i_reset),
        .i_start           (start_memory_print),
        .i_memory_conntent (i_memory_conntent),
        .i_clk_cicle       (clk_cicle),
        .i_wr_end          (end_uart_wr),
        .o_start_wr        (start_uart_wr_memory),
        .o_end             (end_memory_print),
        .o_data_wr         (data_uart_wr_memory)
    );

    debugger_control
    #(
        .UART_BUS_SIZE     (UART_BUS_SIZE),
        .DATA_IN_BUS_SIZE  (DATA_IN_BUS_SIZE),
        .DATA_OUT_BUS_SIZE (DATA_OUT_BUS_SIZE),
        .REGISTER_SIZE     (REGISTER_SIZE)
    )
    debugger_control_unit
    (
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_instruction_memory_empty (i_instruction_memory_empty),
        .i_instruction_memory_full  (i_instruction_memory_full),
        .i_mips_end_program         (i_mips_end_program),
        .i_uart_rd_end              (end_uart_rd),
        .i_uart_wr_end              (end_uart_wr),
        .i_register_print_end       (end_register_print),
        .i_memory_print_end         (end_memory_print),
        .i_data_uart_rd             (data_uart_rd),
        .o_clk_cicle                (clk_cicle),
        .o_start_uart_rd            (start_uart_rd),
        .o_start_uart_wr            (start_uart_wr_control),
        .o_start_register_print     (start_register_print),
        .o_start_memory_print       (start_memory_print),
        .o_mips_instruction_wr      (o_mips_instruction_wr),
        .o_mips_flush               (o_mips_flush),
        .o_mips_clear_program       (o_mips_clear_program),
        .o_mips_enabled             (o_mips_enabled),
        .o_data_wr                  (data_uart_wr_control),
        .o_mips_instruction         (o_mips_instruction),
        .o_state                    (o_state)
    );

endmodule