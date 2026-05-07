# Custom 8-Bit RISC Architecture

This repository contains a custom 8-bit, multi-cycle CPU. Built using a Harvard architecture and written in SystemVerilog, the processor comes with a dedicated Python-based assembler. 

The updated implementation features a streamlined custom instruction set architecture (ISA) designed specially for supporting upto 32 registers accesible in every instruction.

---

## Hardware Specifications

* **Architecture Type:** Harvard (Separate buses for Instructions and Data)
* **Program Memory (ROM):** 16-bit width, 64KB depth (`65536 x 16`)
* **Data Memory (RAM):** 8-bit width, 64KB depth (`65536 x 8`)
* **General Purpose Registers:** 32 x 8-bit registers (`REG0`, `REG1`, .., `REG31`)
* **ALU Flags:** Carry (C), Zero (Z)
* **Execution Model:** Multi-cycle FSM (Fetch, Decode, Execute)

### The Stack
The CPU includes a dedicated, hardware-managed 16-bit Stack Pointer (`stack_ptr`). 
* **Operations:** Natively supports `PUSH`, `POP`, `CALL`, and `RET`.
* **Initialization:** The stack pointer can be loaded using immediate or indirect memory operations.

---

## Repository Structure

**Hardware (SystemVerilog):**
* `cpu.sv`: Top-level CPU wrapper integrating the datapath and control unit.
* `control_unit.sv`: Multi-cycle FSM managing execution states and data routing.
* `alu.sv`: Arithmetic Logic Unit for standard math and bitwise operations.
* `registers.sv`: 4-entry register file with synchronous writes and combinational reads.
* `instruction_decoder.sv`: Combinational logic that parses the instruction word.
* `program_counter.sv`: Instruction pointer supporting jumps, branches, and subroutine returns.
* `cpu_memory.sv`: Parameterized RAM module used for both instruction and data memory.

**Software (Python):**
* `sim/assembler/assembler.py`: The main assembler script.
* `sim/assembler/common_method_defines.py`: Utility functions for bit-field manipulation.
* `sim/assembler/globals.py`: Dictionary mappings for opcodes, registers, and boundaries.

## Using the Assembler

The Python assembler converts `.asm` text files into 16-bit `.hex` machine code. Ensure your `.asm` files are located inside the `sim/assembler/asm/` directory.

## Updated Instruction Set Architecture

		15	14	13	12	11	10	9	8	7	6	5	4	3	2	1	0
																	
STORE_DIR, LOAD_IMM, LOAD_DIR		"opcode
(01, 10, 11)"		NOT REQUIRED	dest/src register					IMMIDIATE BITS							
																	
LOAD_REG, ADD, SUB, CMP, AND, OR, XOR, MUL, DIV		"opcode_slice1
(00)"		"opcode_slice2
(0000, 0001, 0010, 0011, 0100, 0101, 0110, 1000)"				dest register					src register				
																	
LOAD_SP, JMP, JZ, JNZ, JC, JNC, CALL		"opcode_slice1
(00)"		"opcode_slice2
(11)"		"opcode_slice3
(0000, 0001, 0010, 0011, 0100, 0101, 0110)"				IMMIDIATE BITS							
																	
LOAD_IND, LSL, LSR, INC, DEC, PUSH, POP, STORE_IND		"opcode_slice1
(00)"		"opcode_slice2
(11)"		"opcode_
slice3
(1)"	"opcode_slice4
(00)"		"opcode_slice5
(0000, 0001, 0010, 0011, 0100, 0101, 0110, 0111)"				dest/src register				
																	
NOP, LOAD_SP_IND, JMP_IND, JZ_IND, JNZ_IND, JC_IND, JNC_IND, CALL_IND, RET, HALT		"opcode_slice1
(00)"		"opcode_slice2
(11)"		"opcode_
slice3
(1)"	"opcode_slice4
(01)"		"opcode_slice5
(0000, 0001, 0010, 0011, 0100, 0101, 0110, 0111, 1000, 1001)"				NOT REQUIRED				
<img width="1725" height="849" alt="image" src="https://github.com/user-attachments/assets/f2d2c75e-8c45-41bf-b4da-ef24f2c84c38" />

no of instructions	"opcode
binary"	opcode	"dest reg
(5bit)"	"src reg
(5bit)"	"imm bits
(8bit)"	"opcode
size"	"dest reg
size"	"src reg
size"	"imm  bits
size"	"dreg+sreg+imm
size"
"10
(4bits instruction required)"	b00_111010000	NOP	no	no	no	16	0	0	0	0
	b00_111010001	LOAD_SP_IND	no	no	no	16	0	0	0	0
	b00_111010010	JMP_IND	no	no	no	16	0	0	0	0
	b00_111010011	JZ_IND	no	no	no	16	0	0	0	0
	b00_111010100	JNZ_IND	no	no	no	16	0	0	0	0
	b00_111010101	JC_IND	no	no	no	16	0	0	0	0
	b00_111010110	JNC_IND	no	no	no	16	0	0	0	0
	b00_111010111	CALL_IND	no	no	no	16	0	0	0	0
	b00_111011000	RET	no	no	no	16	0	0	0	0
	b00_111011001	HALT	no	no	no	16	0	0	0	0
"8
(3bits instruction required)"	b00_111000000	LOAD_IND	yes	no	no	11	5	0	0	5
	b00_111000001	LSL	yes	no	no	11	5	0	0	5
	b00_111000010	LSR	yes	no	no	11	5	0	0	5
	b00_111000011	INC	yes	no	no	11	5	0	0	5
	b00_111000100	DEC	yes	no	no	11	5	0	0	5
	b00_111000101	PUSH	yes	no	no	11	5	0	0	5
	b00_111000110	POP	yes	no	no	11	5	0	0	5
	b00_111000111	STORE_IND	no	yes	no	11	0	5	0	5
"7
(3bits instruction required)"	b00_110000	LOAD_SP	no	no	yes	8	0	0	8	8
	b00_110001	JMP	no	no	yes	8	0	0	8	8
	b00_110010	JZ	no	no	yes	8	0	0	8	8
	b00_110011	JNZ	no	no	yes	8	0	0	8	8
	b00_110100	JC	no	no	yes	8	0	0	8	8
	b00_110101	JNC	no	no	yes	8	0	0	8	8
	b00_110110	CALL	no	no	yes	8	0	0	8	8
"9
(4bits instruction required)"	b00_1000	LOAD_REG	yes	yes	no	6	5	5	0	10
	b00_0000	ADD	yes	yes	no	6	5	5	0	10
	b00_0001	SUB	yes	yes	no	6	5	5	0	10
	b00_0010	CMP	yes	yes	no	6	5	5	0	10
	b00_0011	AND	yes	yes	no	6	5	5	0	10
	b00_0100	OR	yes	yes	no	6	5	5	0	10
	b00_0101	XOR	yes	yes	no	6	5	5	0	10
	b00_0110	MUL	yes	yes	no	6	5	5	0	10
	b00_0111	DIV	yes	yes	no	6	5	5	0	10
"3
(2bits instruction required)"	b01	STORE_DIR	no	yes	yes	3	0	5	8	13
	b10	LOAD_IMM	yes	no	yes	3	5	0	8	13
	b11	LOAD_DIR	yes	no	yes	3	5	0	8	13
<img width="1378" height="1161" alt="image" src="https://github.com/user-attachments/assets/a30cc2af-8adb-4518-a9f0-6b6cd3567603" />

### Command Line Execution

```bash
# Automatically compile the most recently modified .asm file
python assembler.py

# Select a specific .asm file from an interactive list
python assembler.py --select


