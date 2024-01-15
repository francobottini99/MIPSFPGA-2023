`timescale 1ns / 1ps

`include "alu_control.vh"

module alu_control
    #(
        parameter ALU_CTR_BUS_WIDTH   = `DEFAULT_ALU_CTR_BUS_WIDTH,
        parameter ALU_OP_BUS_WIDTH    = `DEFAULT_ALU_OP_BUS_WIDTH,
        parameter ALU_FUNCT_BUS_WIDTH = `DEFAULT_ALU_FUNCT_BUS_WIDTH
    )
    (
        input  wire [ALU_FUNCT_BUS_WIDTH - 1 : 0] i_funct,
        input  wire [ALU_OP_BUS_WIDTH - 1 : 0]    i_alu_op,
        output wire [ALU_CTR_BUS_WIDTH - 1 : 0]   o_alu_ctr
    );

    reg [ALU_CTR_BUS_WIDTH - 1 : 0] alu_ctr;

    always@(*)
    begin
        case(i_alu_op)
            `CODE_ALU_CTR_R_TYPE:
                case(i_funct)
                    `CODE_FUNCT_SLL  : alu_ctr = `CODE_ALU_EX_SLL;
                    `CODE_FUNCT_SRL  : alu_ctr = `CODE_ALU_EX_SRL;
                    `CODE_FUNCT_SRA  : alu_ctr = `CODE_ALU_EX_SRA;
                    `CODE_FUNCT_ADD  : alu_ctr = `CODE_ALU_EX_ADD;
                    `CODE_FUNCT_ADDU : alu_ctr = `CODE_ALU_EX_ADDU;
                    `CODE_FUNCT_SUB  : alu_ctr = `CODE_ALU_EX_SUB;
                    `CODE_FUNCT_SUBU : alu_ctr = `CODE_ALU_EX_SUBU;
                    `CODE_FUNCT_AND  : alu_ctr = `CODE_ALU_EX_AND;
                    `CODE_FUNCT_OR   : alu_ctr = `CODE_ALU_EX_OR;
                    `CODE_FUNCT_XOR  : alu_ctr = `CODE_ALU_EX_XOR;
                    `CODE_FUNCT_NOR  : alu_ctr = `CODE_ALU_EX_NOR;
                    `CODE_FUNCT_SLT  : alu_ctr = `CODE_ALU_EX_SLT;
                    `CODE_FUNCT_SLLV : alu_ctr = `CODE_ALU_EX_SLLV;
                    `CODE_FUNCT_SRLV : alu_ctr = `CODE_ALU_EX_SRLV;
                    `CODE_FUNCT_SRAV : alu_ctr = `CODE_ALU_EX_SRAV;
                    `CODE_FUNCT_JALR : alu_ctr = `CODE_ALU_EX_SC_B;
                    default          : alu_ctr = `CODE_ALU_EX_NOP;
                endcase
            
            `CODE_ALU_CTR_LOAD_TYPE   |
            `CODE_ALU_CTR_STORE_TYPE  |
            `CODE_ALU_CTR_ADDI        : 
                alu_ctr = `CODE_ALU_EX_ADD;
            `CODE_ALU_CTR_JUMP_TYPE   : alu_ctr = `CODE_ALU_EX_SC_B;
            `CODE_ALU_CTR_ANDI        : alu_ctr = `CODE_ALU_EX_AND;
            `CODE_ALU_CTR_ORI         : alu_ctr = `CODE_ALU_EX_OR;
            `CODE_ALU_CTR_XORI        : alu_ctr = `CODE_ALU_EX_XOR;
            `CODE_ALU_CTR_SLTI        : alu_ctr = `CODE_ALU_EX_SLT;
            default                   : alu_ctr = `CODE_ALU_EX_NOP;
        endcase


    end

    assign o_alu_ctr = alu_ctr;

endmodule