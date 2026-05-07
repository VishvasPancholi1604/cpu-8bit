# Custom 8-Bit RISC Architecture

This repository contains a custom 8-bit, multi-cycle CPU. Built using a Harvard architecture and written in SystemVerilog, the processor comes with a dedicated Python-based assembler. 

The current implementation features a streamlined custom instruction set architecture (ISA) designed around a 4-register core, focusing on a straightforward instruction format.

---

## Hardware Specifications

* **Architecture Type:** Harvard (Separate buses for Instructions and Data)
* **Program Memory (ROM):** 16-bit width, 64KB depth (`65536 x 16`)
* **Data Memory (RAM):** 8-bit width, 64KB depth (`65536 x 8`)
* **General Purpose Registers:** 4 x 8-bit registers (`REG0`, `REG1`, `REG2`, `REG3`)
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

---

## Current Instruction Format

The current ISA uses a strict 16-bit instruction word. To manage operations between the 4 general-purpose registers and memory, the instruction word is broken down into fixed fields:

* **Opcode:** Defines the operation (e.g., ADD, JMP, LOAD).
* **Destination Register:** Selects the target register for the result.
* **Source Register:** Selects the secondary register for the operation.
* **Immediate Bits:** Holds constant values or memory addresses.

---

## Using the Assembler

The Python assembler converts `.asm` text files into 16-bit `.hex` machine code. Ensure your `.asm` files are located inside the `sim/assembler/asm/` directory.

### Command Line Execution

```bash
# Automatically compile the most recently modified .asm file
python assembler.py

# Select a specific .asm file from an interactive list
python assembler.py --select
