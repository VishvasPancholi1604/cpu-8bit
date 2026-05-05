import os
import sys
import argparse
from common_method_defines import *
from globals import *


# ASM and HEX file directories
asm_dir = "/u/pancholv/Desktop/sv_uvm/cpu/sim/assembler/asm"
hex_dir = "/u/pancholv/Desktop/sv_uvm/cpu/sim/assembler/hex"


def parse_int(val_str):
    if val_str.upper().startswith("0X"):
        return int(val_str, 16)
    return int(val_str)


def parse_instruction(l_instr):
    instruction_str = l_instr.strip().replace(',', ' ')
    instruction_str = ' '.join(instruction_str.split())
    if not instruction_str:
        return 0
    keywords = instruction_str.split(' ')
    instr_opcode = keywords[0]
    hex_val = 0
    if instr_opcode in cpu_alu_operation:
        hex_val = set_bit_field(hex_val, boundaries["opcode"]["msb"], boundaries["opcode"]["lsb"], cpu_opcodes["ALU_REG"])
        hex_val = set_bit_field(hex_val, boundaries["alu"]["msb"], boundaries["alu"]["lsb"], cpu_alu_operation[instr_opcode])
        hex_val = set_bit_field(hex_val, boundaries["dreg"]["msb"], boundaries["dreg"]["lsb"], cpu_registers[keywords[1]])
        hex_val = set_bit_field(hex_val, boundaries["sreg"]["msb"], boundaries["sreg"]["lsb"], cpu_registers[keywords[2]])
        return hex_val
    if instr_opcode in cpu_jmp_type:
        hex_val = set_bit_field(hex_val, boundaries["opcode"]["msb"], boundaries["opcode"]["lsb"], cpu_opcodes["BCC"])
        hex_val = set_bit_field(hex_val, boundaries["bcc"]["msb"], boundaries["bcc"]["lsb"], cpu_jmp_type[instr_opcode])
        hex_val = set_bit_field(hex_val, boundaries["imm_bits"]["msb"], boundaries["imm_bits"]["lsb"], parse_int(keywords[1]))
        return hex_val
    if instr_opcode not in cpu_opcodes:
        raise ValueError(f"Invalid opcode: {instr_opcode}")
    hex_val = set_bit_field(hex_val, boundaries["opcode"]["msb"], boundaries["opcode"]["lsb"], cpu_opcodes[instr_opcode])
    if instr_opcode in ["NOP", "RESERVED", "RET", "HALT"]:
        pass
    elif instr_opcode in ["LOAD_IMM", "LOAD_DIR", "LOAD_IND", "STORE_DIR", "STORE_IND"]:
        hex_val = set_bit_field(hex_val, boundaries["dreg"]["msb"], boundaries["dreg"]["lsb"], cpu_registers[keywords[1]])
        if len(keywords) > 2:
            hex_val = set_bit_field(hex_val, boundaries["imm_bits"]["msb"], boundaries["imm_bits"]["lsb"], parse_int(keywords[2]))
    elif instr_opcode in ["PUSH", "POP"]:
        hex_val = set_bit_field(hex_val, boundaries["dreg"]["msb"], boundaries["dreg"]["lsb"], cpu_registers[keywords[1]])
    elif instr_opcode in ["LOAD_SP", "JMP", "CALL"]:
        if len(keywords) > 1:
            hex_val = set_bit_field(hex_val, boundaries["imm_bits"]["msb"], boundaries["imm_bits"]["lsb"], parse_int(keywords[1]))
        elif instr_opcode == "CALL":
            hex_val = set_bit_field(hex_val, 11, 11, 1)
    return hex_val


def assemble_file(input_file, output_file):
    machine_codes = []
    with open(input_file, 'r') as infile:
        for line in infile:
            line = line.split('//')[0].strip()
            if not line:
                continue
            machine_code = parse_instruction(line)
            machine_codes.append(machine_code)
    with open(output_file, 'w') as outfile:
        m_code = [f"{machine_code:04X}" for machine_code in machine_codes]
        outfile.write(' '.join(m_code))


def select_asm_file(path, choose_file=False):
    os.makedirs(path, exist_ok=True)
    asm_files = [file for file in os.listdir(path) if file.endswith('.asm')]
    if not asm_files:
        print(f"No '.asm' files found in {path}")
        sys.exit(1)
    asm_paths = [os.path.join(path, file) for file in asm_files]
    if not choose_file:
        latest_file = max(asm_paths, key=os.path.getmtime)
        print(f"Using default ASM file: {latest_file}")
        return latest_file
    for idx, name in enumerate(asm_files):
        print(f"  {idx}. {name}")
    try:
        selected_idx = int(input(f"Select index of '.asm' file (0-{len(asm_files) - 1}): "))
        if 0 <= selected_idx < len(asm_files):
            return asm_paths[selected_idx]
        print("Invalid index. Defaulting to 0.")
        return asm_paths[0]
    except ValueError:
        print("Invalid input. Defaulting to 0.")
        return asm_paths[0]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--select', action='store_true')
    args = parser.parse_args()
    os.makedirs(hex_dir, exist_ok=True)
    input_file = select_asm_file(asm_dir, choose_file=args.select)
    base_name = os.path.basename(input_file)
    file_name_without_ext = os.path.splitext(base_name)[0]
    output_file = os.path.join(hex_dir, f"{file_name_without_ext}.hex")
    assemble_file(input_file, output_file)
    print(f"Saved hex to: {output_file}")


if __name__ == '__main__':
    main()

