// Initialization
JMP MAIN
JMP ISR_0
JMP ISR_1
NOP
NOP
NOP
NOP
NOP
NOP

MAIN:
LOAD_SP 0xFF // Set stack pointer
LOAD_IMM REG10 0 // Main loop counter
LOAD_IMM REG11 1 // Increment value
LOAD_IMM REG12 0 // ISR 0 counter
LOAD_IMM REG13 0 // ISR 1 counter
SEI // Enable interrupts

LOOP:
ADD REG10 REG11 // Increment main loop counter
NOP // Wait
JMP LOOP

ISR_0:
PUSH_FLAGS // Save status
PUSH REG0 // Save REG0
LOAD_IMM REG0 1 // Load 1
ADD REG12 REG0 // Increment ISR 0 counter
POP REG0 // Restore REG0
POP_FLAGS // Restore status
RETI // Return from interrupt

ISR_1:
PUSH_FLAGS // Save status
PUSH REG0 // Save REG0
LOAD_IMM REG0 1 // Load 1
ADD REG13 REG0 // Increment ISR 1 counter
POP REG0 // Restore REG0
POP_FLAGS // Restore status
RETI // Return from interrupt
