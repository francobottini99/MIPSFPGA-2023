`timescale 1ns / 1ps

`include "tb.vh"
`include "codes.vh"

module tb_alu_control;

    parameter ALU_CTR_BUS_WIDTH   = 4; 
    parameter ALU_OP_BUS_WIDTH    = 3;
    parameter ALU_FUNCT_BUS_WIDTH = 6;

    reg  [ALU_FUNCT_BUS_WIDTH - 1 : 0] i_funct;
    reg  [ALU_OP_BUS_WIDTH - 1 : 0]    i_alu_op;
    wire [ALU_CTR_BUS_WIDTH - 1 : 0]   o_alu_ctr;

    alu_control 
    #(
        .ALU_CTR_BUS_WIDTH   (ALU_CTR_BUS_WIDTH),
        .ALU_OP_BUS_WIDTH    (ALU_OP_BUS_WIDTH),
        .ALU_FUNCT_BUS_WIDTH (ALU_FUNCT_BUS_WIDTH)
    ) 
    dut 
    (
        .i_funct   (i_funct),
        .i_alu_op  (i_alu_op),
        .o_alu_ctr (o_alu_ctr)
    );

    initial
    begin
        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_JR;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_NOP)
            $display("TEST JR     PASSED");
        else
            $display("TEST JR     ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_JALR;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_SC_B)
            $display("TEST JALR   PASSED");
        else
            $display("TEST JALR   ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_SLL;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_SLL)
            $display("TEST SLL    PASSED");
        else
            $display("TEST SLL    ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_SRL;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_SRL)
            $display("TEST SRL    PASSED");
        else
            $display("TEST SRL    ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_SRA;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_SRA)
            $display("TEST SRA    PASSED");
        else
            $display("TEST SRA    ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_ADD;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_ADD)
            $display("TEST ADD    PASSED");
        else
            $display("TEST ADD    ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_ADDU;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_ADDU)
            $display("TEST ADDU   PASSED");
        else
            $display("TEST ADDU   ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_SUB;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_SUB)
            $display("TEST SUB    PASSED");
        else
            $display("TEST SUB    ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_SUBU;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_SUBU)
            $display("TEST SUBU   PASSED");
        else
            $display("TEST SUBU   ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_AND;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_AND)
            $display("TEST AND    PASSED");
        else
            $display("TEST AND    ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_OR;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_OR)
            $display("TEST OR     PASSED");
        else
            $display("TEST OR     ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_XOR;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_XOR)
            $display("TEST XOR    PASSED");
        else
            $display("TEST XOR    ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_NOR;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_NOR)
            $display("TEST NOR    PASSED");
        else
            $display("TEST NOR    ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_SLT;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_SLT)
            $display("TEST SLT    PASSED");
        else
            $display("TEST SLT    ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_SLLV;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_SLLV)
            $display("TEST SLLV   PASSED");
        else
            $display("TEST SLLV   ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_SRLV;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_SRLV)
            $display("TEST SRLV   PASSED");
        else
            $display("TEST SRLV   ERROR");

        i_alu_op = `CODE_ALU_CTR_R_TYPE;
        i_funct  = `CODE_FUNCT_SRAV;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_SRAV)
            $display("TEST SRAV   PASSED");
        else
            $display("TEST SRAV   ERROR");

        i_funct = 0;

        i_alu_op = `CODE_ALU_CTR_LOAD_TYPE;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_ADD)
            $display("TEST LOAD   PASSED");
        else
            $display("TEST LOAD   ERROR");

        i_alu_op = `CODE_ALU_CTR_STORE_TYPE;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_ADD)
            $display("TEST STORE  PASSED");
        else
            $display("TEST STORE  ERROR");

        i_alu_op = `CODE_ALU_CTR_BRANCH_TYPE;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_NOP)
            $display("TEST BRANCH PASSED");
        else
            $display("TEST BRANCH ERROR");

        i_alu_op = `CODE_ALU_CTR_ADDI;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_ADD)
            $display("TEST ADDI   PASSED");
        else
            $display("TEST ADDI   ERROR");

        i_alu_op = `CODE_ALU_CTR_ANDI;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_AND)
            $display("TEST ANDI   PASSED");
        else
            $display("TEST ANDI   ERROR");

        i_alu_op = `CODE_ALU_CTR_ORI;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_OR)
            $display("TEST ORI    PASSED");
        else
            $display("TEST ORI    ERROR");

        i_alu_op = `CODE_ALU_CTR_XORI;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_XOR)
            $display("TEST XORI   PASSED");
        else
            $display("TEST XORI   ERROR");

        i_alu_op = `CODE_ALU_CTR_SLTI;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_SLT)
            $display("TEST SLTI   PASSED");
        else
            $display("TEST SLTI   ERROR");

        i_alu_op = `CODE_ALU_CTR_JUMP_TYPE;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_SC_B)
            $display("TEST JUMP   PASSED");
        else
            $display("TEST JUMP   ERROR");

        i_alu_op = `CODE_ALU_CTR_UNDEFINED;
        #10;
        if (o_alu_ctr === `CODE_ALU_EX_NOP)
            $display("TEST UND    PASSED");
        else
            $display("TEST UND    ERROR");

        $finish;

    end

endmodule