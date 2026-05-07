cpu_registers = {f"REG{i}": i for i in range(32)}

INSTRUCTION_MAP = {
    # FORMAT 1 (2bit opcode): [15:14]=opcode, [13]=0, [12:8]=reg, [7:0]=imm
    "STORE_DIR": {"fmt": 1, "op": 0b01},
    "LOAD_IMM": {"fmt": 1, "op": 0b10},
    "LOAD_DIR": {"fmt": 1, "op": 0b11},
    # FORMAT 2 (6bit prefix 00): [15:14]=00, [13:10]=opcode, [9:5]=dreg, [4:0]=Sreg
    "ADD": {"fmt": 2, "op": 0b0000},
    "SUB": {"fmt": 2, "op": 0b0001},
    "CMP": {"fmt": 2, "op": 0b0010},
    "AND": {"fmt": 2, "op": 0b0011},
    "OR": {"fmt": 2, "op": 0b0100},
    "XOR": {"fmt": 2, "op": 0b0101},
    "MUL": {"fmt": 2, "op": 0b0110},
    "DIV": {"fmt": 2, "op": 0b0111},
    "LOAD_REG": {"fmt": 2, "op": 0b1000},
    # FORMAT 3 (8bit prefix 00_11): [15:12]=0011, [11:8]=opcode, [7:0]=imm
    "LOAD_SP": {"fmt": 3, "op": 0b0000},
    "JMP": {"fmt": 3, "op": 0b0001},
    "JZ": {"fmt": 3, "op": 0b0010},
    "JNZ": {"fmt": 3, "op": 0b0011},
    "JC": {"fmt": 3, "op": 0b0100},
    "JNC": {"fmt": 3, "op": 0b0101},
    "CALL": {"fmt": 3, "op": 0b0110},
    # FORMAT 4 (11bit prefix 00_11100): [15:9]=0011100, [8:5]=opcode, [4:0]=reg
    "LOAD_IND": {"fmt": 4, "op": 0b0000},
    "LSL": {"fmt": 4, "op": 0b0001},
    "LSR": {"fmt": 4, "op": 0b0010},
    "INC": {"fmt": 4, "op": 0b0011},
    "DEC": {"fmt": 4, "op": 0b0100},
    "PUSH": {"fmt": 4, "op": 0b0101},
    "POP": {"fmt": 4, "op": 0b0110},
    "STORE_IND": {"fmt": 4, "op": 0b0111},
    # FORMAT 5 (16bit prefix 00_11101): [15:9]=0011101, [8:5]=opcode, [4:0]=00000
    "NOP": {"fmt": 5, "op": 0b0000},
    "LOAD_SP_IND": {"fmt": 5, "op": 0b0001},
    "JMP_IND": {"fmt": 5, "op": 0b0010},
    "JZ_IND": {"fmt": 5, "op": 0b0011},
    "JNZ_IND": {"fmt": 5, "op": 0b0100},
    "JC_IND": {"fmt": 5, "op": 0b0101},
    "JNC_IND": {"fmt": 5, "op": 0b0110},
    "CALL_IND": {"fmt": 5, "op": 0b0111},
    "RET": {"fmt": 5, "op": 0b1000},
    "HALT": {"fmt": 5, "op": 0b1001},
}
