import re

class asmParser():
    wordSize = 4
    instructionTable = {}
    registerTable = {}
    symbolTable = {}
    currentLocation = 0
    outputArray = []
    instructions = []


    def __init__(self, instructionTable, registerTable, wordSize):
        self.instructionTable = instructionTable
        self.registerTable = registerTable
        self.wordSize = wordSize


    def firstPass(self, lines):
        self.outputArray = []
        self.instructions = []
        self.symbolTable = {}
        self.currentLocation = 0

        for line in lines:
            if '#' in line:
                line = line[0:line.find('#')]
            line = line.strip()
            if not len(line):
                continue

            if ':' in line:
                label = line[0:line.find(':')]
                self.symbolTable[label] = str(self.currentLocation)
                line = line[line.find(':') + 1:].strip()

            spaceIndex = line.find(' ')
            if(spaceIndex != -1):
                instruction = line[0:spaceIndex].strip()
                args        = line[line.find(' ') + 1:].replace(' ', '').split(',')
                acount = 0
                for arg in args:
                    if arg not in self.symbolTable.keys():
                        if arg[-1] == 'H':
                            args[acount] = str(int(arg[:-1], 16))
                        elif arg[-1] == 'B':
                            args[acount] = str(int(arg[:-1], 2))
                    acount += 1
            else:
                instruction = line
                args = None

            valid = self.validateInstruction(instruction)
            if(valid ==4):
                self.currentLocation += valid
            else:
                return valid

        return 0

    def asmToMachineCode(self, lines):

        self.currentLocation = 0
        for line in lines:
            if '#' in line:
                line = line[0:line.find('#')]
            line = line.strip()
            if not len(line):
                continue

            if ':' in line:
                label = line[0:line.find(':')]
                line = line[line.find(':') + 1:].strip()
                self.outputArray.append( '\n' + hex(int(self.symbolTable[label])) + ' <' + label + '>:' )

            spaceIndex = line.find(' ')
            if(spaceIndex != -1):
                instruction = line[0:spaceIndex].strip()
                args        = line[line.find(' ') + 1:].replace(' ', '').split(',')
                acount = 0
                for arg in args:
                    if arg not in self.symbolTable.keys():
                        if arg[-1] == 'H':
                            args[acount] = str(int(arg[:-1], 16))
                        elif arg[-1] == 'B':
                            args[acount] = str(int(arg[:-1], 2))
                    acount += 1
            else:
                instruction = line
                args = None

            if instruction in self.instructionTable.keys():
                self.parseInstruction(instruction, args)


    def parseInstruction(self, instruction, raw_args):

            machine_code = self.instructionTable[instruction]
            arg_count = 0
            offset    = 'not_valid'
            if(raw_args != None):
                args = raw_args[:]
            
                for arg in args:
                    if '(' in arg:
                        offset   = hex(int(arg[0:arg.find('(')]))
                        register = re.search('\((.*)\)', arg)
                        location = self.registerTable[register.group(1)]
                        register = location
                        args[arg_count] = register

                    elif arg in self.registerTable.keys():
                        args[arg_count] = int(self.registerTable[arg])

                    elif arg in self.symbolTable:
                        args[arg_count] = self.symbolTable[arg]

                    arg_count += 1

                if (instruction == 'BEQ' or instruction == 'BNE'):
                    args[2] = (int(args[2]) - self.currentLocation - 4)/4

                if (instruction == 'J' or instruction == 'JAL'):
                    args[0] = int(int(args[0])/4)

                for i in range(0, len(args)):
                    args[i] = str(hex(int(args[i])))

            # R instruction
            if len(machine_code) == 6:
                if (instruction == "JR"): #JR syntax
                    machine_code[1] = args[0] #rs
                    machine_code[2] = '0' #rt
                    machine_code[3] = '0' #rd
                    machine_code[4] = '0' #shamt
                elif (instruction == "JALR"): #JR syntax
                    machine_code[2] = '0' #rt
                    machine_code[4] = '0' #shamt
                    if(len(args) == 1):
                        machine_code[1] = args[0] #rs
                        machine_code[3] = '1f' #rd
                    else:
                        machine_code[1] = args[1] #rs
                        machine_code[3] = args[0] #rd
                elif (instruction == "SLL" or instruction == "SRL" or instruction == "SRA"):
                    machine_code[1] = '0' # rs
                    machine_code[2] = args[1] #rt
                    machine_code[3] = args[0] #rd
                    machine_code[4] = args[2] #shamt
                else:
                    machine_code[1] = args[1] #rs
                    machine_code[2] = args[2] #rt
                    machine_code[3] = args[0] #rd
                    machine_code[4] = '0' #shamt

                op_binary = self.hex2bin(machine_code[0], 6)
                rs_binary = self.hex2bin(machine_code[1], 5)
                rt_binary = self.hex2bin(machine_code[2], 5)
                rd_binary = self.hex2bin(machine_code[3], 5)
                shamt_bin = self.hex2bin(machine_code[4], 5)
                funct_bin = self.hex2bin(machine_code[5], 6)
                
                bit_string = op_binary + rs_binary + rt_binary + rd_binary + shamt_bin + funct_bin
                self.storeBitString(bit_string, instruction, raw_args)

                return

            # I instruction
            if len(machine_code) == 4:
                if instruction == 'BEQ' or instruction == 'BNE':
                    rs  = args[0]
                    rt  = args[1]
                else:
                    rs  = args[1]
                    rt  = args[0]
                    
                imm = offset

                if len(args) == 3:
                    imm = hex(int(args[2], 16))
    

                elif imm == 'not_valid':
                    imm = args[1]
                    rs = '0'

                machine_code[1] = rs
                machine_code[2] = rt
                machine_code[3] = imm

                op_binary = self.hex2bin(machine_code[0], 6)
                rs_binary = self.hex2bin(machine_code[1], 5)
                rt_binary = self.hex2bin(machine_code[2], 5)
                im_binary = self.hex2bin(machine_code[3], 16)

                bit_string = op_binary + rs_binary + rt_binary + im_binary
                self.storeBitString(bit_string, instruction, raw_args)
                return

            # J instruction
            if len(machine_code) == 2:
                address = args[0]
                machine_code[1] = hex(int(address, 16))

                op_binary      = self.hex2bin(machine_code[0], 6)
                address_binary = self.hex2bin(machine_code[1], 26)
                bit_string = op_binary + address_binary

                self.storeBitString(bit_string, instruction, raw_args)
                return
            
            # NOP and HALT
            if len(machine_code) == 1:
                op_binary = self.hex2bin(machine_code[0],32)
                bit_string = op_binary
                self.storeBitString(bit_string, instruction, raw_args)

            return


    def validateInstruction(self, instruction):
        if instruction in self.instructionTable:
            return 4
        else:
            return "NOT VALID INSTRUCTION: " + instruction

    def hex2bin(self, hex_val, num_bits):
        is_negative = False

        if '-' in hex_val:
            is_negative = True
            hex_val = hex_val.replace('-', '')

        bin_val = format(int(hex_val, 16), f'0{num_bits}b')

        if is_negative:
            bin_val = bin_val[-num_bits:]
            bin_val = bin_val.replace('0', '2').replace('1', '0').replace('2', '1')
            bin_val = format(int(bin_val, 2) + 1, f'0{num_bits}b')

        return str(bin_val)
    
    def bin2hex(self, bit_string):
        bit_string = '0b'+bit_string
        hex_string = str(hex(int(bit_string, 2)))[2:]
        hex_string = hex_string.zfill(2)
        return hex_string
    

    def storeBitString(self, bit_string, instruction, arguments):
        
        if self.currentLocation % 4 == 0:
            self.outputArray.append(hex(self.currentLocation) + ':    0x')

        for i in range(0, len(bit_string) - 1, 8):
            self.outputArray[-1] += self.bin2hex(bit_string[i:i + 8])
            self.instructions.append(self.bin2hex(bit_string[i:i+8]))
            self.currentLocation += 1

        if self.currentLocation %4 == 0:
            if(arguments != None):
                self.outputArray[-1] += '    ' + instruction.ljust(5) + ', '.join(arguments)
            else:
                self.outputArray[-1] += '    ' + instruction.ljust(5) 