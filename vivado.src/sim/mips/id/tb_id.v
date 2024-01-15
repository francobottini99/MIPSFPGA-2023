`timescale 1ns / 1ps

`include "tb.vh"

module tb_id;

    localparam REGISTERS_BANK_SIZE   = 32;
    localparam PC_SIZE               = 32;
    localparam BUS_SIZE              = 32;
    
    // Señales de reloj y reset
    reg                                           i_clk;
    reg                                           i_reset;
    reg                                           i_flush;
    // Señales de control de entrada    
    reg                                           i_reg_write_enable;
    reg                                           i_ctr_reg_src;
    // Señales de datos de entrada    
    reg [$clog2(REGISTERS_BANK_SIZE) - 1 : 0]     i_reg_addr_wr;
    reg [BUS_SIZE - 1 : 0]                        i_reg_bus_wr;
    reg [BUS_SIZE - 1 : 0]                        i_instruction;
    reg [BUS_SIZE - 1 : 0]                        i_ex_bus_a;
    reg [BUS_SIZE - 1 : 0]                        i_ex_bus_b;
    reg [PC_SIZE - 1 : 0]                         i_next_seq_pc;
    // Señales de control de salida    
    wire                                          o_next_pc_src;
    wire [2 : 0]                                  o_mem_rd_src;
    wire [1 : 0]                                  o_mem_wr_src;
    wire                                          o_mem_write;
    wire                                          o_wb;
    wire                                          o_mem_to_reg;
    wire [1 : 0]                                  o_reg_dst;
    wire                                          o_alu_src_a;
    wire [2 : 0]                                  o_alu_src_b;
    wire [2 : 0]                                  o_alu_op;
    // Señales de datos de salida    
    wire [BUS_SIZE - 1 : 0]                       o_bus_a;
    wire [BUS_SIZE - 1 : 0]                       o_bus_b;
    wire [PC_SIZE - 1 : 0]                        o_next_not_seq_pc;
    wire [4 : 0]                                  o_rs;
    wire [4 : 0]                                  o_rt;
    wire [4 : 0]                                  o_rd;
    wire [5 : 0]                                  o_funct;
    wire [5 : 0]                                  o_op;
    wire [BUS_SIZE - 1 : 0]                       o_shamt_ext_unsigned;
    wire [BUS_SIZE - 1 : 0]                       o_inm_ext_signed;
    wire [BUS_SIZE - 1 : 0]                       o_inm_upp;
    wire [BUS_SIZE - 1 : 0]                       o_inm_ext_unsigned;
    // Señales de depuración
    wire [REGISTERS_BANK_SIZE * BUS_SIZE - 1 : 0] o_bus_debug;

    // Instancia del módulo
    id
    #(
        .REGISTERS_BANK_SIZE (REGISTERS_BANK_SIZE),
        .PC_SIZE             (PC_SIZE),
        .BUS_SIZE            (BUS_SIZE)
    ) 
    dut
    (
        .i_clk                (i_clk),
        .i_reset              (i_reset),
        .i_flush              (i_flush),
        .i_reg_write_enable   (i_reg_write_enable),
        .i_ctr_reg_src        (i_ctr_reg_src),
        .i_reg_addr_wr        (i_reg_addr_wr),
        .i_reg_bus_wr         (i_reg_bus_wr),
        .i_instruction        (i_instruction),
        .i_ex_bus_a           (i_ex_bus_a),
        .i_ex_bus_b           (i_ex_bus_b),
        .i_next_seq_pc        (i_next_seq_pc),
        .o_next_pc_src        (o_next_pc_src),
        .o_mem_rd_src         (o_mem_rd_src),
        .o_mem_wr_src         (o_mem_wr_src),
        .o_mem_write          (o_mem_write),
        .o_wb                 (o_wb),
        .o_mem_to_reg         (o_mem_to_reg),
        .o_reg_dst            (o_reg_dst),
        .o_alu_src_a          (o_alu_src_a),
        .o_alu_src_b          (o_alu_src_b),
        .o_alu_op             (o_alu_op),
        .o_bus_a              (o_bus_a),
        .o_bus_b              (o_bus_b),
        .o_next_not_seq_pc    (o_next_not_seq_pc),
        .o_rs                 (o_rs),
        .o_rt                 (o_rt),
        .o_rd                 (o_rd),
        .o_funct              (o_funct),
        .o_op                 (o_op),
        .o_shamt_ext_unsigned (o_shamt_ext_unsigned),
        .o_inm_ext_signed     (o_inm_ext_signed),
        .o_inm_upp            (o_inm_upp),
        .o_inm_ext_unsigned   (o_inm_ext_unsigned),
        .o_bus_debug          (o_bus_debug)
    );

    `CLK_TOGGLE(i_clk, `CLK_PERIOD)
    
    reg [5:0]              instructions [19:0];
    reg [5:0]              functs       [16:0];
    reg [19:0]             valid_out;

    reg [BUS_SIZE - 1 : 0] shamt_ext_unsigned;
    reg [BUS_SIZE - 1 : 0] inm_ext_signed;
    reg [BUS_SIZE - 1 : 0] inm_upp;
    reg [BUS_SIZE - 1 : 0] inm_ext_unsigned;

    integer i = 0;
    integer j = 0;

    initial
    begin
        instructions[0]  = `CODE_OP_R_TYPE;
        instructions[1]  = `CODE_OP_BEQ;
        instructions[2]  = `CODE_OP_BNE;
        instructions[3]  = `CODE_OP_J;
        instructions[4]  = `CODE_OP_JAL;
        instructions[5]  = `CODE_OP_LB;
        instructions[6]  = `CODE_OP_LH;
        instructions[7]  = `CODE_OP_LW;
        instructions[8]  = `CODE_OP_LWU;
        instructions[9]  = `CODE_OP_LBU;
        instructions[10] = `CODE_OP_LHU;
        instructions[11] = `CODE_OP_SB;
        instructions[12] = `CODE_OP_SH;
        instructions[13] = `CODE_OP_SW;
        instructions[14] = `CODE_OP_ADDI;
        instructions[15] = `CODE_OP_ANDI;
        instructions[16] = `CODE_OP_ORI;
        instructions[17] = `CODE_OP_XORI;
        instructions[18] = `CODE_OP_LUI;
        instructions[19] = `CODE_OP_SLTI;

        functs[0]  = `CODE_FUNCT_JR;
        functs[1]  = `CODE_FUNCT_JALR;
        functs[2]  = `CODE_FUNCT_SLL;
        functs[3]  = `CODE_FUNCT_SRL;
        functs[4]  = `CODE_FUNCT_SRA;
        functs[5]  = `CODE_FUNCT_ADD;
        functs[6]  = `CODE_FUNCT_ADDU;
        functs[7]  = `CODE_FUNCT_SUB;
        functs[8]  = `CODE_FUNCT_SUBU;
        functs[9]  = `CODE_FUNCT_AND;
        functs[10] = `CODE_FUNCT_OR;
        functs[11] = `CODE_FUNCT_XOR;
        functs[12] = `CODE_FUNCT_NOR;
        functs[13] = `CODE_FUNCT_SLT;
        functs[14] = `CODE_FUNCT_SLLV;
        functs[15] = `CODE_FUNCT_SRLV;
        functs[16] = `CODE_FUNCT_SRAV;
    end
    
    task automatic set_valid_out();
        if (i_instruction != `INSTRUCTION_NOP)
            case (instructions[i])
                `CODE_OP_R_TYPE :
                    case (functs[j])
                        `CODE_FUNCT_JR    : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_REG, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_NOTHING, `CODE_ALU_CTR_SRC_B_NOTHING,     `CODE_ALU_CTR_R_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING    };
                        `CODE_FUNCT_JALR  : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_REG, `CODE_MAIN_CTR_REG_DST_GPR_31,  `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_NEXT_SEQ_PC, `CODE_ALU_CTR_R_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                        `CODE_FUNCT_SLL   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,     `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_DST_RD,      `CODE_ALU_CTR_SRC_A_SHAMT,   `CODE_ALU_CTR_SRC_B_BUS_B,       `CODE_ALU_CTR_R_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                        `CODE_FUNCT_SRL   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,     `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_DST_RD,      `CODE_ALU_CTR_SRC_A_SHAMT,   `CODE_ALU_CTR_SRC_B_BUS_B,       `CODE_ALU_CTR_R_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                        `CODE_FUNCT_SRA   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,     `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_DST_RD,      `CODE_ALU_CTR_SRC_A_SHAMT,   `CODE_ALU_CTR_SRC_B_BUS_B,       `CODE_ALU_CTR_R_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                        default           : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,     `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_DST_RD,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_BUS_B,       `CODE_ALU_CTR_R_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                    endcase
                `CODE_OP_LW   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_LOAD_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_WORD,          `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT };
                `CODE_OP_SW   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_STORE_TYPE,  `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_WORD,     `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING    };
                `CODE_OP_BEQ  : valid_out = {  i_ex_bus_a == i_ex_bus_b ? { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_BRANCH } : { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP }, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_NOTHING, `CODE_ALU_CTR_SRC_B_NOTHING,     `CODE_ALU_CTR_BRANCH_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING    };
                `CODE_OP_BNE  : valid_out = {  i_ex_bus_a != i_ex_bus_b ? { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_BRANCH } : { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP }, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_NOTHING, `CODE_ALU_CTR_SRC_B_NOTHING,     `CODE_ALU_CTR_BRANCH_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING    };
                `CODE_OP_ADDI : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_ADDI,        `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_J    : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ,  `CODE_MAIN_CTR_JMP_DIR,                                                                                               `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_NOTHING, `CODE_ALU_CTR_SRC_B_NOTHING,     `CODE_ALU_CTR_JUMP_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING    };
                `CODE_OP_JAL  : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ,  `CODE_MAIN_CTR_JMP_DIR,                                                                                                `CODE_MAIN_CTR_REG_DST_GPR_31,  `CODE_ALU_CTR_SRC_A_NOTHING, `CODE_ALU_CTR_SRC_B_NEXT_SEQ_PC, `CODE_ALU_CTR_JUMP_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_ANDI : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_USIG_INM,    `CODE_ALU_CTR_ANDI,        `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_ORI  : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_USIG_INM,    `CODE_ALU_CTR_ORI,         `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_XORI : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_USIG_INM,    `CODE_ALU_CTR_XORI,        `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_SLTI : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_SLTI,        `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_LUI  : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_UPPER_INM,   `CODE_ALU_CTR_LOAD_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_LB   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_LOAD_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_SIG_BYTE,      `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT };
                `CODE_OP_LBU  : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_LOAD_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_USIG_BYTE,     `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT };
                `CODE_OP_LH   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_LOAD_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_SIG_HALFWORD,  `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT };
                `CODE_OP_LHU  : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_LOAD_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_USIG_HALFWORD, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT };
                `CODE_OP_LWU  : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_LOAD_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_WORD,          `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT };
                `CODE_OP_SB   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_STORE_TYPE,  `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_BYTE,     `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING    };
                `CODE_OP_SH   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_STORE_TYPE,  `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_HALFWORD, `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING    };
                default       : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                                `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_NOTHING, `CODE_ALU_CTR_SRC_B_NOTHING,     `CODE_ALU_CTR_UNDEFINED ,  `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING    };
            endcase
        else
            valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_NOTHING, `CODE_ALU_CTR_SRC_B_NOTHING, `CODE_ALU_CTR_UNDEFINED, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING };
    endtask

    initial 
    begin
        $srandom(99595291);

        i_reset = 1;
        i_flush = 0;
        i_reg_write_enable = 0;
        i_ctr_reg_src = 0;
        i_reg_addr_wr = 0;
        i_reg_bus_wr = 0;
        i_instruction = 0;
        i_next_seq_pc = 0;
        i_ex_bus_a    = 0;
        i_ex_bus_b    = 0;

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_reset = 0;

        repeat (20)
        begin
            if (i == 0)
                begin
                    repeat (17) 
                    begin
                        i_instruction = $urandom; 
                        i_instruction = { instructions[i], i_instruction[19:0] , functs[j] };

                        shamt_ext_unsigned = { { 27 { 1'b0 } }, i_instruction[10:6] };  
                        inm_ext_signed = { { 16 { i_instruction[15] } }, i_instruction[15:0] };
                        inm_upp = (inm_ext_signed << 16);
                        inm_ext_unsigned = { { 16 { 1'b0 } }, i_instruction[15:0] };
                        
                        set_valid_out();
                        
                        `TICKS_DELAY_1(`CLK_PERIOD);

                        if (o_rs               === i_instruction[25:21] && o_rt                 === i_instruction[20:16] && 
                            o_rd               === i_instruction[15:11] && o_funct              === i_instruction[5:0]   && 
                            o_op               === i_instruction[31:26] &&
                            o_inm_ext_unsigned === inm_ext_unsigned     && o_shamt_ext_unsigned === shamt_ext_unsigned   && 
                            o_inm_upp          === inm_upp              && o_inm_ext_signed     === inm_ext_signed       && 
                            o_next_pc_src      === valid_out[19]        && o_reg_dst            === valid_out[16:15]     && 
                            o_alu_src_a        === valid_out[14]        && o_alu_src_b          === valid_out[13:11]     &&
                            o_alu_op           === valid_out[10:8]      && o_mem_rd_src         === valid_out[7:5]       &&
                            o_mem_wr_src       === valid_out[4:3]       && o_mem_write          === valid_out[2]         && 
                            o_wb               === valid_out[1]         && o_mem_to_reg         === valid_out[0])
                            $display("TEST %0d - %0d PASS", i, j);
                        else
                            begin
                                $display("/* --------------------------------------------------------------------------------");
                                $display("/* TEST %0d - %0d ERROR", i, j);
                                $display("/* ");
                                $display("/* Valid_reg_out             : %b", { valid_out[19], valid_out[16:0] });
                                $display("/* Obtain_reg_out            : %b", { o_next_pc_src, o_reg_dst, o_alu_src_a, o_alu_src_b, o_alu_op, o_mem_rd_src, o_mem_wr_src, o_mem_write, o_wb, o_mem_to_reg });
                                $display("/* ");
                                $display("/* Valid_rs                  : %b", i_instruction[25:21]);
                                $display("/* Obtain_rs                 : %b", o_rs);
                                $display("/* ");
                                $display("/* Valid_rt                  : %b", i_instruction[20:16]);
                                $display("/* Obtain_rt                 : %b", o_rt);
                                $display("/* ");
                                $display("/* Valid_rd                  : %b", i_instruction[15:11]);
                                $display("/* Obtain_rd                 : %b", o_rd);
                                $display("/* ");
                                $display("/* Valid_funct               : %b", i_instruction[5:0]);
                                $display("/* Obtain_funct              : %b", o_funct);
                                $display("/* ");
                                $display("/* Valid_op                  : %b", i_instruction[31:26]);
                                $display("/* Obtain_op                 : %b", o_op);
                                $display("/* ");
                                $display("/* Valid_imm_ext_signed      : %b", inm_ext_signed);
                                $display("/* Obtain_imm_ext_signed     : %b", o_inm_ext_signed);
                                $display("/* ");
                                $display("/* Valid_imm_ext_unsigned    : %b", inm_ext_unsigned);
                                $display("/* Obtain_imm_ext_unsigned   : %b", o_inm_ext_unsigned);
                                $display("/* ");
                                $display("/* Valid_shamt_ext_unsigned  : %b", shamt_ext_unsigned);
                                $display("/* Obtain_shamt_ext_unsigned : %b", o_shamt_ext_unsigned);
                                $display("/* ");
                                $display("/* Valid_inm_upp             : %b", inm_upp);
                                $display("/* Obtain_inm_upp            : %b", o_inm_upp);
                                $display("/* --------------------------------------------------------------------------------");
                            end

                        i_next_seq_pc = i_next_seq_pc + 4; 
 
                        j = j + 1; 
                    end
                end
            else
                begin
                    i_instruction = $urandom;
                    i_instruction = { instructions[i], i_instruction[25:0]};

                    shamt_ext_unsigned = { { 27 { 1'b0 } }, i_instruction[10:6] };  
                    inm_ext_signed = { { 16 { i_instruction[15] } }, i_instruction[15:0] };
                    inm_upp = (inm_ext_signed << 16);
                    inm_ext_unsigned = { { 16 { 1'b0 } }, i_instruction[15:0] };
                    
                    set_valid_out();
                    
                    `TICKS_DELAY_1(`CLK_PERIOD);

                        if (o_rs               === i_instruction[25:21] && o_rt                 === i_instruction[20:16] && 
                            o_rd               === i_instruction[15:11] && o_funct              === i_instruction[5:0]   && 
                            o_op               === i_instruction[31:26] &&
                            o_inm_ext_unsigned === inm_ext_unsigned     && o_shamt_ext_unsigned === shamt_ext_unsigned   && 
                            o_inm_upp          === inm_upp              && o_inm_ext_signed     === inm_ext_signed       && 
                            o_next_pc_src      === valid_out[19]        && o_reg_dst            === valid_out[16:15]     && 
                            o_alu_src_a        === valid_out[14]        && o_alu_src_b          === valid_out[13:11]     &&
                            o_alu_op           === valid_out[10:8]      && o_mem_rd_src         === valid_out[7:5]       &&
                            o_mem_wr_src       === valid_out[4:3]       && o_mem_write          === valid_out[2]         && 
                            o_wb               === valid_out[1]         && o_mem_to_reg         === valid_out[0])
                        $display("TEST %0d PASS", i);
                    else
                        begin
                            $display("/* --------------------------------------------------------------------------------");
                            $display("/* TEST %0d ERROR", i);
                            $display("/* ");
                            $display("/* Valid_reg_out             : %b", { valid_out[19], valid_out[16:0] });
                            $display("/* Obtain_reg_out            : %b", { o_next_pc_src, o_reg_dst, o_alu_src_a, o_alu_src_b, o_alu_op, o_mem_rd_src, o_mem_wr_src, o_mem_write, o_wb, o_mem_to_reg });
                            $display("/* ");
                            $display("/* Valid_rs                  : %b", i_instruction[25:21]);
                            $display("/* Obtain_rs                 : %b", o_rs);
                            $display("/* ");
                            $display("/* Valid_rt                  : %b", i_instruction[20:16]);
                            $display("/* Obtain_rt                 : %b", o_rt);
                            $display("/* ");
                            $display("/* Valid_rd                  : %b", i_instruction[15:11]);
                            $display("/* Obtain_rd                 : %b", o_rd);
                            $display("/* ");
                            $display("/* Valid_funct               : %b", i_instruction[5:0]);
                            $display("/* Obtain_funct              : %b", o_funct);
                            $display("/* ");
                            $display("/* Valid_op                  : %b", i_instruction[31:26]);
                            $display("/* Obtain_op                 : %b", o_op);
                            $display("/* ");
                            $display("/* Valid_imm_ext_signed      : %b", inm_ext_signed);
                            $display("/* Obtain_imm_ext_signed     : %b", o_inm_ext_signed);
                            $display("/* ");
                            $display("/* Valid_imm_ext_unsigned    : %b", inm_ext_unsigned);
                            $display("/* Obtain_imm_ext_unsigned   : %b", o_inm_ext_unsigned);
                            $display("/* ");
                            $display("/* Valid_shamt_ext_unsigned  : %b", shamt_ext_unsigned);
                            $display("/* Obtain_shamt_ext_unsigned : %b", o_shamt_ext_unsigned);
                            $display("/* ");
                            $display("/* Valid_inm_upp             : %b", inm_upp);
                            $display("/* Obtain_inm_upp            : %b", o_inm_upp);
                            $display("/* --------------------------------------------------------------------------------");
                        end

                    i_next_seq_pc = i_next_seq_pc + 4;
                end

            i = i + 1;
        end

        $finish;
    end

endmodule
