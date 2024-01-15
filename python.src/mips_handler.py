from uart import Uart
import time
from enum import Enum, auto

class ExecutionsModes(Enum):
    BY_STEPS = auto()
    DEBUG = auto()
    RELEASE = auto()
    
RESPONSE_SIZE_BYTES  = 7

RESPONSE_TYPE_MASK   = 0xff000000000000
RESPONSE_CICLE_MASK  = 0x00ff0000000000
RESPONSE_ADDR_MASK   = 0x0000ff00000000
RESPONSE_DATA_MASK   = 0x000000ffffffff

FILD_BYTE                = 0x00

COMMAND_LOAD_PROGRAM     = 0x4C
COMMAND_EXECUTE          = 0x45
COMMAND_EXECUTE_BY_STEPS = 0x53
COMMAND_EXECUTE_DEBUG    = 0x44
COMMAND_DELETE           = 0x46
COMMAND_NEXT_STEP        = 0x4E
COMMAND_STOP_EXECUTION   = 0x53

ERROR_PREFIX = 0xff
INFO_PREFIX  = 0x00
REG_PREFIX  = 0x01
MEM_PREFIX  = 0x02

RESPONSE_INFO_END_PROGRAM  = 0x1
RESPONSE_INFO_LOAD_PROGRAM = 0x2
RESPONSE_INFO_STEP_END     = 0x3

RESPONSE_ERROR_EMPTY_PROGRAM = 0x2

class MipsHandlerException(Exception):
    pass

class MipsHandler():
    uart = None
    registers = None
    memory = None
    
    in_step_execution_mode = False
    
    def __init__(self, uart: Uart):
        self.uart = uart
    
    def _read_response(self, lock = False):
        if (self.uart.available(RESPONSE_SIZE_BYTES) or lock):
            response = self.uart.read(RESPONSE_SIZE_BYTES)
            
            response_type  = (response & RESPONSE_TYPE_MASK)  >> 48
            response_cicle = (response & RESPONSE_CICLE_MASK) >> 40
            response_addr  = (response & RESPONSE_ADDR_MASK)  >> 32
            response_data  = (response & RESPONSE_DATA_MASK)
            
            return response_type, response_cicle, response_addr, response_data
        else:
            return -1, -1, -1, -1
    
    def _send_command(self, command: int):
        self.uart.write(command)
        self.uart.write(FILD_BYTE)
        self.uart.write(FILD_BYTE)
        self.uart.write(FILD_BYTE)
        time.sleep(0.1)
        
    def _read_results(self) -> bool:
        while True:
            type, cicle, addr, content = self._read_response()
            
            if type == ERROR_PREFIX:
                if content == RESPONSE_ERROR_EMPTY_PROGRAM:
                    raise MipsHandlerException(f"Not program loaded !")
                else:
                    raise MipsHandlerException(f"Execution program error {hex(content)} !")
            elif type == INFO_PREFIX:
                if content == RESPONSE_INFO_END_PROGRAM:
                    return True
                elif content == RESPONSE_INFO_STEP_END:
                    return False
            elif type == REG_PREFIX:
                self.registers.append({'cicle': cicle, 'addr': addr, 'content': content})
            elif type == MEM_PREFIX:
                self.memory.append({'cicle': cicle, 'addr': addr, 'content': content})
            else:
                time.sleep(0.01)
                
                
    def load_program(self, instructions: list):
        self._send_command(COMMAND_LOAD_PROGRAM)
        
        type, _, _, data = self._read_response()
        
        if type != -1:
            raise MipsHandlerException(f"Failed to load program: {hex(data)} !")
        
        for i in range (0, len(instructions), 4):
            for j in range (3, -1, -1):
                index = i+j
                if (index < len(instructions)):
                    self.uart.write(int(instructions[index], 16), byteorder='big')
                else: 
                    break

        type, _, _, data = self._read_response(lock=True)
        
        if type == ERROR_PREFIX:
            raise MipsHandlerException(f"Failed to load program: {hex(data)} !")
        
    def execute_program(self, mode: ExecutionsModes) -> bool:
        self.registers = []
        self.memory = []
        
        self.in_step_execution_mode = False
        
        if mode == ExecutionsModes.BY_STEPS:
            self._send_command(COMMAND_EXECUTE_BY_STEPS)
            self.in_step_execution_mode = True
        elif mode == ExecutionsModes.DEBUG:
            self._send_command(COMMAND_EXECUTE_DEBUG)
        elif mode == ExecutionsModes.RELEASE:
            self._send_command(COMMAND_EXECUTE)
        else:
            raise MipsHandlerException(f"Not supported execution mode: {mode} !")
        
        return self._read_results()
    
    def execute_program_next_step(self) -> bool:
        if not self.in_step_execution_mode:
            raise MipsHandlerException(f"The program is not running in step mode !")
            
        self._send_command(COMMAND_NEXT_STEP)
        
        return self._read_results()
    
    def execute_program_stop(self):
        if not self.in_step_execution_mode:
            raise MipsHandlerException(f"The program is not running in step mode !")
            
        self._send_command(COMMAND_STOP_EXECUTION)
        
        type, _, _, data = self._read_response()
        
        if type != -1:
            raise MipsHandlerException(f"Stop execution error {hex(data)} !")
        
    def delete_program(self):
        self._send_command(COMMAND_DELETE)
        
        type, _, _, data = self._read_response()
        
        if type != -1:
            raise MipsHandlerException(f"Delete program error {hex(data)} !")
        
    def get_registers(self):
        return self.registers
    
    def get_memory(self):
        return self.memory
    
    def get_registers_by_last_cicle(self):
        if not self.registers:
            return []
        
        last_cicle = self.registers[-1]['cicle']
        
        return self.get_registers_by_cicle(last_cicle)
    
    def get_memory_by_last_cicle(self):
        if not self.memory:
            return []
        
        last_cicle = self.memory[-1]['cicle']
        
        return self.get_memory_by_cicle(last_cicle)
    
    def get_registers_by_cicle(self, cicle: int):
        return list(filter(lambda register: register['cicle'] == cicle, self.registers))
    
    def get_memory_by_cicle(self, cicle: int):
        return list(filter(lambda memory: memory['cicle'] == cicle, self.memory))
    
    def get_registers_by_addr(self, addr: int):
        return list(filter(lambda register: register['addr'] == addr, self.registers))
    
    def get_memory_by_addr(self, addr: int):
        return list(filter(lambda memory: memory['addr'] == addr, self.memory))
    
    def get_registers_by_cicle_and_addr(self, cicle: int, addr: int):
        return list(filter(lambda register: register['cicle'] == cicle and register['addr'] == addr, self.registers))
    
    def get_memory_by_cicle_and_addr(self, cicle: int, addr: int):
        return list(filter(lambda memory: memory['cicle'] == cicle and memory['addr'] == addr, self.memory))
    
    def get_register_summary(self):
        summary = []

        if not self.registers or len(self.registers) < 2:
            return summary

        last_cicle = self.registers[-1]['cicle']

        for cicle in range(2, last_cicle):
            prev_cicle_registers = self.get_registers_by_cicle(cicle - 1)
            cicle_registers = self.get_registers_by_cicle(cicle)

            for register in cicle_registers:
                addr = register['addr']
               
                prev_content = prev_cicle_registers[addr]['content']

                if register['content'] != prev_content:
                    summary.append({'cicle': register['cicle'], 'addr': register['addr'], 'content': register['content'],  'prev_content': prev_content})

        return summary

    def get_memory_summary(self):
        summary = []

        if not self.memory or len(self.memory) < 2:
            return summary

        last_cicle = self.memory[-1]['cicle']

        for cicle in range(2, last_cicle):
            prev_cicle_memory = self.get_memory_by_cicle(cicle - 1)
            cicle_memory = self.get_memory_by_cicle(cicle)

            for memory in cicle_memory:
                addr = memory['addr']
               
                prev_content = prev_cicle_memory[addr]['content']

                if memory['content'] != prev_content:
                    summary.append({'cicle': memory['cicle'], 'addr': memory['addr'], 'content': memory['content'],  'prev_content': prev_content})

        return summary
        
    def Close(self):
        self.uart.close()