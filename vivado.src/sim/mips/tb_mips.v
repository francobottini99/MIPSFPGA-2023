`timescale 1ns / 1ps

`include "tb.vh"
`include "codes.vh"

module tb_mips;

    localparam PC_BUS_SIZE = 32;
    localparam DATA_BUS_SIZE = 32;
    localparam INSTRUCTION_BUS_SIZE = 32;
    localparam INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES = 4;
    localparam INSTRUCTION_MEMORY_SIZE_IN_WORDS = 64;
    localparam REGISTERS_BANK_SIZE = 32;
    localparam DATA_MEMORY_ADDR_SIZE = 5;

    reg                                                     i_clk;
    reg                                                     i_reset;
    reg                                                     i_enable;
    reg                                                     i_flush;
    reg                                                     i_clear_program;
    reg                                                     i_ins_mem_wr;
    reg  [INSTRUCTION_BUS_SIZE - 1 : 0]                     i_ins;
    wire                                                    o_end_program;
    wire                                                    o_ins_mem_full;
    wire                                                    o_ins_mem_empty;
    wire [REGISTERS_BANK_SIZE * DATA_BUS_SIZE - 1 : 0]      o_registers;
    wire [2**DATA_MEMORY_ADDR_SIZE * DATA_BUS_SIZE - 1 : 0] o_mem_data;

    mips
    #(
        .PC_BUS_SIZE                           (PC_BUS_SIZE),
        .DATA_BUS_SIZE                         (DATA_BUS_SIZE),
        .INSTRUCTION_BUS_SIZE                  (INSTRUCTION_BUS_SIZE),
        .INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES (INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES),
        .INSTRUCTION_MEMORY_SIZE_IN_WORDS      (INSTRUCTION_MEMORY_SIZE_IN_WORDS),
        .REGISTERS_BANK_SIZE                   (REGISTERS_BANK_SIZE),
        .DATA_MEMORY_ADDR_SIZE                 (DATA_MEMORY_ADDR_SIZE)
    )
    dut
    (
        .i_clk           (i_clk),
        .i_reset         (i_reset),
        .i_enable        (i_enable),
        .i_flush         (i_flush),
        .i_clear_program (i_clear_program),
        .i_ins_mem_wr    (i_ins_mem_wr),
        .i_ins           (i_ins),
        .o_end_program   (o_end_program),
        .o_ins_mem_full  (o_ins_mem_full),
        .o_ins_mem_empty (o_ins_mem_empty),
        .o_registers     (o_registers),
        .o_mem_data      (o_mem_data)
    );

    `CLK_TOGGLE(i_clk, `CLK_PERIOD)

    reg [INSTRUCTION_BUS_SIZE - 1 : 0] first_program  [28 : 0];
    reg [INSTRUCTION_BUS_SIZE - 1 : 0] second_program [29 : 0];
    reg [INSTRUCTION_BUS_SIZE - 1 : 0] third_program  [17 : 0];

    reg [2**DATA_MEMORY_ADDR_SIZE * DATA_BUS_SIZE - 1 : 0] mem_last;
    reg [REGISTERS_BANK_SIZE * DATA_BUS_SIZE - 1 : 0]      reg_last;

    initial
    begin
        first_program[0]  = `ADDI(`R4, `R0, 16'd7123);
        first_program[1]  = `ADDI(`R3, `R0, 16'd85);
        first_program[2]  = `ADDU(`R5, `R4, `R3);
        first_program[3]  = `SUBU(`R6, `R4, `R3);
        first_program[4]  = `AND(`R7, `R4, `R3);
        first_program[5]  = `OR(`R8, `R4, `R3);
        first_program[6]  = `XOR(`R9, `R4, `R3);
        first_program[7]  = `NOR(`R10, `R3, `R4);
        first_program[8]  = `SLT(`R11, `R3, `R4);
        first_program[9]  = `SLL(`R12, `R10, 5'd2);
        first_program[10] = `SRL(`R13, `R10, 5'd2);
        first_program[11] = `SRA(`R14, `R10, 5'd2);
        first_program[12] = `SLLV(`R15, `R10, `R11);
        first_program[13] = `SRLV(`R16, `R10, `R11);
        first_program[14] = `SRAV(`R17, `R10, `R11);
        first_program[15] = `SB(`R13, `R0, 16'd4);
        first_program[16] = `SH(`R13, `R0, 16'd8);
        first_program[17] = `SW(`R13, `R0, 16'd12);
        first_program[18] = `LB(`R18, `R0, 16'd12);
        first_program[19] = `ANDI(`R19, `R18, 16'd6230);
        first_program[20] = `LH(`R20, `R0, 16'd12);
        first_program[21] = `ORI(`R21, `R20, 16'd6230);
        first_program[22] = `LW(`R22, `R0, 16'd12);
        first_program[23] = `XORI(`R23, `R22, 16'd6230);
        first_program[24] = `LWU(`R24, `R0, 16'd12);
        first_program[25] = `LUI(`R25, 16'd6230);
        first_program[26] = `LBU(`R26, `R0, 16'd12);
        first_program[27] = `SLTI(`R27, `R19, 16'd22614);
        first_program[28] = `HALT;
    end

    initial
    begin
        second_program[0]  = `J(26'd5);
        second_program[1]  = `ADDI(`R3, `R0, 16'd85);
        second_program[2]  = `NOP;
        second_program[3]  = `NOP;
        second_program[4]  = `NOP;
        second_program[5]  = `JAL(26'd8);
        second_program[6]  = `ADDI(`R4, `R0, 16'd95);
        second_program[7]  = `NOP;
        second_program[8]  = `ADDI(`R5, `R0, 16'd56);
        second_program[9]  = `JR(`R5);
        second_program[10] = `ADDI(`R2, `R0, 16'd2);
        second_program[11] = `NOP;
        second_program[12] = `NOP;
        second_program[13] = `NOP;
        second_program[14] = `ADDI(`R6, `R0, 16'd80);
        second_program[15] = `JALR(`R6);
        second_program[16] = `ADDI(`R1, `R0, 16'd10);
        second_program[17] = `NOP;
        second_program[18] = `NOP;
        second_program[19] = `NOP;
        second_program[20] = `ADDI(`R7, `R0, 16'd15);
        second_program[21] = `ADDI(`R8, `R0, 16'd8);
        second_program[22] = `ADDI(`R8, `R8, 16'd1);
        second_program[23] = `SW(`R7, `R8, 16'd0);
        second_program[24] = `BNE(`R8, `R7, -16'd3);
        second_program[25] = `BEQ(`R8, `R7, 16'd2);
        second_program[26] = `ADDI(`R9, `R0, 16'd8);
        second_program[27] = `ADDI(`R10, `R0, 16'd8);
        second_program[28] = `ADDI(`R11, `R0, 16'd8);
        second_program[29] = `HALT;
    end

    initial
    begin
        third_program[0]  = `ADDI(`R3, `R0, 16'd85);
        third_program[1]  = `JAL(26'd14);
        third_program[2]  = `ADDI(`R4, `R0, 16'd86);
        third_program[3]  = `J(26'd16);
        third_program[4]  = `NOP;
        third_program[5]  = `NOP;
        third_program[6]  = `NOP;
        third_program[7]  = `NOP;
        third_program[8]  = `NOP;
        third_program[9]  = `NOP;
        third_program[10] = `NOP;
        third_program[11] = `NOP;
        third_program[12] = `NOP;
        third_program[13] = `NOP;
        third_program[14] = `ADDI(`R5, `R0, 16'd87);
        third_program[15] = `JALR(`R31);
        third_program[16] = `ADDI(`R6, `R0, 16'd88);
        third_program[17] = `HALT;
    end
    
    integer i, j;

    initial 
    begin
        $srandom(61981512);
        
        i_reset         = 1'b1;
        i_enable        = 1'b0;
        i_flush         = 1'b0;
        i_ins_mem_wr    = 1'b0;
        i_clear_program = 1'b0;
        

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_reset = 0;

        i = 0;
        j = 1;

        repeat(29)
        begin
                                        i_ins        = first_program[i];
                                        i_ins_mem_wr = 1'b1;
            `TICKS_DELAY_1(`CLK_PERIOD) i_ins_mem_wr = 1'b0;
                                        i            = i + 1;  
        end

        $display("\n----------------------------------- FIRST  PROGRAM -----------------------------------\n");

        i_enable = 1'b1;
   
        `TICKS_DELAY(`CLK_PERIOD, 100);

        i_clear_program = 1'b1;
        i_enable        = 1'b0;
        i_flush         = 1'b1;
        i_ins_mem_wr    = 1'b0;

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_clear_program = 1'b0; i_flush = 1'b0;

        i = 0;
        j = 1;

        repeat(30)
        begin
                                        i_ins        = second_program[i];
                                        i_ins_mem_wr = 1'b1;
            `TICKS_DELAY_1(`CLK_PERIOD) i_ins_mem_wr = 1'b0;
                                        i            = i + 1;  
        end

        $display("\n----------------------------------- SECOND PROGRAM -----------------------------------\n");

        i_enable = 1'b1;
         
        `TICKS_DELAY(`CLK_PERIOD, 100);

        i_clear_program = 1'b1;
        i_enable        = 1'b0;
        i_flush         = 1'b1;
        i_ins_mem_wr    = 1'b0;

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_clear_program = 1'b0; i_flush = 1'b0;

        i = 0;
        j = 1;

        repeat(18)
        begin
                                        i_ins        = third_program[i];
                                        i_ins_mem_wr = 1'b1;
            `TICKS_DELAY_1(`CLK_PERIOD) i_ins_mem_wr = 1'b0;
                                        i            = i + 1;  
        end

        $display("\n----------------------------------- THIRD  PROGRAM -----------------------------------\n");

        i_enable = 1'b1;

        `TICKS_DELAY(`CLK_PERIOD, 100);

        $display("\n--------------------------------------------------------------------------------------\n");

        $finish;
    end
        
    always @(posedge i_clk)
    begin
        if (i_reset || i_flush)
            begin
                for (i = 0; i < REGISTERS_BANK_SIZE; i = i + 1)
                    `GET_REG(reg_last, i) = 0;

                for (i = 0; i < 2**DATA_MEMORY_ADDR_SIZE; i = i + 1)
                    `GET_MEM(mem_last, i) = 0;
            end
        else if (i_enable)
           begin
                for (i = 0; i < REGISTERS_BANK_SIZE; i = i + 1)
                    if (`GET_REG(o_registers, i) != `GET_REG(reg_last, i))
                        begin
                            $display("[Cicle %d] R %d  | %h | -> | %h |", j, i, `GET_REG(reg_last, i), `GET_REG(o_registers, i));
                            `GET_REG(reg_last, i) = `GET_REG(o_registers, i);
                        end
                
                for (i = 0; i < 2**DATA_MEMORY_ADDR_SIZE; i = i + 1)
                    if (`GET_MEM(o_mem_data, i) != `GET_MEM(mem_last, i))
                        begin
                            $display("[Cicle %d] M(%d) | %h | -> | %h |", j, i, `GET_MEM(mem_last, i), `GET_MEM(o_mem_data, i));
                            `GET_MEM(mem_last, i) = `GET_MEM(o_mem_data, i);
                        end
                
                j = j + 1;
            end
    end
endmodule