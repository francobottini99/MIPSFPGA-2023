`timescale 1ns / 1ps

`include "mem.vh"

module mem
    #(
        parameter IO_BUS_SIZE   = `DEFAULT_MEM_BUS_SIZE,
        parameter MEM_ADDR_SIZE = `DEFAULT_DATA_MEMORY_ADDR_SIZE
    )
    (
        input  wire                                          i_clk,
        input  wire                                          i_reset,
        input  wire                                          i_flush,
        input  wire                                          i_mem_wr_rd,
        input  wire [1 : 0]                                  i_mem_wr_src,
        input  wire [2 : 0]                                  i_mem_rd_src,
        input  wire [MEM_ADDR_SIZE - 1 : 0]                  i_mem_addr,
        input  wire [IO_BUS_SIZE - 1 : 0]                    i_bus_b,
        output wire [IO_BUS_SIZE - 1 : 0]                    o_mem_rd,
        output wire [2**MEM_ADDR_SIZE * IO_BUS_SIZE - 1 : 0] o_bus_debug
    );

    wire [`BYTE_SIZE - 1 : 0]      bus_b_byte;
    wire [IO_BUS_SIZE / 2 - 1 : 0] bus_b_halfword;
    wire [IO_BUS_SIZE - 1 : 0]     bus_b_uext_byte;
    wire [IO_BUS_SIZE - 1 : 0]     bus_b_uext_halfword;

    wire [`BYTE_SIZE - 1 : 0]      mem_out_data_byte;
    wire [IO_BUS_SIZE / 2 - 1 : 0] mem_out_data_halfword;
    wire [IO_BUS_SIZE - 1 : 0]     mem_out_data_uext_byte;
    wire [IO_BUS_SIZE - 1 : 0]     mem_out_data_uext_halfword;
    wire [IO_BUS_SIZE - 1 : 0]     mem_out_data_sext_byte;
    wire [IO_BUS_SIZE - 1 : 0]     mem_out_data_sext_halfword;

    wire [IO_BUS_SIZE - 1 : 0]     mem_in_data;
    wire [IO_BUS_SIZE - 1 : 0]     mem_out_data;

    assign bus_b_byte            = i_bus_b[`BYTE_SIZE - 1 : 0];
    assign bus_b_halfword        = i_bus_b[IO_BUS_SIZE / 2 - 1 : 0];

    assign mem_out_data_byte     = mem_out_data[`BYTE_SIZE - 1 : 0];
    assign mem_out_data_halfword = mem_out_data[IO_BUS_SIZE / 2 - 1 : 0];

    data_memory
    #(
        .ADDR_SIZE (MEM_ADDR_SIZE),
        .SLOT_SIZE (IO_BUS_SIZE)
    )
    data_memory_unit
    (
        .i_clk       (i_clk),
        .i_reset     (i_reset),
        .i_flush     (i_flush),
        .i_wr_rd     (i_mem_wr_rd),
        .i_addr      (i_mem_addr),
        .i_data      (mem_in_data),
        .o_data      (mem_out_data),
        .o_bus_debug (o_bus_debug)
    );

    mux 
    #(
        .CHANNELS (3), 
        .BUS_SIZE (IO_BUS_SIZE)
    ) 
    mux_in_mem_unit
    (
        .selector (i_mem_wr_src),
        .data_in  ({bus_b_uext_byte, bus_b_uext_halfword, i_bus_b}),
        .data_out (mem_in_data)
    );

    mux 
    #(
        .CHANNELS (5), 
        .BUS_SIZE (IO_BUS_SIZE)
    ) 
    mux_out_mem_unit
    (
        .selector (i_mem_rd_src),
        .data_in  ({mem_out_data_uext_byte, mem_out_data_uext_halfword, mem_out_data_sext_byte, mem_out_data_sext_halfword, mem_out_data}),
        .data_out (o_mem_rd)
    );

    unsig_extend 
    #(
        .REG_IN_SIZE  (IO_BUS_SIZE / 2), 
        .REG_OUT_SIZE (IO_BUS_SIZE)
    ) 
    unsig_extend_bus_b_halfword_unit 
    (
        .i_reg (bus_b_halfword),
        .o_reg (bus_b_uext_halfword)
    );

    unsig_extend 
    #(
        .REG_IN_SIZE  (`BYTE_SIZE), 
        .REG_OUT_SIZE (IO_BUS_SIZE)
    ) 
    unsig_extend_bus_b_byte_unit 
    (
        .i_reg (bus_b_byte),
        .o_reg (bus_b_uext_byte)
    );

    unsig_extend 
    #(
        .REG_IN_SIZE  (IO_BUS_SIZE / 2), 
        .REG_OUT_SIZE (IO_BUS_SIZE)
    ) 
    unsig_extend_mem_out_data_halfword_unit 
    (
        .i_reg (mem_out_data_halfword),
        .o_reg (mem_out_data_uext_halfword)
    );

    unsig_extend 
    #(
        .REG_IN_SIZE  (`BYTE_SIZE), 
        .REG_OUT_SIZE (IO_BUS_SIZE)
    ) 
    unsig_extend_mem_out_data_byte_unit 
    (
        .i_reg (mem_out_data_byte),
        .o_reg (mem_out_data_uext_byte)
    );

    sig_extend 
    #(
        .REG_IN_SIZE  (IO_BUS_SIZE / 2), 
        .REG_OUT_SIZE (IO_BUS_SIZE)
    ) 
    sig_extend_mem_out_data_halfword_unit
    (
        .i_reg (mem_out_data_halfword),
        .o_reg (mem_out_data_sext_halfword)
    );

    sig_extend
    #(
        .REG_IN_SIZE  (`BYTE_SIZE), 
        .REG_OUT_SIZE (IO_BUS_SIZE)
    )
    sig_extend_mem_out_data_byte_unit
    (
        .i_reg (mem_out_data_byte),
        .o_reg (mem_out_data_sext_byte)
    );

endmodule