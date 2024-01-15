`timescale 1ns / 1ps

`include "mips.vh"

module mips
    #(
        parameter PC_BUS_SIZE                           = `DEFAULT_PC_SIZE,
        parameter DATA_BUS_SIZE                         = `DEFAULT_ID_BUS_SIZE, 
        parameter INSTRUCTION_BUS_SIZE                  = `DEFAULT_ID_INSTRUCTION_SIZE, 
        parameter INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES = `DEFAULT_INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES,
        parameter INSTRUCTION_MEMORY_SIZE_IN_WORDS      = `DEFAULT_INSTRUCTION_MEMORY_MEM_SIZE_IN_WORDS,
        parameter REGISTERS_BANK_SIZE                   = `DEFAULT_REGISTERS_BANK_SIZE,
        parameter DATA_MEMORY_ADDR_SIZE                 = `DEFAULT_DATA_MEMORY_ADDR_SIZE
    )
    (
        input  wire                                                    i_clk,
        input  wire                                                    i_reset,
        input  wire                                                    i_enable,
        input  wire                                                    i_ins_mem_wr,
        input  wire                                                    i_flush,
        input  wire                                                    i_clear_program,
        input  wire [INSTRUCTION_BUS_SIZE - 1 : 0]                     i_ins,
        output wire                                                    o_end_program,
        output wire                                                    o_ins_mem_full,
        output wire                                                    o_ins_mem_empty,
        output wire [REGISTERS_BANK_SIZE * DATA_BUS_SIZE - 1 : 0]      o_registers,
        output wire [2**DATA_MEMORY_ADDR_SIZE * DATA_BUS_SIZE - 1 : 0] o_mem_data
    );

    // --------------------------- IF Wires ---------------------------
    wire                                       i_if_not_load;
    wire [PC_BUS_SIZE - 1 : 0]                 i_if_next_not_seq_pc;
    wire [PC_BUS_SIZE - 1 : 0]                 i_if_next_seq_pc;
    wire                                       i_if_next_pc_src;
    wire                                       i_if_halt;
    wire [INSTRUCTION_BUS_SIZE - 1 : 0]        o_if_instruction;
    wire [PC_BUS_SIZE - 1 : 0]                 o_if_next_seq_pc;

    // --------------------------- IF / ID Wires ---------------------------
    wire                                       o_if_id_halt;                

    // --------------------------- ID Wires ---------------------------
    wire                                       i_id_reg_wr;
    wire                                       i_id_ctr_reg_src;
    wire [INSTRUCTION_BUS_SIZE - 1 : 0]        i_id_instruction;
    wire [$clog2(REGISTERS_BANK_SIZE) - 1 : 0] i_id_reg_addr_wr;
    wire [DATA_BUS_SIZE - 1 : 0]               i_id_reg_data_wr;
    wire [2 : 0]                               o_id_mem_rd_src;
    wire [1 : 0]                               o_id_mem_wr_src;
    wire                                       o_id_mem_write;
    wire                                       o_id_wb;
    wire                                       o_id_mem_to_reg;
    wire [1 : 0]                               o_id_reg_dst;
    wire                                       o_id_alu_src_a;
    wire [2 : 0]                               o_id_alu_src_b;
    wire [2 : 0]                               o_id_alu_op;
    wire [DATA_BUS_SIZE - 1 : 0]               o_id_bus_a;
    wire [DATA_BUS_SIZE - 1 : 0]               o_id_bus_b;
    wire [4 : 0]                               o_id_rs;
    wire [4 : 0]                               o_id_rt;
    wire [4 : 0]                               o_id_rd;
    wire [5 : 0]                               o_id_funct;
    wire [5 : 0]                               o_id_op;
    wire [DATA_BUS_SIZE - 1 : 0]               o_id_shamt_ext_unsigned;
    wire [DATA_BUS_SIZE - 1 : 0]               o_id_inm_ext_signed;
    wire [DATA_BUS_SIZE - 1 : 0]               o_id_inm_upp;
    wire [DATA_BUS_SIZE - 1 : 0]               o_id_inm_ext_unsigned;

    // --------------------------- ID / EX Wires ---------------------------
    wire                                       i_id_ex_jmp_stop;
    wire                                       o_id_ex_jmp_stop;
    wire                                       o_id_ex_halt;
    wire [4 : 0]                               o_id_ex_rs;
    wire [5 : 0]                               o_id_ex_op;

    // --------------------------- EX Wires ---------------------------
    wire [1 : 0]                               i_ex_reg_dst;
    wire                                       i_ex_alu_src_a;
    wire [2 : 0]                               i_ex_alu_src_b;
    wire [2 : 0]                               i_ex_alu_op;
    wire [DATA_BUS_SIZE - 1 : 0]               i_ex_bus_a;
    wire [DATA_BUS_SIZE - 1 : 0]               i_ex_bus_b;
    wire [4 : 0]                               i_ex_rt;
    wire [4 : 0]                               i_ex_rd;
    wire [5 : 0]                               i_ex_funct;
    wire [DATA_BUS_SIZE - 1 : 0]               i_ex_shamt_ext_unsigned;
    wire [DATA_BUS_SIZE - 1 : 0]               i_ex_inm_ext_signed;
    wire [DATA_BUS_SIZE - 1 : 0]               i_ex_inm_upp;
    wire [DATA_BUS_SIZE - 1 : 0]               i_ex_inm_ext_unsigned;
    wire [DATA_BUS_SIZE - 1 : 0]               i_ex_next_seq_pc;
    wire [1 : 0]                               i_ex_sc_src_a;
    wire [1 : 0]                               i_ex_sc_src_b;
    wire [DATA_BUS_SIZE - 1 : 0]               i_ex_sc_alu_result;
    wire [DATA_BUS_SIZE - 1 : 0]               i_ex_sc_wb_result;
    wire [DATA_MEMORY_ADDR_SIZE - 1 : 0]       o_ex_wb_addr;
    wire [DATA_BUS_SIZE - 1 : 0]               o_ex_alu_result;
    wire [DATA_BUS_SIZE - 1 : 0]               o_ex_sc_bus_b;
    wire [DATA_BUS_SIZE - 1 : 0]               o_ex_sc_bus_a;

    // --------------------------- EX / MEM Wires ---------------------------
    wire [2 : 0]                               i_ex_mem_mem_rd_src;
    wire [1 : 0]                               i_ex_mem_mem_wr_src;
    wire                                       i_ex_mem_mem_write;
    wire                                       i_ex_mem_wb;
    wire                                       i_ex_mem_mem_to_reg;
    wire                                       o_ex_mem_halt;

    // --------------------------- MEM Wires ---------------------------
    wire                                       i_mem_mem_wr_rd;
    wire [1 : 0]                               i_mem_mem_wr_src;
    wire [2 : 0]                               i_mem_mem_rd_src;
    wire [DATA_BUS_SIZE - 1 : 0]               i_mem_bus_b;
    wire [DATA_BUS_SIZE - 1 : 0]               o_mem_mem_rd;

    // --------------------------- MEM / WB Wires ---------------------------
    wire                                       i_mem_wb_mem_to_reg;
    wire                                       i_mem_wb_wb;
    wire [DATA_MEMORY_ADDR_SIZE - 1 : 0]       i_mem_wb_addr_wr;
    wire [DATA_BUS_SIZE - 1 : 0]               i_mem_wb_alu_res;

    // --------------------------- WB Wires ---------------------------
    wire [DATA_BUS_SIZE - 1 : 0]               i_wb_mem_result;
    wire [DATA_BUS_SIZE - 1 : 0]               i_wb_alu_result;
    wire                                       i_wb_mem_to_reg;

    // --------------------------- IF Unit ---------------------------
    _if
    #(
        .PC_SIZE            (PC_BUS_SIZE),
        .WORD_SIZE_IN_BYTES (INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES),
        .MEM_SIZE_IN_WORDS  (INSTRUCTION_MEMORY_SIZE_IN_WORDS)
    )
    if_unit
    (
        .i_clk             (i_clk),
        .i_reset           (i_reset),
        .i_enable          (i_enable),
        .i_write_mem       (i_ins_mem_wr),
        .i_instruction     (i_ins),
        .i_halt            (i_if_halt),
        .i_not_load        (i_if_not_load),
        .i_next_pc_src     (i_if_next_pc_src),
        .i_next_not_seq_pc (i_if_next_not_seq_pc),
        .i_next_seq_pc     (i_if_next_seq_pc),
        .i_flush           (i_flush),
        .i_clear_mem       (i_clear_program),
        .o_full_mem        (o_ins_mem_full),
        .o_empty_mem       (o_ins_mem_empty),
        .o_instruction     (o_if_instruction),
        .o_next_seq_pc     (o_if_next_seq_pc)
    );

    // --------------------------- IF / ID Unit ---------------------------
    if_id
    #(
        .PC_SIZE          (PC_BUS_SIZE),
        .INSTRUCTION_SIZE (INSTRUCTION_BUS_SIZE)
    )
    if_id_unit
    (
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_enable       (i_enable),
        .i_flush        (i_flush),
        .i_halt         (i_if_halt),
        .i_next_seq_pc  (o_if_next_seq_pc),
        .i_instruction  (o_if_instruction),
        .o_next_seq_pc  (i_if_next_seq_pc),
        .o_instruction  (i_id_instruction),
        .o_halt         (o_if_id_halt)
    );

    // --------------------------- ID Unit ---------------------------
    id
    #(
        .REGISTERS_BANK_SIZE (REGISTERS_BANK_SIZE),
        .PC_SIZE             (PC_BUS_SIZE),
        .BUS_SIZE            (DATA_BUS_SIZE)
    ) 
    id_unit
    (
        .i_clk                (i_clk),
        .i_reset              (i_reset),
        .i_flush              (i_flush),
        .i_reg_write_enable   (i_id_reg_wr),
        .i_ctr_reg_src        (i_id_ctr_reg_src),
        .i_reg_addr_wr        (i_id_reg_addr_wr),
        .i_reg_bus_wr         (i_id_reg_data_wr),
        .i_instruction        (i_id_instruction),
        .i_ex_bus_a           (o_ex_sc_bus_a),
        .i_ex_bus_b           (o_ex_sc_bus_b),
        .i_next_seq_pc        (i_if_next_seq_pc),
        .o_next_pc_src        (i_if_next_pc_src),
        .o_next_not_seq_pc    (i_if_next_not_seq_pc),
        .o_mem_rd_src         (o_id_mem_rd_src),
        .o_mem_wr_src         (o_id_mem_wr_src),
        .o_mem_write          (o_id_mem_write),
        .o_wb                 (o_id_wb),
        .o_mem_to_reg         (o_id_mem_to_reg),
        .o_reg_dst            (o_id_reg_dst),
        .o_alu_src_a          (o_id_alu_src_a),
        .o_alu_src_b          (o_id_alu_src_b),
        .o_alu_op             (o_id_alu_op),
        .o_bus_a              (o_id_bus_a),
        .o_bus_b              (o_id_bus_b),
        .o_rs                 (o_id_rs),
        .o_rt                 (o_id_rt),
        .o_rd                 (o_id_rd),
        .o_funct              (o_id_funct),
        .o_op                 (o_id_op),
        .o_shamt_ext_unsigned (o_id_shamt_ext_unsigned),
        .o_inm_ext_signed     (o_id_inm_ext_signed),
        .o_inm_upp            (o_id_inm_upp),
        .o_inm_ext_unsigned   (o_id_inm_ext_unsigned),
        .o_bus_debug          (o_registers)
    );

    // --------------------------- ID / EX Unit ---------------------------
    id_ex
    #(
        .BUS_SIZE (DATA_BUS_SIZE)
    )
    id_ex_unit 
    (
        .i_clk                (i_clk),
        .i_reset              (i_reset),
        .i_enable             (i_enable),
        .i_flush              (i_flush),
        .i_mem_rd_src         (o_id_mem_rd_src),
        .i_mem_wr_src         (o_id_mem_wr_src),
        .i_mem_write          (o_id_mem_write),
        .i_wb                 (o_id_wb),
        .i_jmp_stop           (i_id_ex_jmp_stop),
        .i_mem_to_reg         (o_id_mem_to_reg),
        .i_reg_dst            (o_id_reg_dst),
        .i_alu_src_a          (o_id_alu_src_a),
        .i_alu_src_b          (o_id_alu_src_b),
        .i_alu_op             (o_id_alu_op),
        .i_bus_a              (o_id_bus_a),
        .i_bus_b              (o_id_bus_b),
        .i_rs                 (o_id_rs),
        .i_rt                 (o_id_rt),
        .i_rd                 (o_id_rd),
        .i_funct              (o_id_funct),
        .i_op                 (o_id_op),
        .i_shamt_ext_unsigned (o_id_shamt_ext_unsigned),
        .i_inm_ext_signed     (o_id_inm_ext_signed),
        .i_inm_upp            (o_id_inm_upp),
        .i_inm_ext_unsigned   (o_id_inm_ext_unsigned),
        .i_next_seq_pc        (i_if_next_seq_pc),
        .i_halt               (o_if_id_halt),
        .o_reg_dst            (i_ex_reg_dst),
        .o_alu_src_a          (i_ex_alu_src_a),
        .o_alu_src_b          (i_ex_alu_src_b),
        .o_alu_op             (i_ex_alu_op),
        .o_bus_a              (i_ex_bus_a),
        .o_bus_b              (i_ex_bus_b),
        .o_rs                 (o_id_ex_rs),
        .o_rt                 (i_ex_rt),
        .o_rd                 (i_ex_rd),
        .o_funct              (i_ex_funct),
        .o_op                 (o_id_ex_op),
        .o_shamt_ext_unsigned (i_ex_shamt_ext_unsigned),
        .o_inm_ext_signed     (i_ex_inm_ext_signed),
        .o_inm_upp            (i_ex_inm_upp),
        .o_inm_ext_unsigned   (i_ex_inm_ext_unsigned),
        .o_next_seq_pc        (i_ex_next_seq_pc),
        .o_mem_rd_src         (i_ex_mem_mem_rd_src),
        .o_mem_wr_src         (i_ex_mem_mem_wr_src),
        .o_mem_write          (i_ex_mem_mem_write),
        .o_wb                 (i_ex_mem_wb),
        .o_mem_to_reg         (i_ex_mem_mem_to_reg),
        .o_jmp_stop           (o_id_ex_jmp_stop),
        .o_halt               (o_id_ex_halt)
    );

    // --------------------------- EX Unit ---------------------------
    ex
    #(
        .BUS_SIZE (DATA_BUS_SIZE)
    )
    ex_unit
    (
        .i_reg_dst            (i_ex_reg_dst),
        .i_alu_src_a          (i_ex_alu_src_a),
        .i_alu_src_b          (i_ex_alu_src_b),
        .i_alu_op             (i_ex_alu_op),
        .i_bus_a              (i_ex_bus_a),
        .i_bus_b              (i_ex_bus_b),
        .i_rt                 (i_ex_rt),
        .i_rd                 (i_ex_rd),
        .i_funct              (i_ex_funct),
        .i_shamt_ext_unsigned (i_ex_shamt_ext_unsigned),
        .i_inm_ext_signed     (i_ex_inm_ext_signed),
        .i_inm_upp            (i_ex_inm_upp),
        .i_inm_ext_unsigned   (i_ex_inm_ext_unsigned),
        .i_next_seq_pc        (i_ex_next_seq_pc),
        .i_sc_src_a           (i_ex_sc_src_a),
        .i_sc_src_b           (i_ex_sc_src_b),
        .i_sc_alu_result      (i_mem_wb_alu_res),
        .i_sc_wb_result       (i_id_reg_data_wr),
        .o_wb_addr            (o_ex_wb_addr),
        .o_alu_result         (o_ex_alu_result),
        .o_sc_bus_b           (o_ex_sc_bus_b),
        .o_sc_bus_a           (o_ex_sc_bus_a)
    );

    // --------------------------- EX / MEM Unit ---------------------------
    ex_mem
    #(
        .BUS_SIZE      (DATA_BUS_SIZE),
        .MEM_ADDR_SIZE (DATA_MEMORY_ADDR_SIZE)
    )
    ex_mem_unit
    (
        .i_clk         (i_clk),
        .i_reset       (i_reset),
        .i_enable      (i_enable),
        .i_flush       (i_flush),
        .i_mem_rd_src  (i_ex_mem_mem_rd_src),
        .i_mem_wr_src  (i_ex_mem_mem_wr_src),
        .i_mem_write   (i_ex_mem_mem_write),
        .i_wb          (i_ex_mem_wb),
        .i_mem_to_reg  (i_ex_mem_mem_to_reg),
        .i_alu_result  (o_ex_alu_result),
        .i_bus_b       (o_ex_sc_bus_b),
        .i_addr_wr     (o_ex_wb_addr),
        .i_halt        (o_id_ex_halt),
        .o_alu_result  (i_mem_wb_alu_res),
        .o_bus_b       (i_mem_bus_b),
        .o_mem_write   (i_mem_mem_wr_rd),
        .o_mem_wr_src  (i_mem_mem_wr_src),
        .o_mem_rd_src  (i_mem_mem_rd_src),
        .o_addr_wr     (i_mem_wb_addr_wr),
        .o_mem_to_reg  (i_mem_wb_mem_to_reg),
        .o_wb          (i_mem_wb_wb),
        .o_halt        (o_ex_mem_halt)
    );

    // --------------------------- MEM Unit ---------------------------
    mem
    #(
        .IO_BUS_SIZE   (DATA_BUS_SIZE),
        .MEM_ADDR_SIZE (DATA_MEMORY_ADDR_SIZE)
    )
    mem_unit
    (
        .i_clk         (i_clk),
        .i_reset       (i_reset),
        .i_flush       (i_flush),
        .i_mem_wr_rd   (i_mem_mem_wr_rd),
        .i_mem_wr_src  (i_mem_mem_wr_src),
        .i_mem_rd_src  (i_mem_mem_rd_src),
        .i_mem_addr    (i_mem_wb_alu_res[DATA_MEMORY_ADDR_SIZE - 1 : 0]),
        .i_bus_b       (i_mem_bus_b),
        .o_mem_rd      (o_mem_mem_rd),
        .o_bus_debug   (o_mem_data)
    );

    // --------------------------- MEM / WB Unit ---------------------------
    mem_wb
    #(
        .BUS_SIZE      (DATA_BUS_SIZE),
        .MEM_ADDR_SIZE (DATA_MEMORY_ADDR_SIZE)
    )
    mem_wb_unit
    (
        .i_clk         (i_clk),
        .i_reset       (i_reset),
        .i_enable      (i_enable),
        .i_flush       (i_flush),
        .i_mem_to_reg  (i_mem_wb_mem_to_reg),
        .i_wb          (i_mem_wb_wb),
        .i_mem_result  (o_mem_mem_rd),
        .i_alu_result  (i_mem_wb_alu_res),
        .i_addr_wr     (i_mem_wb_addr_wr),
        .i_halt        (o_ex_mem_halt),
        .o_mem_to_reg  (i_wb_mem_to_reg),
        .o_wb          (i_id_reg_wr),
        .o_mem_result  (i_wb_mem_result),
        .o_alu_result  (i_wb_alu_result),
        .o_addr_wr     (i_id_reg_addr_wr),
        .o_halt        (o_end_program)
    );

    // --------------------------- WB Unit ---------------------------
    wb
    #(
        .IO_BUS_SIZE (DATA_BUS_SIZE)
    )
    wb_unit
    (
        .i_mem_to_reg (i_wb_mem_to_reg),
        .i_mem_result (i_wb_mem_result),
        .i_alu_result (i_wb_alu_result),
        .o_wb_data    (i_id_reg_data_wr)
    );

    // --------------------------- SHORT CIRCUIT Unit ---------------------------
    short_circuit
    #(
        .MEM_ADDR_SIZE (DATA_MEMORY_ADDR_SIZE)
    )
    short_circuit_unit
    (
        .i_ex_mem_wb     (i_mem_wb_wb),
        .i_mem_wb_wb     (i_id_reg_wr),
        .i_id_ex_rs      (o_id_ex_rs),
        .i_id_ex_rt      (i_ex_rt),
        .i_ex_mem_addr   (i_mem_wb_addr_wr),
        .i_mem_wb_addr   (i_id_reg_addr_wr),
        .o_sc_data_a_src (i_ex_sc_src_a),
        .o_sc_data_b_src (i_ex_sc_src_b)
    );

    // --------------------------- RISK DETECTION Unit ---------------------------
    risk_detection risk_detection_unit
    (
        .i_if_id_rs    (o_id_rs),
        .i_if_id_rd    (o_id_rd),
        .i_if_id_op    (o_id_op),
        .i_if_id_funct (o_id_funct),
        .i_id_ex_rt    (i_ex_rt),
        .i_id_ex_op    (o_id_ex_op),
        .i_jmp_stop    (o_id_ex_jmp_stop),
        .o_jmp_stop    (i_id_ex_jmp_stop),
        .o_not_load    (i_if_not_load),
        .o_halt        (i_if_halt),
        .o_ctr_reg_src (i_id_ctr_reg_src)
    );

endmodule