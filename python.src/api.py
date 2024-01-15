import os
import signal
import sys
import serial
import platform

from serial.tools import list_ports
from mips_handler import MipsHandler, ExecutionsModes, MipsHandlerException
from asm_parser import asmParser
from uart import Uart
from tables import instructionTable, registerTable
from colorama import Fore, Back, Style

uart = None
mips_handler = None
parser = None

class SigIntException(Exception):
    pass

def sigint_handler(signal, frame):
    raise SigIntException("SIGINT received")

def clear_screen():
    if platform.system() == "Windows":
        os.system("cls")
    else:
        os.system("clear")
        
def print_centered_title(menu):
    console_width = os.get_terminal_size().columns

    title = "MIPS Handler API" + " - " + menu
    spaces_before = (console_width - len(title) - 2) // 2
    spaces_after = console_width - len(title) - spaces_before - 2

    border_line = "-" * console_width

    print(Fore.LIGHTGREEN_EX + Back.BLACK + border_line)
    print(Fore.LIGHTGREEN_EX + Back.BLACK + "-" + " " * spaces_before + Fore.LIGHTGREEN_EX + title +
          Fore.LIGHTGREEN_EX + " " * spaces_after + Back.BLACK + "-")
    print(Fore.LIGHTGREEN_EX + Back.BLACK + border_line)
    print(Style.RESET_ALL)

def print_menu(options, menu_name):
    print_centered_title(menu_name)

    for i, option in enumerate(options):
        print(f"  {option}")

def get_user_selection(options, menu_name):
    current_row = 0

    while True:
        clear_screen()
        print_menu(options, menu_name)
        key = input("\nEnter your choice (Press Enter to confirm): ")

        if key.isdigit():
            selected_index = int(key) - 1
            if 0 <= selected_index < len(options):
                return selected_index
            
        display_error("Invalid option")
        
        input(Fore.LIGHTYELLOW_EX + "\nPress enter to continue..." + Style.RESET_ALL)
        
def get_baud_rate():
    baud_rates = [9600, 19200, 38400, 57600, 115200]
    options = [f"{i + 1}. {rate} bps" for i, rate in enumerate(baud_rates)]
    selected_index = get_user_selection(options, "Baud Rate Selection")
    return baud_rates[selected_index]

def select_serial_port():
    ports = get_serial_ports()

    if not ports:
        clear_screen()
        print_centered_title("Serial Port Selection")
        display_error("No serial ports found ! Program will exit...")
        input(Fore.LIGHTYELLOW_EX + "\nPress enter to continue..." + Style.RESET_ALL)
        clear_screen()
        sys.exit(0)
    
    options = [f"{i + 1}. {port}" for i, port in enumerate(ports)]
    
    selected_index = get_user_selection(options, "Serial Port Selection")
    
    return ports[selected_index]

def get_serial_ports():
    try:
        ports = list_ports.comports()
        return [port.device for port in ports]
    except serial.SerialException:
        return []

def display_error(message):
    print(Fore.RED + f"\nError: {message}" + Style.RESET_ALL)

def main_menu():
    menu_options = ["Load Program", "Execute Program", "Execute by Steps", "Execute in Debug Mode", 
                    "Delete Program", "Exit"]

    while True:
        options = [f"{i + 1}. {option}" for i, option in enumerate(menu_options)]
        selected_index = get_user_selection(options, "Main Menu")

        if selected_index == 0:
            load_program()
        elif selected_index == 1:
            run_normal_mode_program()
        elif selected_index == 2:
            run_step_mode_program()
        elif selected_index == 3:
            run_debug_mode_program()
        elif selected_index == 4:
            delete_program()
        elif selected_index == 5:
            clear_screen()
            print(Fore.LIGHTYELLOW_EX + "\nExiting...\n" + Style.RESET_ALL)
            break
        
        input(Fore.LIGHTYELLOW_EX + "\nPress enter to continue..." + Style.RESET_ALL)

def load_program():
    clear_screen()
    
    try:
        print_centered_title("Load Program")

        program_path = input("Input the program path: ")

        with open(program_path, "r") as file:
            lines = file.readlines()
            result = parser.firstPass(lines)

            if result != 0:
                display_error(f"Compilation error: {result}")
            else:
                clear_screen()
                
                print_centered_title("Load Program")
                
                print(Fore.GREEN + "Program compiled successfully. Result:\n" + Style.RESET_ALL)
                
                parser.asmToMachineCode(lines)
                
                for string in parser.outputArray:
                    print(Fore.LIGHTBLUE_EX + string + Style.RESET_ALL)
                    
                mips_handler.load_program(parser.instructions)
                
                print(Fore.GREEN + "\nProgram loaded successfully !" + Style.RESET_ALL)
    except SigIntException:
        raise
    except FileNotFoundError:
        display_error("File not found")
    except MipsHandlerException as e:
        display_error(e)
    except Exception as e:
        display_error(e)

def run_normal_mode_program():
    clear_screen()

    try:
        print_centered_title("Execute Program")

        mips_handler.execute_program(ExecutionsModes.RELEASE)

        registers = mips_handler.get_registers()
        memory = mips_handler.get_memory()
        
        print_tables(registers, memory, False)    
        
        print(Fore.GREEN + "\nProgram executed successfully !" + Style.RESET_ALL)
    except SigIntException:
        raise
    except MipsHandlerException as e:
        display_error(e)
    except Exception as e:
        display_error(e)
    
def run_step_mode_program():
    clear_screen()

    try:
        print_centered_title("Execute Program by Steps")

        program_end = mips_handler.execute_program(ExecutionsModes.BY_STEPS)

        while not program_end:
            clear_screen()
            print_centered_title("Execute Program by Steps")
            
            registers = mips_handler.get_registers_by_last_cicle()
            memory = mips_handler.get_memory_by_last_cicle()
        
            print_tables(registers, memory)    

            while user_input := input("\nInput 'N' for next step. Input 'S' for exit: "):
                if user_input.upper() == 'N':
                    program_end = mips_handler.execute_program_next_step()
                    break
                elif user_input.upper() == 'S':
                    mips_handler.execute_program_stop()
                    break
                else:
                    display_error("Invalid option")
            
            if user_input.upper() == 'S':
                break

        clear_screen()
        print_centered_title("Execute Program by Steps")
        
        if program_end:
            registers = mips_handler.get_registers_by_last_cicle()
            memory = mips_handler.get_memory_by_last_cicle()
        
            print_tables(registers, memory)          
            
            print(Fore.GREEN + "\nProgram execution finished !" + Style.RESET_ALL)
        else:
            print(Fore.LIGHTRED_EX + "Aborting execution !" + Style.RESET_ALL)
              
    except SigIntException:
        raise
    except MipsHandlerException as e:
        display_error(e)
    except Exception as e:
        display_error(e)

def run_debug_mode_program():
    clear_screen()

    try:
        print_centered_title("Execute Program in Debug Mode")

        print(Fore.LIGHTYELLOW_EX + "Execution program in debug mode..." + Style.RESET_ALL)

        mips_handler.execute_program(ExecutionsModes.DEBUG)

        registers = mips_handler.get_register_summary()
        memory = mips_handler.get_memory_summary()
        
        print_tables(registers, memory)    
        
        print(Fore.GREEN + "\nProgram executed successfully !" + Style.RESET_ALL)
    except SigIntException:
        raise
    except MipsHandlerException as e:
        display_error(e)
    except Exception as e:
        display_error(e)

def delete_program():
    clear_screen()

    try:
        print_centered_title("Delete Program")

        mips_handler.delete_program()
        
        print(Fore.GREEN + "Program deleted successfully !" + Style.RESET_ALL)
    except SigIntException:
        raise
    except MipsHandlerException as e:
        display_error(e)
    except Exception as e:
        display_error(e)

def print_tables(registers, memory, show_cicle = True):
        console_width = os.get_terminal_size().columns
        half_width = console_width // 2

        memory_area = f"{'Memory':^{half_width}}"
        registers_area = f"{'Registers':^{half_width}}"

        line = '-' * console_width
        vertical_line = '|'

        print(Fore.LIGHTBLUE_EX + line + registers_area + vertical_line + memory_area + line + Style.RESET_ALL)
        
        register_print = []
        for register in registers:
            if show_cicle:
                register_print.append(f"    [Cicle {register['cicle']:04d}] R{register['addr']:02d} -> | 0x{register['content']:08X} |")
            else:
                register_print.append(f"    R{register['addr']:02d} -> | 0x{register['content']:08X} |")
            
        memory_print = []
        for mem in memory:
            if show_cicle:
                memory_print.append(f"    [Cicle {mem['cicle']:04d}] M(0x{mem['addr']:02X}) -> | 0x{mem['content']:08X} |")
            else:
                memory_print.append(f"    M(0x{mem['addr']:02X}) -> | 0x{mem['content']:08X} |")
                
        if len(register_print) > len(memory_print):
            for i in range(len(register_print) - len(memory_print)):
                memory_print.append(" " * half_width)
            
        elif len(memory_print) > len(register_print):
            for i in range(len(memory_print) - len(register_print)):
                register_print.append(" " * half_width)
            
        for i in range(max(len(register_print), len(memory_print))):
            if i < len(register_print):
                register = register_print[i] + " " * (half_width - len(register_print[i]) - 1)
            else:
                register = " " * len(half_width - 1)
                
            if i < len(memory_print):
                mem = memory_print[i] + " " * (half_width - len(memory_print[i]) - 1)
            else:
                mem = " " * len(half_width - 1)
                
            print(Fore.LIGHTCYAN_EX + register + Fore.LIGHTBLUE_EX + " " + vertical_line + Fore.LIGHTCYAN_EX + mem + Style.RESET_ALL)

        print(Fore.LIGHTBLUE_EX + line + Style.RESET_ALL)

def main():
    global uart, mips_handler, parser

    try:
        signal.signal(signal.SIGINT, sigint_handler)

        serial_port = select_serial_port()
        baud_rate = get_baud_rate()

        uart = Uart(serial_port, baud_rate)
        mips_handler = MipsHandler(uart)
        parser = asmParser(instructionTable, registerTable, 4)

        main_menu()

    except SigIntException:
        clear_screen()
        print(Fore.RED + "\nSignal SIGINT received. Exiting...\n" + Style.RESET_ALL)
        sys.exit(0)

if __name__ == "__main__":
    main()