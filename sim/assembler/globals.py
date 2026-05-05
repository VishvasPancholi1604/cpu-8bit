cpu_opcodes = {
    "NOP": 0b0000,
    "ALU_REG": 0b0001,
    "RESERVED": 0b0010,
    "LOAD_IMM": 0b0011,
    "LOAD_DIR": 0b0100,
    "LOAD_IND": 0b0101,
    "STORE_DIR": 0b0110,
    "STORE_IND": 0b0111,
    "LOAD_SP": 0b1000,
    "JMP": 0b1001,
    "BCC": 0b1010,
    "CALL": 0b1011,
    "RET": 0b1100,
    "PUSH": 0b1101,
    "POP": 0b1110,
    "HALT": 0b1111
}
cpu_alu_operation = {
    "ADD": 0b0000,
    "SUB": 0b0001,
    "CMP": 0b0010,
    "AND": 0b0011,
    "OR": 0b0100,
    "XOR": 0b0101,
    "LSL": 0b0110,
    "LSR": 0b0111
}
cpu_jmp_type = {
    "JZ": 0b00,
    "JNZ": 0b01,
    "JC": 0b10,
    "JNC": 0b11
}
cpu_registers = {
    "REG0": 0b00,
    "REG1": 0b01,
    "REG2": 0b10,
    "REG3": 0b11
}
cpu_states = {
    "FETCH": 0b000,
    "DECODE": 0b001,
    "EXECUTE": 0b010,
    "CALL_HI": 0b011,
    "CALL_LO": 0b100,
    "RET_HI": 0b101,
    "RET_LO": 0b110,
    "HALTED": 0b111
}

boundaries = {
    "opcode": {"msb": 15, "lsb": 12},
    "dreg": {"msb": 11, "lsb": 10},
    "sreg": {"msb": 9, "lsb": 8},
    "imm_bits": {"msb": 7, "lsb":0},
    "alu": {"msb": 3,"lsb": 0},
    "bcc": {"msb": 9,"lsb": 8}
}

