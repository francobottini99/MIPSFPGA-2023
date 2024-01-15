`ifndef __TB_VH__
`define __TB_VH__
    `include "common.vh"
    
    `define CLK_PERIOD       10

    `define CLK_TOGGLE(clk, period) \
        initial clk = 0; \
        always #(period / 2) clk = ~clk;
    
    `define TICKS_DELAY(clk_period, ticks) #(ticks * clk_period)
    
    `define TICKS_DELAY_1(clk_period)  `TICKS_DELAY(clk_period, 1)
    `define TICKS_DELAY_5(clk_period)  `TICKS_DELAY(clk_period, 5)
    `define TICKS_DELAY_10(clk_period) `TICKS_DELAY(clk_period, 10)
    
    `define RANDOM_TICKS_DELAY(clk_period, max_ticks) \
        #(($urandom_range(max_ticks - 1) + 1) * clk_period)

    `define RANDOM_TICKS_DELAY_MAX_10(clk_period) `RANDOM_TICKS_DELAY(clk_period, 10)
    `define RANDOM_TICKS_DELAY_MAX_20(clk_period) `RANDOM_TICKS_DELAY(clk_period, 20)
    `define RANDOM_TICKS_DELAY_MAX_30(clk_period) `RANDOM_TICKS_DELAY(clk_period, 30)

    // Registers

    `define R0  5'b00000
    `define R1  5'b00001
    `define R2  5'b00010
    `define R3  5'b00011
    `define R4  5'b00100
    `define R5  5'b00101
    `define R6  5'b00110
    `define R7  5'b00111
    `define R8  5'b01000
    `define R9  5'b01001
    `define R10 5'b01010
    `define R11 5'b01011
    `define R12 5'b01100
    `define R13 5'b01101
    `define R14 5'b01110
    `define R15 5'b01111
    `define R16 5'b10000
    `define R17 5'b10001
    `define R18 5'b10010
    `define R19 5'b10011
    `define R20 5'b10100
    `define R21 5'b10101
    `define R22 5'b10110
    `define R23 5'b10111
    `define R24 5'b11000
    `define R25 5'b11001
    `define R26 5'b11010
    `define R27 5'b11011
    `define R28 5'b11100
    `define R29 5'b11101
    `define R30 5'b11110
    `define R31 5'b11111

    // Instruction types

    `define INST_TYPE_R(RS, RT, RD, SHAMT, FUNCT) { `CODE_OP_R_TYPE, RS, RT, RD, SHAMT, FUNCT }
    `define INST_TYPE_I(OPCODE, RS, RT, IMM)      { OPCODE,          RS, RT, IMM }
    `define INST_TYPE_J(OPCODE, ADDR)             { OPCODE,          ADDR }
    `define HALT                                  { 32 { 1'b1 } }
    `define NOP                                   { 32 { 1'b0 } }

    // R-Type instructions

    `define JR(RS1)             `INST_TYPE_R( RS1,      5'b00000, 5'b00000, 5'b00000, `CODE_FUNCT_JR   ) // PC = Rs1
    `define JALR(RS1)           `INST_TYPE_R( RS1,      5'b00000, 5'b00000, 5'b00000, `CODE_FUNCT_JALR ) // R31 = PC + 4; PC = Rs1
    `define SLL(RD, RS2, SHAMT) `INST_TYPE_R( 5'b00000, RS2,      RD,       SHAMT,    `CODE_FUNCT_SLL  ) // Rd = Rs1 << Shamt
    `define SRL(RD, RS2, SHAMT) `INST_TYPE_R( 5'b00000, RS2,      RD,       SHAMT,    `CODE_FUNCT_SRL  ) // Rd = Rs1 >> Shamt
    `define SRA(RD, RS2, SHAMT) `INST_TYPE_R( 5'b00000, RS2,      RD,       SHAMT,    `CODE_FUNCT_SRA  ) // Rd = Rs1 >>> Shamt
    `define ADD(RD, RS1, RS2)   `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_ADD  ) // Rd = Rs1 + Rs2
    `define ADDU(RD, RS1, RS2)  `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_ADDU ) // Rd = Rs1 + Rs2
    `define SUB(RD, RS1, RS2)   `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_SUB  ) // Rd = Rs1 - Rs2
    `define SUBU(RD, RS1, RS2)  `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_SUBU ) // Rd = Rs1 - Rs2
    `define AND(RD, RS1, RS2)   `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_AND  ) // Rd = Rs1 & Rs2
    `define OR(RD, RS1, RS2)    `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_OR   ) // Rd = Rs1 | Rs2
    `define XOR(RD, RS1, RS2)   `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_XOR  ) // Rd = Rs1 ^ Rs2
    `define NOR(RD, RS1, RS2)   `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_NOR  ) // Rd = ~(Rs1 | Rs2)
    `define SLT(RD, RS1, RS2)   `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_SLT  ) // Rd = Rs1 < Rs2
    `define SLLV(RD, RS1, RS2)  `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_SLLV ) // Rd = Rs1 << Rs2
    `define SRLV(RD, RS1, RS2)  `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_SRLV ) // Rd = Rs1 >> Rs2
    `define SRAV(RD, RS1, RS2)  `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_SRAV ) // Rd = Rs1 >>> Rs2

    // I-Type instructions

    `define BEQ(RS1, RS2, INM)  `INST_TYPE_I( `CODE_OP_BEQ,  RS1,      RS2,      INM ) // PC += (Rs1 == Rs2 ? sigextend(Inm) : 0)
    `define BNE(RS1, RS2, INM)  `INST_TYPE_I( `CODE_OP_BNE,  RS1,      RS2,      INM ) // PC += (Rs1 != Rs2 ? sigextend(Inm) : 0)
    `define LB(RD, RS1, INM)    `INST_TYPE_I( `CODE_OP_LB,   RS1,      RD,       INM ) // Rd = sigextend(Mem[Rs1 + unsigextend(Inm)])
    `define LH(RD, RS1, INM)    `INST_TYPE_I( `CODE_OP_LH,   RS1,      RD,       INM ) // Rd = sigextend(Mem[Rs1 + unsigextend(Inm)])
    `define LW(RD, RS1, INM)    `INST_TYPE_I( `CODE_OP_LW,   RS1,      RD,       INM ) // Rd = Mem[Rs1 + unsigextend(Inm)]
    `define LWU(RD, RS1, INM)   `INST_TYPE_I( `CODE_OP_LWU,  RS1,      RD,       INM ) // Rd = Mem[Rs1 + unsigextend(Inm)]
    `define LBU(RD, RS1, INM)   `INST_TYPE_I( `CODE_OP_LBU,  RS1,      RD,       INM ) // Rd = unsigextend(Mem[Rs1 + unsigextend(Inm)])
    `define LHU(RD, RS1, INM)   `INST_TYPE_I( `CODE_OP_LHU,  RS1,      RD,       INM ) // Rd = unsigextend(Mem[Rs1 + unsigextend(Inm)])
    `define SB(RD, RS1, INM)    `INST_TYPE_I( `CODE_OP_SB,   RS1,      RD,       INM ) // Mem[Rs1 + unsigextend(Inm)] = Rd[7:0]
    `define SH(RD, RS1, INM)    `INST_TYPE_I( `CODE_OP_SH,   RS1,      RD,       INM ) // Mem[Rs1 + unsigextend(Inm)] = Rd[15:0]
    `define SW(RD, RS1, INM)    `INST_TYPE_I( `CODE_OP_SW,   RS1,      RD,       INM ) // Mem[Rs1 + unsigextend(Inm)] = Rd[31:0]
    `define ADDI(RD, RS1, INM)  `INST_TYPE_I( `CODE_OP_ADDI, RS1,      RD,       INM ) // Rd = Rs1 + sigextend(Inm)
    `define ANDI(RD, RS1, INM)  `INST_TYPE_I( `CODE_OP_ANDI, RS1,      RD,       INM ) // Rd = Rs1 & Inm
    `define ORI(RD, RS1, INM)   `INST_TYPE_I( `CODE_OP_ORI,  RS1,      RD,       INM ) // Rd = Rs1 | Inm
    `define XORI(RD, RS1, INM)  `INST_TYPE_I( `CODE_OP_XORI, RS1,      RD,       INM ) // Rd = Rs1 ^ Inm
    `define LUI(RD, INM)        `INST_TYPE_I( `CODE_OP_LUI,  5'b00000, RD,       INM ) // Rd = Inm << 16
    `define SLTI(RD, RS1, INM)  `INST_TYPE_I( `CODE_OP_SLTI, RS1,      RD,       INM ) // Rd = Rs1 < sigextend(Inm) ? 1 : 0

    // J-Type instructions

    `define J(ADDR)             `INST_TYPE_J( `CODE_OP_J,   ADDR ) // PC = extend(Addr)
    `define JAL(ADDR)           `INST_TYPE_J( `CODE_OP_JAL, ADDR ) // R31 = PC + 4; PC = extend(Addr)

    // Utils

    `define GET_REG(BANK, R) BANK[R * DATA_BUS_SIZE +: DATA_BUS_SIZE]
    `define GET_MEM(MEMORY, DIR) MEMORY[DIR * DATA_BUS_SIZE +: DATA_BUS_SIZE]
    
`endif // __TB_VH__