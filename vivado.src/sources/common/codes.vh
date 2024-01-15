`ifndef __CODES_VH__
`define __CODES_VH__

    /** --------------------------- Codes for OP (instruction[31:26]) --------------------------- **/

    `define CODE_OP_R_TYPE  6'b000000 // R-Type instructions                             
    `define CODE_OP_HALT    6'b111111 // Halt instruction                      

    `define CODE_OP_BEQ     6'b000100 // Branch if equal instruction                     
    `define CODE_OP_BNE     6'b000101 // Branch if not equal instruction                     
    `define CODE_OP_J       6'b000010 // Jump instruction                                
    `define CODE_OP_JAL     6'b000011 // Jump and link instruction                       
    `define CODE_OP_LB      6'b100000 // Load byte instruction                           
    `define CODE_OP_LH      6'b100001 // Load halfword instruction                       
    `define CODE_OP_LW      6'b100011 // Load word instruction                           
    `define CODE_OP_LWU     6'b100111 // Load word unsigned instruction                  
    `define CODE_OP_LBU     6'b100100 // Load byte unsigned instruction                  
    `define CODE_OP_LHU     6'b100101 // Load halfword unsigned instruction              
    `define CODE_OP_SB      6'b101000 // Store byte instruction                          
    `define CODE_OP_SH      6'b101001 // Store halfword instruction                      
    `define CODE_OP_SW      6'b101011 // Store word instruction                          
    `define CODE_OP_ADDI    6'b001000 // Add immediate instruction                       
    `define CODE_OP_ANDI    6'b001100 // And immediate instruction                       
    `define CODE_OP_ORI     6'b001101 // Or immediate instruction                        
    `define CODE_OP_XORI    6'b001110 // Xor immediate instruction                       
    `define CODE_OP_LUI     6'b001111 // Load upper immediate instruction                
    `define CODE_OP_SLTI    6'b001010 // Set less than immediate instruction          

    /** --------------------------- Codes for FUNCT (instruction[5:0]) --------------------------- **/   

    `define CODE_FUNCT_JR   6'b001000 // Jump register function                       
    `define CODE_FUNCT_JALR 6'b001001 // Jump and link register function              

    `define CODE_FUNCT_SLL  6'b000000 // Shift left logical function                  
    `define CODE_FUNCT_SRL  6'b000010 // Shift right logical function                 
    `define CODE_FUNCT_SRA  6'b000011 // Shift right arithmetic function              
    `define CODE_FUNCT_ADD  6'b100000 // Add function                                 
    `define CODE_FUNCT_ADDU 6'b100001 // Add unsigned function                        
    `define CODE_FUNCT_SUB  6'b100010 // Subtract function                            
    `define CODE_FUNCT_SUBU 6'b100011 // Subtract unsigned function                   
    `define CODE_FUNCT_AND  6'b100100 // And function                                 
    `define CODE_FUNCT_OR   6'b100101 // Or function                                  
    `define CODE_FUNCT_XOR  6'b100110 // Xor function                                 
    `define CODE_FUNCT_NOR  6'b100111 // Nor function                                 
    `define CODE_FUNCT_SLT  6'b101010 // Set less than function                       
    `define CODE_FUNCT_SLLV 6'b000100 // Shift left logical variable function         
    `define CODE_FUNCT_SRLV 6'b000110 // Shift right logical variable function        
    `define CODE_FUNCT_SRAV 6'b000111 // Shift right arithmetic variable function      

    /** --------------------------- Codes for MAIN control --------------------------- **/   

    `define CODE_MAIN_CTR_NEXT_PC_SRC_SEQ          1'b0   // Sequential
    `define CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ      1'b1   // Not sequential
    `define CODE_MAIN_CTR_NOT_JMP                  2'bxx  // Not jump
    `define CODE_MAIN_CTR_JMP_DIR                  2'b10  // Jump direct
    `define CODE_MAIN_CTR_JMP_REG                  2'b01  // Jump register
    `define CODE_MAIN_CTR_JMP_BRANCH               2'b00  // Jump branch
    `define CODE_MAIN_CTR_REG_DST_RD               2'b01  // Register destination is rd
    `define CODE_MAIN_CTR_REG_DST_GPR_31           2'b10  // Register destination is gpr[31]
    `define CODE_MAIN_CTR_REG_DST_RT               2'b00  // Register destination is rt
    `define CODE_MAIN_CTR_REG_DST_NOTHING          2'bxx  // Register destination is nothing
    `define CODE_MAIN_CTR_MEM_WR_SRC_WORD          2'b00  // Memory write source is word
    `define CODE_MAIN_CTR_MEM_WR_SRC_HALFWORD      2'b01  // Memory write source is halfword
    `define CODE_MAIN_CTR_MEM_WR_SRC_BYTE          2'b10  // Memory write source is byte
    `define CODE_MAIN_CTR_MEM_WR_SRC_NOTHING       2'bxx  // Memory write source is nothing
    `define CODE_MAIN_CTR_MEM_RD_SRC_WORD          3'b000 // Memory read source is word
    `define CODE_MAIN_CTR_MEM_RD_SRC_SIG_HALFWORD  3'b001 // Memory read source is signed halfword
    `define CODE_MAIN_CTR_MEM_RD_SRC_SIG_BYTE      3'b010 // Memory read source is signed byte
    `define CODE_MAIN_CTR_MEM_RD_SRC_USIG_HALFWORD 3'b011 // Memory read source is unsigned halfword
    `define CODE_MAIN_CTR_MEM_RD_SRC_USIG_BYTE     3'b100 // Memory read source is unsigned byte
    `define CODE_MAIN_CTR_MEM_RD_SRC_NOTHING       3'bxxx // Memory read source is nothing
    `define CODE_MAIN_CTR_MEM_WRITE_ENABLE         1'b1   // Enable memory write
    `define CODE_MAIN_CTR_MEM_WRITE_DISABLE        1'b0   // Disable memory write
    `define CODE_MAIN_CTR_WB_ENABLE                1'b1   // Enable register write back
    `define CODE_MAIN_CTR_WB_DISABLE               1'b0   // Disable register write back
    `define CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT    1'b0   // Memory result to register
    `define CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT    1'b1   // ALU result to register
    `define CODE_MAIN_CTR_MEM_TO_REG_NOTHING       1'bx   // Nothing to register

    /** --------------------------- Codes for ALU control --------------------------- **/
    
    `define CODE_ALU_CTR_LOAD_TYPE         3'b000 // Load instructions
    `define CODE_ALU_CTR_STORE_TYPE        3'b000 // Store instructions
    `define CODE_ALU_CTR_ADDI              3'b000 // Add immediate instruction
    `define CODE_ALU_CTR_BRANCH_TYPE       3'b001 // Branch instructions
    `define CODE_ALU_CTR_ANDI              3'b010 // And immediate instruction
    `define CODE_ALU_CTR_ORI               3'b011 // Or immediate instruction
    `define CODE_ALU_CTR_XORI              3'b100 // Xor immediate instruction
    `define CODE_ALU_CTR_SLTI              3'b101 // Set less than immediate instruction
    `define CODE_ALU_CTR_R_TYPE            3'b110 // R-Type instructions
    `define CODE_ALU_CTR_JUMP_TYPE         3'b111 // Jump instructions
    `define CODE_ALU_CTR_UNDEFINED         3'bxxx // Undefined instruction

    `define CODE_ALU_CTR_SRC_A_SHAMT       1'b0  // Shamt
    `define CODE_ALU_CTR_SRC_A_BUS_A       1'b1  // Bus A
    `define CODE_ALU_CTR_SRC_A_NOTHING     1'bx // Nothing
    
    `define CODE_ALU_CTR_SRC_B_NEXT_SEQ_PC 3'b000  // Next sequential PC
    `define CODE_ALU_CTR_SRC_B_UPPER_INM   3'b001  // Upper immediate
    `define CODE_ALU_CTR_SRC_B_SIG_INM     3'b010  // Sign immediate
    `define CODE_ALU_CTR_SRC_B_USIG_INM    3'b011  // Unsigned immediate
    `define CODE_ALU_CTR_SRC_B_BUS_B       3'b100  // Bus B
    `define CODE_ALU_CTR_SRC_B_NOTHING     3'bxxx  // Nothing
    
    /** --------------------------- Codes for ALU excution --------------------------- **/

    `define CODE_ALU_EX_SLL          4'b0000 // Shift left logical
    `define CODE_ALU_EX_SRL          4'b0001 // Shift right logical
    `define CODE_ALU_EX_SRA          4'b0010 // Shift right arithmetic
    `define CODE_ALU_EX_ADD          4'b0011 // Sum
    `define CODE_ALU_EX_ADDU         4'b0100 // Sum unsigned
    `define CODE_ALU_EX_SUB          4'b0101 // Substract 
    `define CODE_ALU_EX_SUBU         4'b0110 // Substract unsigned
    `define CODE_ALU_EX_AND          4'b0111 // Logical and
    `define CODE_ALU_EX_OR           4'b1000 // Logical or
    `define CODE_ALU_EX_XOR          4'b1001 // Logical xor
    `define CODE_ALU_EX_NOR          4'b1010 // Logical nor
    `define CODE_ALU_EX_SLT          4'b1011 // Set if less than
    `define CODE_ALU_EX_SLLV         4'b1100 // Shift left logical
    `define CODE_ALU_EX_SRLV         4'b1101 // Shift right logical
    `define CODE_ALU_EX_SRAV         4'b1110 // Shift right arithmetic
    `define CODE_ALU_EX_SC_B         4'b1111 // Short circuit B
    `define CODE_ALU_EX_NOP          4'bxxxx // No operation

    /** --------------------------- Codes for Short Circuit --------------------------- **/

    `define CODE_SC_DATA_SRC_ID_EX   2'b00 // Data source is ID/EX
    `define CODE_SC_DATA_SRC_MEM_WB  2'b01 // Data source is MEM/WB
    `define CODE_SC_DATA_SRC_EX_MEM  2'b10 // Data source is EX/MEM
    `define CODE_SC_DATA_SRC_NOTHING 2'bxx // Data source is nothing

    /* --------------------------- Codes for Debugger --------------------------- **/

    `define DEBUGGER_NO_CICLE_MASK                  8'b00000000
    `define DEBUGGER_NO_ADDRESS_MASK                8'b00000000

    `define DEBUGGER_ERROR_PREFIX                   8'b11111111
    `define DEBUGGER_INFO_PREFIX                    8'b00000000
    `define DEBUGGER_REG_PREFIX                     8'b00000001
    `define DEBUGGER_MEM_PREFIX                     8'b00000010

    `define DEBUGGER_INFO_END_PROGRAM               32'b00000000000000000000000000000001
    `define DEBUGGER_INFO_LOAD_PROGRAM              32'b00000000000000000000000000000010
    `define DEBUGGER_INFO_END_STEP                  32'b00000000000000000000000000000011

    `define DEBUGGER_ERROR_INSTRUCTION_MEMORY_FULL  32'b00000000000000000000000000000001
    `define DEBUGGER_ERROR_NO_PROGRAM_LOAD          32'b00000000000000000000000000000010
    `define DEBUGGER_ERROR_BAD_REGISTER_ADDRESS     32'b00000000000000000000000000000011
    `define DEBUGGER_ERROR_BAD_MEMORY_ADDRESS       32'b00000000000000000000000000000100
    `define DEBUGGER_ERROR_UNKNOWN_COMMAND          32'b00000000000000000000000000000101
    `define DEBUGGER_ERROR_ALREADY_PROGRAM_LOAD     32'b00000000000000000000000000000110

`endif // __CODES_VH__