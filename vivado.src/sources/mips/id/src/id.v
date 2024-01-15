`timescale 1ns / 1ps

`include "id.vh"
`include "codes.vh"

module id
    #(
        parameter REGISTERS_BANK_SIZE = `DEFAULT_REGISTERS_BANK_SIZE,
        parameter PC_SIZE             = `DEFAULT_PC_SIZE,
        parameter BUS_SIZE            = `DEFAULT_ID_BUS_SIZE
    )
    (
        /* input controls wires */
        input  wire                                          i_clk,
        input  wire                                          i_reset,
        input  wire                                          i_flush,
        input  wire                                          i_reg_write_enable,
        input  wire                                          i_ctr_reg_src,
        /* input data wires */
        input  wire [$clog2(REGISTERS_BANK_SIZE) - 1 : 0]    i_reg_addr_wr,
        input  wire [BUS_SIZE - 1 : 0]                       i_reg_bus_wr,
        input  wire [BUS_SIZE - 1 : 0]                       i_instruction,
        input  wire [BUS_SIZE - 1 : 0]                       i_ex_bus_a,
        input  wire [BUS_SIZE - 1 : 0]                       i_ex_bus_b,
        input  wire [PC_SIZE - 1 : 0]                        i_next_seq_pc,
        /* output controls wires */
        output wire                                          o_next_pc_src,
        output wire [2 : 0]                                  o_mem_rd_src,
        output wire [1 : 0]                                  o_mem_wr_src,
        output wire                                          o_mem_write,
        output wire                                          o_wb,
        output wire                                          o_mem_to_reg,
        output wire [1 : 0]                                  o_reg_dst,
        output wire                                          o_alu_src_a,
        output wire [2 : 0]                                  o_alu_src_b,
        output wire [2 : 0]                                  o_alu_op,
        /* output data wires */
        output wire [BUS_SIZE - 1 : 0]                       o_bus_a,
        output wire [BUS_SIZE - 1 : 0]                       o_bus_b,
        output wire [PC_SIZE - 1 : 0]                        o_next_not_seq_pc,
        output wire [4 : 0]                                  o_rs,
        output wire [4 : 0]                                  o_rt,
        output wire [4 : 0]                                  o_rd,
        output wire [5 : 0]                                  o_funct,
        output wire [5 : 0]                                  o_op,
        output wire [BUS_SIZE - 1 : 0]                       o_shamt_ext_unsigned,
        output wire [BUS_SIZE - 1 : 0]                       o_inm_ext_signed,
        output wire [BUS_SIZE - 1 : 0]                       o_inm_upp,
        output wire [BUS_SIZE - 1 : 0]                       o_inm_ext_unsigned,
        /* debug wires */
        output wire [REGISTERS_BANK_SIZE * BUS_SIZE - 1 : 0] o_bus_debug
    );

    /* -------------------------- Internal wires -------------------------- */
    
    wire                    is_not_equal_result;
    wire                    is_nop_result;
    wire [1 : 0]            jmp_ctrl;
    wire [19 : 0]           main_ctrl_regs;
    wire [16 : 0]           next_stage_ctrl_regs; 
    wire [4 : 0]            shamt;
    wire [15 : 0]           inm;
    wire [25 : 0]           dir;
    wire [BUS_SIZE - 1 : 0] inm_ext_signed_shifted;
    wire [BUS_SIZE - 1 : 0] dir_ext_unsigned;
    wire [BUS_SIZE - 1 : 0] dir_ext_unsigned_shifted;
    wire [BUS_SIZE - 1 : 0] branch_pc_dir;
    wire [BUS_SIZE - 1 : 0] jump_pc_dir;
    
    /* -------------------------- Assignment internal wires -------------------------- */
    assign dir           = i_instruction[25:0];
    assign inm           = i_instruction[15:0];
    assign shamt         = i_instruction[10:6];
    assign jmp_ctrl      = main_ctrl_regs[18:17];
    assign jump_pc_dir   = { i_next_seq_pc[31:28], dir_ext_unsigned_shifted[27:0] };

    /* -------------------------- Assignment output wires -------------------------- */
    assign o_op          = i_instruction[31:26];
    assign o_rs          = i_instruction[25:21];
    assign o_rt          = i_instruction[20:16];
    assign o_rd          = i_instruction[15:11];
    assign o_funct       = i_instruction[5:0];
    assign o_next_pc_src = main_ctrl_regs[19];
    assign o_reg_dst     = next_stage_ctrl_regs[16:15];
    assign o_alu_src_a   = next_stage_ctrl_regs[14];
    assign o_alu_src_b   = next_stage_ctrl_regs[13:11];
    assign o_alu_op      = next_stage_ctrl_regs[10:8];
    assign o_mem_rd_src  = next_stage_ctrl_regs[7:5];
    assign o_mem_wr_src  = next_stage_ctrl_regs[4:3];
    assign o_mem_write   = next_stage_ctrl_regs[2];
    assign o_wb          = next_stage_ctrl_regs[1];
    assign o_mem_to_reg  = next_stage_ctrl_regs[0];

    /* -------------------------- Register Bank -------------------------- */
    registers_bank 
    #(
        .REGISTERS_BANK_SIZE (REGISTERS_BANK_SIZE),
        .REGISTERS_SIZE      (BUS_SIZE)
    ) 
    registers_bank_unit 
    (
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_flush        (i_flush),
        .i_write_enable (i_reg_write_enable),
        .i_addr_a       (o_rs),
        .i_addr_b       (o_rt),
        .i_addr_wr      (i_reg_addr_wr),
        .i_bus_wr       (i_reg_bus_wr),
        .o_bus_a        (o_bus_a),
        .o_bus_b        (o_bus_b),
        .o_bus_debug    (o_bus_debug)
    );

    /* -------------------------- Main Control -------------------------- */
    main_control main_control_unit 
    (
        .i_bus_a_not_equal_bus_b (is_not_equal_result),
        .i_instruction_is_nop    (is_nop_result),
        .i_op                    (o_op),
        .i_funct                 (o_funct),
        .o_ctrl_regs             (main_ctrl_regs)
    );

    /* -------------------------- Extend unsigned for DIR -------------------------- */
    unsig_extend 
    #(
        .REG_IN_SIZE  (26), 
        .REG_OUT_SIZE (BUS_SIZE)
    ) 
    unsig_extend_dir_unit 
    (
        .i_reg (dir),
        .o_reg (dir_ext_unsigned)
    );

    /* -------------------------- Extend signed for INM -------------------------- */
    sig_extend 
    #(
        .REG_IN_SIZE  (16), 
        .REG_OUT_SIZE (BUS_SIZE)
    ) 
    sig_extend_inm_unit 
    (
        .i_reg (inm),
        .o_reg (o_inm_ext_signed)
    );
    
    /* -------------------------- Extend unsigned for INM -------------------------- */
    unsig_extend 
    #(
        .REG_IN_SIZE  (16), 
        .REG_OUT_SIZE (BUS_SIZE)
    ) 
    unsig_extend_inm_unit 
    (
        .i_reg (inm),
        .o_reg (o_inm_ext_unsigned)
    );

    /* -------------------------- Extend unsigned for SHAMT -------------------------- */
    unsig_extend 
    #(
        .REG_IN_SIZE  (5), 
        .REG_OUT_SIZE (BUS_SIZE)
    ) 
    unsig_extend_shamt_unit 
    (
        .i_reg (shamt),
        .o_reg (o_shamt_ext_unsigned)
    );

    /* -------------------------- Test if not EQUAL A and B -------------------------- */
    is_not_equal 
    #(
        .BUS_SIZE (BUS_SIZE)
    )
    is_not_equal_unit 
    (
        .in_a         (i_ex_bus_a),
        .in_b         (i_ex_bus_b),
        .is_not_equal (is_not_equal_result)
    );

    /* -------------------------- Test if zero INSTRUCTION -------------------------- */
    is_zero 
    #(
        .BUS_SIZE (BUS_SIZE)
    )
    is_nop_unit 
    (
        .in      (i_instruction),
        .is_zero (is_nop_result)
    );

    /* -------------------------- Shift left 2 for extended signed INM -------------------------- */
    shift_left 
    #(
        .BUS_SIZE   (BUS_SIZE), 
        .SHIFT_LEFT (2)
    ) 
    shift_left_ext_inm_signed_unit 
    (
        .in  (o_inm_ext_signed),
        .out (inm_ext_signed_shifted)
    );

    /* -------------------------- Shift left 2 for DIR -------------------------- */
    shift_left 
    #(
        .BUS_SIZE   (BUS_SIZE), 
        .SHIFT_LEFT (2)
    ) 
    shift_left_dir_unit 
    (
        .in  (dir_ext_unsigned),
        .out (dir_ext_unsigned_shifted)
    );

    /* -------------------------- Shift left 16 for INM -------------------------- */
    shift_left 
    #(
        .BUS_SIZE   (BUS_SIZE), 
        .SHIFT_LEFT (16)
    ) 
    shift_left_inm_unit 
    (
        .in  (o_inm_ext_unsigned),
        .out (o_inm_upp)
    );

    /* -------------------------- Adder to calculate next branch PC -------------------------- */
    adder 
    #
    (
        .BUS_SIZE (BUS_SIZE)
    ) 
    adder_unit 
    (
        .a   (i_next_seq_pc),
        .b   (inm_ext_signed_shifted),
        .sum (branch_pc_dir)
    );

    /* -------------------------- Mux to select next stage control register -------------------------- */
    mux 
    #(
        .CHANNELS(2), 
        .BUS_SIZE(17)
    ) 
    mux_ctr_regs_unit
    (
        .selector (i_ctr_reg_src),
        .data_in  ({17'b0, main_ctrl_regs[16:0]}),
        .data_out (next_stage_ctrl_regs)
    );

    /* -------------------------- Mux to select next PC -------------------------- */
    mux 
    #(
        .CHANNELS(3), 
        .BUS_SIZE(BUS_SIZE)
    ) 
    mux_jump_src_unit
    (
        .selector (jmp_ctrl),
        .data_in  ({jump_pc_dir, i_ex_bus_a, branch_pc_dir}),
        .data_out (o_next_not_seq_pc)
    );

endmodule