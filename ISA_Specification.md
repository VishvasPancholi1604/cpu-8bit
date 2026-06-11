# Custom 8-bit CPU ISA Specification

## 1. Architecture Overview

The Custom 8-bit CPU is a Harvard-architecture processor with separate memory spaces for instructions and data. 

- **Data Width**: 8-bit (ALU, Data Memory, and General Purpose Registers are all 8-bit wide).
- **Instruction Width**: 16-bit.
- **Address Space**: 16-bit addressing, capable of addressing $2^{16}$ (65536) words of instruction memory and $2^{16}$ bytes of data memory.
- **Endianness**: The architecture handles operations primarily as 8-bit bytes. For 16-bit values like the Program Counter and addresses, they are logically represented as continuous 16-bit fields. For operations involving 16-bit addresses stored in the register file, `REG31` holds the upper 8 bits (high byte) and `REG30` holds the lower 8 bits (low byte).

---

## 2. Register File

The CPU contains 32 general-purpose registers and a few special-purpose registers.

### 2.1 General Purpose Registers
- **REG0 - REG31**: Thirty-two 8-bit general-purpose registers available for computation and data movement.
- **Indirect Address Register**: The register pair `[REG31:REG30]` forms a 16-bit pointer used for indirect addressing. `REG31` acts as the high byte, and `REG30` acts as the low byte. Whenever an indirect memory instruction (e.g., `LOAD_IND`, `STORE_IND`, `JMP_IND`) is executed, the address accessed is read from `{REG31, REG30}`.

### 2.2 Special Function Registers
- **PC (Program Counter)**: 16-bit register holding the address of the currently executing instruction.
- **SP (Stack Pointer)**: 16-bit register pointing to the top of the stack in data memory. It is initialized to `0xFFFF` upon a hardware reset. The stack grows downwards (decrements on `PUSH`, increments on `POP`).
- **FLAGS (Status Register)**: 8-bit register containing ALU condition codes.
  - **Bit 1 (Carry - C)**: Set if the last arithmetic operation produced a carry/borrow.
  - **Bit 0 (Zero - Z)**: Set if the result of the last arithmetic or logical operation was exactly zero.
  - Bits [7:2] are reserved (currently hardcoded to 0).

---

## 3. Memory Model

- **Instruction Memory**: $64K \times 16\text{-bit}$. Stores the application code. It is addressed exclusively by the 16-bit Program Counter (PC).
- **Data Memory**: $64K \times 8\text{-bit}$. Stores variables and the stack. It is addressed via immediate addressing (direct), register indirect addressing (`[REG31:REG30]`), or the Stack Pointer (`SP`).

---

## 4. Instruction Formats

Instructions are fixed at 16-bits. The instruction decoder identifies the instruction type based on the uppermost bits, resulting in 5 distinct encoding formats.

### Format 1: Immediate & Direct Data
Used for operations involving a register and an 8-bit immediate value or direct data address.
*Condition:* `[15:14] != 00`
| 15 : 14 | 13 | 12 : 8 | 7 : 0 |
| :---: | :---: | :---: | :---: |
| Opcode | 0 | Dest/Src Register | Immediate Data |

### Format 2: Register to Register
Used for ALU operations and register-to-register transfers.
*Condition:* `[15:14] == 00` AND `[13:12] != 11`
| 15 : 14 | 13 : 10 | 9 : 5 | 4 : 0 |
| :---: | :---: | :---: | :---: |
| `00` | Opcode | Dest Register | Src Register |

### Format 3: Immediate Branch & SP Load
Used for direct jumps, calls, and loading the stack pointer with an immediate value.
*Condition:* `[15:12] == 0011` AND `[11] == 0`
| 15 : 12 | 11 : 8 | 7 : 0 |
| :---: | :---: | :---: |
| `0011` | Opcode | Immediate Address/Data |

### Format 4: Register Single-Operand
Used for shifts, stack push/pop, and indirect data memory access.
*Condition:* `[15:9] == 0011100`
| 15 : 9 | 8 : 5 | 4 : 0 |
| :---: | :---: | :---: |
| `0011100` | Opcode | Dest/Src Register |

### Format 5: Zero-Operand & Indirect Branch
Used for halted state, indirect jumps, returns, and NOP.
*Condition:* `[15:9] == 0011101`
| `[15:13]`  | `[12:8]` | `[7:0]`    |
| :--- | :--- | :--- |
| `000` | Opcode | Empty (`0x00`) |

### 4.6 Assembler Labels
The assembler supports labels for jump addresses. A label is defined by appending a colon `:` to a word on a single line, or preceding an instruction. Labels can be passed as arguments to jump and branch instructions.
Example:
```assembly
LOOP:
    ADD REG1 REG2
    JMP LOOP
```

---

## 5. Instruction Set Reference

### 5.1 Data Movement
| Mnemonic | Format | Description | Operation | Flags |
| :--- | :---: | :--- | :--- | :---: |
| `LOAD_IMM Rd, imm` | 1 | Load Immediate | `Rd <- imm` | - |
| `LOAD_DIR Rd, imm` | 1 | Load Direct | `Rd <- Mem[imm]` | - |
| `STORE_DIR Rs, imm`| 1 | Store Direct | `Mem[imm] <- Rs` | - |
| `LOAD_REG Rd, Rs`  | 2 | Load Register | `Rd <- Rs` | - |
| `LOAD_IND Rd`      | 4 | Load Indirect | `Rd <- Mem[{REG31, REG30}]` | - |
| `STORE_IND Rs`     | 4 | Store Indirect| `Mem[{REG31, REG30}] <- Rs` | - |
| `PUSH_FLAGS`       | 5 | Push Flags    | `SP <- SP - 1`; `Mem[SP] <- FLAGS` | - |
| `POP_FLAGS`        | 5 | Pop Flags     | `FLAGS <- Mem[SP]`; `SP <- SP + 1` | All |

### 5.2 ALU Operations
*All operations update the Zero (Z) flag. All operations except AND, OR, and XOR update the Carry (C) flag. CMP updates flags but does not write back to a register.*

| Mnemonic | Format | Description | Operation | Flags |
| :--- | :---: | :--- | :--- | :---: |
| `ADD Rd, Rs` | 2 | Add | `Rd <- Rd + Rs` | Z, C |
| `SUB Rd, Rs` | 2 | Subtract | `Rd <- Rd - Rs` | Z, C |
| `CMP Rd, Rs` | 2 | Compare | `Rd - Rs` (Flags only) | Z, C |
| `AND Rd, Rs` | 2 | Bitwise AND | `Rd <- Rd & Rs` | Z |
| `OR Rd, Rs`  | 2 | Bitwise OR | `Rd <- Rd | Rs` | Z |
| `XOR Rd, Rs` | 2 | Bitwise XOR | `Rd <- Rd ^ Rs` | Z |
| `LSL Rd`     | 4 | Logical Shift Left | `Rd <- Rd << 1` | Z, C |
| `LSR Rd`     | 4 | Logical Shift Right | `Rd <- Rd >> 1` | Z |
| `INC Rd`     | 4 | Increment | `Rd <- Rd + 1` | Z, C |
| `DEC Rd`     | 4 | Decrement | `Rd <- Rd - 1` | Z, C |
| `MUL Rd, Rs` | 2 | Multiply (Unimplemented) | `Rd <- Rd * Rs` | Z, C |
| `DIV Rd, Rs` | 2 | Divide (Unimplemented) | `Rd <- Rd / Rs` | Z, C |

### 5.3 Stack Operations
| Mnemonic | Format | Description | Operation | Flags |
| :--- | :---: | :--- | :--- | :---: |
| `LOAD_SP imm`     | 3 | Load SP Immediate | `SP <- imm` | - |
| `LOAD_SP_IND`     | 5 | Load SP Indirect | `SP <- {REG31, REG30}` | - |
| `PUSH Rs`         | 4 | Push to Stack | `SP <- SP - 1`; `Mem[SP] <- Rs` | - |
| `POP Rd`          | 4 | Pop from Stack | `Rd <- Mem[SP]`; `SP <- SP + 1` | - |

### 5.4 Control Flow
| Mnemonic | Format | Description | Operation | Flags |
| :--- | :---: | :--- | :--- | :---: |
| `JMP addr`     | 3 | Jump Direct | `PC <- addr` | - |
| `JZ addr`      | 3 | Jump if Zero | `if(Z == 1) PC <- addr` | - |
| `JNZ addr`     | 3 | Jump if Not Zero | `if(Z == 0) PC <- addr` | - |
| `JC addr`      | 3 | Jump if Carry | `if(C == 1) PC <- addr` | - |
| `JNC addr`     | 3 | Jump if No Carry | `if(C == 0) PC <- addr` | - |
| `CALL addr`    | 3 | Call Subroutine | `Push(PC_High)`; `Push(PC_Low)`; `PC <- addr` | - |
| `RET`          | 5 | Return from Subroutine| `PC_Low <- Pop()`; `PC_High <- Pop()` | - |
| `JMP_IND`      | 5 | Jump Indirect | `PC <- {REG31, REG30}` | - |
| `JZ_IND`       | 5 | Jump Indirect if Zero | `if(Z == 1) PC <- {REG31, REG30}` | - |
| `JNZ_IND`      | 5 | Jump Ind. if Not Zero | `if(Z == 0) PC <- {REG31, REG30}` | - |
| `JC_IND`       | 5 | Jump Indirect if Carry| `if(C == 1) PC <- {REG31, REG30}` | - |
| `JNC_IND`      | 5 | Jump Ind. if No Carry | `if(C == 0) PC <- {REG31, REG30}` | - |
| `CALL_IND`     | 5 | Call Indirect | `Push(PC_High)`; `Push(PC_Low)`; `PC <- {REG31, REG30}` | - |
| `RETI`         | 5 | Return from Interrupt | `PC_Low <- Pop()`; `PC_High <- Pop()`; `I <- 1` | - |

### 5.5 System & Interrupt Control
| Mnemonic | Format | Description | Operation | Flags |
| :--- | :---: | :--- | :--- | :---: |
| `NOP`  | 5 | No Operation | None | - |
| `HALT` | 5 | Halt CPU Execution | CPU Enters HALTED state | - |
| `SEI`  | 5 | Set Interrupt Enable | `I <- 1` | - |
| `CLI`  | 5 | Clear Interrupt Enable| `I <- 0` | - |

---

## 6. Assembly Syntax & Example

The default assembler (`sim/assembler/assembler.py`) expects a space-separated syntax structured as:
`OPCODE DEST_REG SRC_REG_OR_IMM`

### Example Program
This simple program loads 10 into `REG0`, 1 into `REG1`, and creates a decrement loop until `REG0` is zero.

```assembly
// Initialize registers
LOAD_IMM REG0 10    // REG0 = 10 (Loop counter)
LOAD_IMM REG1 1     // REG1 = 1 (Decrement value)

LOOP:
// Start of the loop
SUB REG0 REG1       // REG0 = REG0 - REG1, updates Zero flag
JNZ LOOP            // If Zero flag is 0 (REG0 != 0), jump back to LOOP

// Loop finished
HALT                // Halt the CPU
```

*Note: The assembler handles resolving the `LOOP` label to the correct memory address during compilation.*
