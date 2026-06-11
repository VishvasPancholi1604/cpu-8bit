from common_method_defines import *
from globals import *


def parse_int(val_str, labels={}):
    if val_str in labels:
        return labels[val_str]
    if val_str.upper().startswith("0X"):
        return int(val_str, 16)
    return int(val_str)


def parse_instruction(l_instr, labels={}):
    instruction_str = l_instr.strip().replace(',', ' ')
    instruction_str = ' '.join(instruction_str.split())
    if not instruction_str:
        return 0
    keywords = instruction_str.split(' ')
    instr_opcode = keywords[0].upper()
    if instr_opcode not in INSTRUCTION_MAP:
        raise ValueError(f"Invalid opcode: {instr_opcode}")
    info = INSTRUCTION_MAP[instr_opcode]
    fmt = info["fmt"]
    op = info["op"]
    hex_val = 0
    if fmt == 1:
        hex_val = set_bit_field(hex_val, 15, 14, op)
        hex_val = set_bit_field(hex_val, 13, 13, 0)
        hex_val = set_bit_field(hex_val, 12, 8, cpu_registers[keywords[1].upper()])
        hex_val = set_bit_field(hex_val, 7, 0, parse_int(keywords[2], labels))
    elif fmt == 2:
        hex_val = set_bit_field(hex_val, 15, 14, 0b00)
        hex_val = set_bit_field(hex_val, 13, 10, op)
        hex_val = set_bit_field(hex_val, 9, 5, cpu_registers[keywords[1].upper()])
        hex_val = set_bit_field(hex_val, 4, 0, cpu_registers[keywords[2].upper()])
    elif fmt == 3:
        hex_val = set_bit_field(hex_val, 15, 12, 0b0011)
        hex_val = set_bit_field(hex_val, 11, 8, op)
        hex_val = set_bit_field(hex_val, 7, 0, parse_int(keywords[1], labels))
    elif fmt == 4:
        hex_val = set_bit_field(hex_val, 15, 9, 0b0011100)
        hex_val = set_bit_field(hex_val, 8, 5, op)
        hex_val = set_bit_field(hex_val, 4, 0, cpu_registers[keywords[1].upper()])
    elif fmt == 5:
        hex_val = set_bit_field(hex_val, 15, 9, 0b0011101)
        hex_val = set_bit_field(hex_val, 8, 5, op)
        hex_val = set_bit_field(hex_val, 4, 0, 0b00000)

    return hex_val


def assemble_file(input_file, output_file):
    labels = {}
    instructions = []
    
    # Pass 1: Parse labels and map line numbers
    pc = 0
    with open(input_file, 'r') as i_file:
        for line in i_file:
            line = line.split('//')[0].strip()
            if not line:
                continue
            if ':' in line:
                parts = line.split(':')
                label = parts[0].strip()
                labels[label] = pc
                rest = parts[1].strip()
                if rest:
                    instructions.append(rest)
                    pc += 1
            else:
                instructions.append(line)
                pc += 1

    # Pass 2: Generate machine code
    machine_codes = []
    for instr in instructions:
        machine_code = parse_instruction(instr, labels)
        machine_codes.append(machine_code)

    with open(output_file, 'w') as o_file:
        m_code = [f"{machine_code:04X}" for machine_code in machine_codes]
        o_file.write('\n'.join(m_code))


if __name__ == "__main__":
    assemble_file(r'/u/pancholv/Desktop/sv_uvm/cpu/sim/assembler/asm/multiply.asm', r'/u/pancholv/Desktop/sv_uvm/cpu/sim/assembler/hex/multiply.hex')
