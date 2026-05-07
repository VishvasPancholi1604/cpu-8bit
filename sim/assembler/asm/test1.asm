LOAD_SP 0xFF          // Init stack pointer to top of memory
LOAD_IMM REG0 0x00    // Clear REG0
LOAD_IMM REG1 0x0A    // Load 10 into REG1
LOAD_IMM REG2 0x05    // Load 5 into REG2
STORE_DIR REG1 0x20   // Store REG1 (0x0A) into memory address 0x20
LOAD_DIR REG3 0x20    // Load value from memory address 0x20 into REG3
LOAD_REG REG4 REG1    // Copy REG1 to REG4
ADD REG1 REG2         // REG1 = 10 + 5 = 15
SUB REG1 REG2         // REG1 = 15 - 5 = 10
MUL REG1 REG2         // REG1 = 10 * 5 = 50
DIV REG1 REG2         // REG1 = 50 / 5 = 10
AND REG1 REG2         // REG1 = REG1 & REG2
OR REG1 REG2          // REG1 = REG1 | REG2
XOR REG1 REG2         // REG1 = REG1 ^ REG2
CMP REG1 REG1         // Compare REG1 with itself (Sets Zero Flag Z=1)
INC REG1              // Increment REG1
DEC REG2              // Decrement REG2
LSL REG1              // Logical Shift Left REG1
LSR REG2              // Logical Shift Right REG2
LOAD_IMM REG31 0x00   // Set Indirect Pointer High Byte (0x00)
LOAD_IMM REG30 0x50   // Set Indirect Pointer Low Byte (0x50) -> Address: 0x0050
STORE_IND REG1        // Store REG1 data into memory at address 0x0050
LOAD_IND REG5         // Load data from memory at address 0x0050 into REG5
PUSH REG1             // Push REG1 onto the stack
POP REG6              // Pop top of stack into REG6
CALL 0x40             // Call subroutine at immediate address 0x40
JZ 0x41               // Jump if Zero (Z=1) to 0x41
JNZ 0x42              // Jump if Not Zero (Z=0) to 0x42
JC 0x43               // Jump if Carry (C=1) to 0x43
JNC 0x44              // Jump if Not Carry (C=0) to 0x44
JMP 0x45              // Unconditional jump to 0x45
LOAD_IMM REG31 0x00   // Set Indirect Pointer High Byte
LOAD_IMM REG30 0x60   // Set Indirect Pointer Low Byte -> Address: 0x0060
LOAD_SP_IND           // Load Stack Pointer with 0x0060
CALL_IND              // Call subroutine at 0x0060
JZ_IND                // Jump indirectly if Zero to 0x0060
JNZ_IND               // Jump indirectly if Not Zero to 0x0060
JC_IND                // Jump indirectly if Carry to 0x0060
JNC_IND               // Jump indirectly if Not Carry to 0x0060
JMP_IND               // Unconditional indirect jump to 0x0060
NOP                   // No Operation
RET                   // Return from subroutine
HALT                  // Halt CPU execution
