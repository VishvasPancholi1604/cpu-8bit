`define STACK_PTR_HW_RST_VAL 'hFFFF

typedef enum bit[5:0] {
    NOP         = 6'b000000,
    LOAD_SP_IND = 6'b000001,
    JMP_IND     = 6'b000010,
    JZ_IND      = 6'b000011,
    JNZ_IND     = 6'b000100,
    JC_IND      = 6'b000101,
    JNC_IND     = 6'b000110,
    CALL_IND    = 6'b000111,
    RET         = 6'b001000,
    HALT        = 6'b001001,
    LOAD_IND    = 6'b001010,
    LSL         = 6'b001011,
    LSR         = 6'b001100,
    INC         = 6'b001101,
    DEC         = 6'b001110,
    PUSH        = 6'b001111,
    POP         = 6'b010000,
    STORE_IND   = 6'b010001,
    LOAD_SP     = 6'b010010,
    JMP         = 6'b010011,
    JZ          = 6'b010100,
    JNZ         = 6'b010101,
    JC          = 6'b010110,
    JNC         = 6'b010111,
    CALL        = 6'b011000,
    LOAD_REG    = 6'b011001,
    ADD         = 6'b011010,
    SUB         = 6'b011011,
    CMP         = 6'b011100,
    AND         = 6'b011101,
    OR          = 6'b011110,
    XOR         = 6'b011111,
    MUL         = 6'b100000,
    DIV         = 6'b100001,
    STORE_DIR   = 6'b100010,
    LOAD_IMM    = 6'b100011,
    LOAD_DIR    = 6'b100100
} cpu_opcodes_e;

typedef enum bit[4:0] {
    REG0   = 5'b00000,
    REG1   = 5'b00001,
    REG2   = 5'b00010,
    REG3   = 5'b00011,
    REG4   = 5'b00100,
    REG5   = 5'b00101,
    REG6   = 5'b00110,
    REG7   = 5'b00111,
    REG8   = 5'b01000,
    REG9   = 5'b01001,
    REG10  = 5'b01010,
    REG11  = 5'b01011,
    REG12  = 5'b01100,
    REG13  = 5'b01101,
    REG14  = 5'b01110,
    REG15  = 5'b01111,
    REG16  = 5'b10000,
    REG17  = 5'b10001,
    REG18  = 5'b10010,
    REG19  = 5'b10011,
    REG20  = 5'b10100,
    REG21  = 5'b10101,
    REG22  = 5'b10110,
    REG23  = 5'b10111,
    REG24  = 5'b11000,
    REG25  = 5'b11001,
    REG26  = 5'b11010,
    REG27  = 5'b11011,
    REG28  = 5'b11100,
    REG29  = 5'b11101,
    REG30  = 5'b11110,
    REG31  = 5'b11111
} cpu_registers_e;

typedef enum bit[2:0] {
    FETCH   = 3'b000,
    DECODE  = 3'b001,
    EXECUTE = 3'b010,
    CALL_HI = 3'b011,
    CALL_LO = 3'b100,
    RET_HI  = 3'b101,
    RET_LO  = 3'b110,
    HALTED  = 3'b111
} cpu_states_e;

typedef enum bit[3:0] {
    ALU_ADD = 4'b0000,
    ALU_SUB = 4'b0001,
    ALU_CMP = 4'b0010,
    ALU_AND = 4'b0011,
    ALU_OR  = 4'b0100,
    ALU_XOR = 4'b0101,
    ALU_MUL = 4'b0110,
    ALU_DIV = 4'b0111,
    ALU_LSL = 4'b1000,
    ALU_LSR = 4'b1001,
    ALU_INC = 4'b1010,
    ALU_DEC = 4'b1011
} cpu_alu_operation_e;

typedef enum bit[1:0] {
    BCC_JZ  = 2'b00, 
    BCC_JNZ = 2'b01, 
    BCC_JC  = 2'b10, 
    BCC_JNC = 2'b11 
} cpu_jmp_type_e;
