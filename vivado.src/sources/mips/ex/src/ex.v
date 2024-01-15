`timescale 1ns / 1ps

`include "ex.vh"

module ex
    #(
        parameter BUS_SIZE = `DEFAULT_EX_BUS_SIZE
    )
    (
        // input controls wires
        input wire                     i_alu_src_a,
        input wire  [2 : 0]            i_alu_src_b,
        input wire  [1 : 0]            i_reg_dst,
        input wire  [2 : 0]            i_alu_op,
        input wire  [1 : 0]            i_sc_src_a,
        input wire  [1 : 0]            i_sc_src_b,
        input wire  [4 : 0]            i_rt,
        input wire  [4 : 0]            i_rd,
        input wire  [5 : 0]            i_funct,
        // input data wires
        input wire  [BUS_SIZE - 1 : 0] i_sc_alu_result,
        input wire  [BUS_SIZE - 1 : 0] i_sc_wb_result,
        input wire  [BUS_SIZE - 1 : 0] i_bus_a,
        input wire  [BUS_SIZE - 1 : 0] i_bus_b,
        input wire  [BUS_SIZE - 1 : 0] i_shamt_ext_unsigned,
        input wire  [BUS_SIZE - 1 : 0] i_inm_ext_signed,
        input wire  [BUS_SIZE - 1 : 0] i_inm_upp,
        input wire  [BUS_SIZE - 1 : 0] i_inm_ext_unsigned,
        input wire  [BUS_SIZE - 1 : 0] i_next_seq_pc,
        // output data wires
        output wire [4 : 0]            o_wb_addr,
        output wire [BUS_SIZE - 1 : 0] o_alu_result,
        output wire [BUS_SIZE - 1 : 0] o_sc_bus_b,
        output wire [BUS_SIZE - 1 : 0] o_sc_bus_a
    );

    /* -------------------------- Internal wires -------------------------- */
    wire [BUS_SIZE - 1 : 0] alu_data_a;
    wire [BUS_SIZE - 1 : 0] alu_data_b;
    wire [3 : 0]            alu_ctrl;

    /* -------------------------- ALU -------------------------- */
    alu 
    #(
        .IO_BUS_WIDTH  (BUS_SIZE),
        .CTR_BUS_WIDTH (4)
    ) 
    alu_unit 
    (
        .i_ctr_code (alu_ctrl),
        .i_data_a   (alu_data_a),
        .i_data_b   (alu_data_b),
        .o_data     (o_alu_result)
    );

    /* -------------------------- ALU Control -------------------------- */
    alu_control 
    #(
        .ALU_CTR_BUS_WIDTH   (4),
        .ALU_OP_BUS_WIDTH    (3),
        .ALU_FUNCT_BUS_WIDTH (6)
    ) 
    alu_control_unit 
    (
        .i_funct   (i_funct),
        .i_alu_op  (i_alu_op),
        .o_alu_ctr (alu_ctrl)
    );

    /* -------------------------- MUX ALU Data A -------------------------- */
    mux 
    #(
        .CHANNELS(2), 
        .BUS_SIZE(BUS_SIZE)
    ) 
    mux_alu_src_data_a_unit
    (
        .selector (i_alu_src_a),
        .data_in  ({o_sc_bus_a, i_shamt_ext_unsigned}),
        .data_out (alu_data_a)
    );

    /* -------------------------- MUX ALU Data B -------------------------- */
    mux 
    #(
        .CHANNELS(5), 
        .BUS_SIZE(BUS_SIZE)
    ) 
    mux_alu_src_data_b_unit
    (
        .selector (i_alu_src_b),
        .data_in  ({o_sc_bus_b, i_inm_ext_unsigned, i_inm_ext_signed, i_inm_upp, i_next_seq_pc}),
        .data_out (alu_data_b)
    );

    /* -------------------------- MUX Short circuit source A -------------------------- */
    mux 
    #(
        .CHANNELS(3), 
        .BUS_SIZE(BUS_SIZE)
    ) 
    mux_sc_src_a_unit
    (
        .selector (i_sc_src_a),
        .data_in  ({i_sc_alu_result, i_sc_wb_result, i_bus_a}),
        .data_out (o_sc_bus_a)
    );

    /* -------------------------- MUX Short circuit source B -------------------------- */
    mux 
    #(
        .CHANNELS(3), 
        .BUS_SIZE(BUS_SIZE)
    ) 
    mux_sc_src_b_unit
    (
        .selector (i_sc_src_b),
        .data_in  ({i_sc_alu_result, i_sc_wb_result, i_bus_b}),
        .data_out (o_sc_bus_b)
    );

    /* -------------------------- MUX REG destiny -------------------------- */
    mux 
    #(
        .CHANNELS(3), 
        .BUS_SIZE(5)
    ) 
    mux_reg_dst_unit
    (
        .selector (i_reg_dst),
        .data_in  ({5'b11111, i_rd, i_rt}),
        .data_out (o_wb_addr)
    );
    
endmodule