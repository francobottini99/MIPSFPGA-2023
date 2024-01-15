OP_CODE_R      = '0x00'
OP_CODE_J      = '0x02'
OP_CODE_JAL    = '0x03'
OP_CODE_BEQ    = '0x04'
OP_CODE_BNE    = '0x05'
OP_CODE_ADDI   = '0x08'
OP_CODE_SLTI   = '0x0a'
OP_CODE_ANDI   = '0x0c'
OP_CODE_ORI    = '0x0d'
OP_CODE_XORI   = '0x0e'
OP_CODE_LUI    = '0x0f'
OP_CODE_LB     = '0x20'
OP_CODE_LH     = '0x21'
OP_CODE_LW     = '0x23'
OP_CODE_LBU    = '0x24'
OP_CODE_LHU    = '0x25'
OP_CODE_SB     = '0x28'
OP_CODE_SH     = '0x29'
OP_CODE_SW     = '0x2b'
OP_CODE_LWU    = '0x27'

FUNC_CODE_JR   = '0x08'
FUNC_CODE_JALR = '0x09'
FUNC_CODE_SLL  = '0x00'
FUNC_CODE_SRL  = '0x02'
FUNC_CODE_SRA  = '0x03'
FUNC_CODE_SLLV = '0x04'
FUNC_CODE_SRLV = '0x06'
FUNC_CODE_SRAV = '0x07'
FUNC_CODE_ADDU = '0x21'
FUNC_CODE_SUBU = '0x23'
FUNC_CODE_AND  = '0x24'
FUNC_CODE_OR   = '0x25'
FUNC_CODE_XOR  = '0x26'
FUNC_CODE_NOR  = '0x27'
FUNC_CODE_SLT  = '0x2a'

instructionTable = {
    #R type
    'SLL'  : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_SLL  ],  #Rd = Rt << Shamt; Rs = 0x00
    'SRL'  : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_SRL  ],  #Rd = Rt >> Shamt; Rs = 0x00
    'SRA'  : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_SRA  ],  #Rd = Rt >>> Shamt; Rs = 0x00
    'SLLV' : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_SLLV ],  #Rd = Rt << Rs; Shamt = 0x00
    'SRLV' : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_SRLV ],  #Rd = Rt >> Rs; Shamt = 0x00
    'SRAV' : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_SRAV ],  #Rd = Rt >>> Rs; Shamt = 0x00
    'ADDU' : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_ADDU ],  #Rd = Rs + Rt; Shamt = 0x00
    'SUBU' : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_SUBU ],  #Rd = Rs - Rt; Shamt = 0x00
    'AND'  : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_AND  ],  #Rd = Rs & Rt; Shamt = 0x00
    'OR'   : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_OR   ],  #Rd = Rs | Rt; Shamt = 0x00
    'XOR'  : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_XOR  ],  #Rd = Rs ^ Rt; Shamt = 0x00
    'NOR'  : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_NOR  ],  #Rd = ~(Rs | Rt); Shamt = 0x00
    'SLT'  : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_SLT  ],  #Rd = (Rs < Rt) ? 1 : 0; Shamt = 0x00

    #I type
    'LB'   : [ OP_CODE_LB,   'RS', 'RT', 'INM' ], #Rt = sigextend(Mem[Rs + unsigextend(INM)])
    'LH'   : [ OP_CODE_LH,   'RS', 'RT', 'INM' ], #Rt = sigextend(Mem[Rs + unsigextend(INM)])
    'LW'   : [ OP_CODE_LW,   'RS', 'RT', 'INM' ], #Rt = Mem[Rs + unsigextend(INM)]
    'LWU'  : [ OP_CODE_LWU,  'RS', 'RT', 'INM' ], #Rt = Mem[Rs + unsigextend(INM)]
    'LBU'  : [ OP_CODE_LBU,  'RS', 'RT', 'INM' ], #Rt = unsigextend(Mem[Rs + unsigextend(INM)])
    'LHU'  : [ OP_CODE_LHU,  'RS', 'RT', 'INM' ], #Rt = unsigextend(Mem[Rs + unsigextend(INM)])
    'SB'   : [ OP_CODE_SB,   'RS', 'RT', 'INM' ], #Mem[Rs + unsigextend(INM)] = Rt[7:0] 
    'SH'   : [ OP_CODE_SH,   'RS', 'RT', 'INM' ], #Mem[Rs + unsigextend(INM)] = Rt[15:0]
    'SW'   : [ OP_CODE_SW,   'RS', 'RT', 'INM' ], #Mem[Rs + unsigextend(INM)] = Rt[31:0]
    'ADDI' : [ OP_CODE_ADDI, 'RS', 'RT', 'INM' ], #Rt = Rs + sigextend(INM)
    'ANDI' : [ OP_CODE_ANDI, 'RS', 'RT', 'INM' ], #Rt = Rs & unsigextend(INM)
    'ORI'  : [ OP_CODE_ORI,  'RS', 'RT', 'INM' ], #Rt = Rs | unsigextend(INM)
    'XORI' : [ OP_CODE_XORI, 'RS', 'RT', 'INM' ], #Rt = Rs ^ unsigextend(INM)
    'LUI'  : [ OP_CODE_LUI,  'RS', 'RT', 'INM' ], #Rt = INM << 16; Rs = 0x00
    'SLTI' : [ OP_CODE_SLTI, 'RS', 'RT', 'INM' ], #Rt = (Rs < sigextend(INM)) ? 1 : 0
    'BEQ'  : [ OP_CODE_BEQ,  'RS', 'RT', 'INM' ], #if (Rs == Rt) PC = PC + 4 + (INM << 2)
    'BNE'  : [ OP_CODE_BNE,  'RS', 'RT', 'INM' ], #if (Rs != Rt) PC = PC + 4 + (INM << 2)

    'JALR' : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_JALR ], #R31 = PC + 4; PC = Rs; Shamt = 0x00
    'JR'   : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_JR   ], #PC = Rs
    
    #J type
    'J'    : [ OP_CODE_J,   'DIR' ], #PC = (PC & 0xf0000000) | (DIR << 2)
    'JAL'  : [ OP_CODE_JAL, 'DIR' ], #R31 = PC + 4; PC = (PC & 0xf0000000) | (DIR << 2)

    'NOP'  : [ '0x00000000' ], #No Operation
    'HALT' : [ '0xffffffff' ]  #Halt
}

registerTable = {
    'r0'  : 0,
    'r1'  : 1,
    'r2'  : 2,
    'r3'  : 3,
    'r4'  : 4,
    'r5'  : 5,
    'r6'  : 6,
    'r7'  : 7,
    'r8'  : 8,
    'r9'  : 9,
    'r10' : 10,
    'r11' : 11,
    'r12' : 12,
    'r13' : 13,
    'r14' : 14,
    'r15' : 15,
    'r16' : 16,
    'r17' : 17,
    'r18' : 18,
    'r19' : 19,
    'r20' : 20,
    'r21' : 21,
    'r22' : 22,
    'r23' : 23,
    'r24' : 24,
    'r25' : 25,
    'r26' : 26,
    'r27' : 27,
    'r28' : 28,
    'r29' : 29,
    'r30' : 30,
    'r31' : 31
}