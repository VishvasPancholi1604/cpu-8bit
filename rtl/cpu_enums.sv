typedef enum bit[3:0] {
    NOP       = 4'b0000,
    ADD       = 4'b0001,
    SUB       = 4'b0010,
    LOAD_IMM  = 4'b0011,
    LOAD_DIR  = 4'b0100, 
    LOAD_IND  = 4'b0101, 
    STORE_DIR = 4'b0110,
    STORE_IND = 4'b0111,
    JMP       = 4'b1000,
    JZ        = 4'b1001,
    CALL      = 4'b1010,
    RET       = 4'b1011,
    PUSH      = 4'b1100,
    POP       = 4'b1101,
    HALT      = 4'b1110
} cpu_opcodes_e;

typedef enum bit[1:0] {
    REG0 = 2'b00,
    REG1 = 2'b01,
    REG2 = 2'b10,
    REG3 = 2'b11
} cpu_registers_e;

typedef enum bit[1:0] {
    CPU_IDLE,
    CPU_HALT,
    CPU_ACTIVE,
    CPU_RESET
} cpu_states_e;
