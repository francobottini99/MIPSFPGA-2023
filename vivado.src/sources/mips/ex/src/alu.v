`timescale 1ns / 1ps

`include "alu.vh"

module alu
    #(
        parameter IO_BUS_WIDTH  = `DEFAULT_ALU_IO_BUS_WIDTH,
        parameter CTR_BUS_WIDTH = `DEFAULT_ALU_CTR_BUS_WIDTH
    )
    (
        input  [CTR_BUS_WIDTH - 1 : 0] i_ctr_code, 
        input  [IO_BUS_WIDTH - 1 : 0]  i_data_a,
        input  [IO_BUS_WIDTH - 1 : 0]  i_data_b,
        output [IO_BUS_WIDTH - 1 : 0]  o_data
    );
    
    reg[IO_BUS_WIDTH - 1 : 0] result;

    always@(*)
    begin
        case(i_ctr_code)
            `CODE_ALU_EX_SLL   : result = i_data_b << i_data_a;
            `CODE_ALU_EX_SRL   : result = i_data_b >> i_data_a;
            `CODE_ALU_EX_SRA   : result = $signed(i_data_b) >>> i_data_a;
            `CODE_ALU_EX_ADD   : result = $signed(i_data_a) + $signed(i_data_b);
            `CODE_ALU_EX_ADDU  : result = i_data_a + i_data_b;
            `CODE_ALU_EX_SUB   : result = $signed(i_data_a) - $signed(i_data_b);
            `CODE_ALU_EX_SUBU  : result = i_data_a - i_data_b;
            `CODE_ALU_EX_AND   : result = i_data_a & i_data_b;
            `CODE_ALU_EX_OR    : result = i_data_a | i_data_b;
            `CODE_ALU_EX_XOR   : result = i_data_a ^ i_data_b;
            `CODE_ALU_EX_NOR   : result = ~(i_data_a | i_data_b);
            `CODE_ALU_EX_SLT   : result = $signed(i_data_a) < $signed(i_data_b);
            `CODE_ALU_EX_SLLV  : result = i_data_a << i_data_b;
            `CODE_ALU_EX_SRLV  : result = i_data_a >> i_data_b;
            `CODE_ALU_EX_SRAV  : result = $signed(i_data_a) >>> i_data_b;
            `CODE_ALU_EX_SC_B  : result = i_data_b;
            default            : result = {IO_BUS_WIDTH {1'bz}};
        endcase
    end
    
    assign o_data = result; 
    
endmodule