`define STACK_PTR_HW_RST_VAL 'hFFFF

typedef enum bit[3:0] {
    NOP       = 4'b0000,
    ALU_REG   = 4'b0001, // IMPLEMENTED
    RESERVED  = 4'b0010, // to preserve old asm hex files for now..
    LOAD_IMM  = 4'b0011, // IMPLEMENTED
    LOAD_DIR  = 4'b0100, // IMPLEMENTED 
    LOAD_IND  = 4'b0101, // IMPLEMENTED 
    STORE_DIR = 4'b0110, // IMPLEMENTED
    STORE_IND = 4'b0111, // IMPLEMENTED
    LOAD_SP   = 4'b1000,
    JMP       = 4'b1001, // IMPLEMENTED
    BCC       = 4'b1010,  // IMPLEMENTED
    CALL      = 4'b1011,
    RET       = 4'b1100,
    PUSH      = 4'b1101,
    POP       = 4'b1110,
    HALT      = 4'b1111
} cpu_opcodes_e;

typedef enum bit[3:0] {
    ADD = 4'b0000,
    SUB = 4'b0001,
    CMP = 4'b0010,
    AND = 4'b0011,
    OR  = 4'b0100,
    XOR = 4'b0101,
    LSL = 4'b0110,
    LSR = 4'b0111
} cpu_alu_operation_e;

typedef enum bit[1:0] {
    JZ  = 2'b00, // used for IF conditions
    JNZ = 2'b01, // used for IF conditions
    JC  = 2'b10, // used in FOR loop
    JNC = 2'b11 // used for loop
} cpu_jmp_type_e;

typedef enum bit[1:0] {
    REG0 = 2'b00,
    REG1 = 2'b01,
    REG2 = 2'b10,
    REG3 = 2'b11
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
