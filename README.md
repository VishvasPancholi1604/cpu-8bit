# Custom 8-Bit RISC Architecture

This repository contains a custom 8-bit, multi-cycle CPU. Built using a Harvard architecture and written in SystemVerilog, the processor comes with a dedicated Python-based assembler and simulation automation environment. 

The updated implementation features a streamlined custom instruction set architecture (ISA) designed specifically to support up to 32 general-purpose registers, accessible in every instruction.

---

## Hardware Specifications

* **Architecture Type:** Harvard (Separate buses for Instructions and Data)
* **Program Memory (ROM):** 16-bit width, 64KB depth (`65536 x 16`)
* **Data Memory (RAM):** 8-bit width, 64KB depth (`65536 x 8`)
* **General Purpose Registers:** 32 x 8-bit registers (`REG0` to `REG31`)
* **ALU Flags:** Carry (C), Zero (Z)
* **Execution Model:** Multi-cycle FSM (Fetch, Decode, Execute)

### Advanced Addressing & Stack
* **The Stack:** Includes a dedicated, hardware-managed 16-bit Stack Pointer (`stack_ptr`) supporting `PUSH`, `POP`, `CALL`, and `RET`.
* **Indirect Memory Pointer:** Because the registers are 8-bit but the memory space is 16-bit, indirect memory operations (like `LOAD_IND`, `STORE_IND`, `CALL_IND`) automatically concatenate `{REG31, REG30}` to form the 16-bit target address.

---

## Updated Instruction Set Architecture 

The new ISA utilizes hierarchical decoding to pack 5-bit register addresses and 8-bit immediates efficiently into the 16-bit instruction word.

### Bit Slicing
<img width="1725" height="849" alt="image" src="https://github.com/user-attachments/assets/f2d2c75e-8c45-41bf-b4da-ef24f2c84c38" />

### Variable Length Opcode Bifurcation
<img width="1378" height="1161" alt="image" src="https://github.com/user-attachments/assets/a30cc2af-8adb-4518-a9f0-6b6cd3567603" />

---

## Repository Structure

**Hardware (SystemVerilog):**
* `cpu.sv`: Top-level CPU wrapper integrating the datapath and control unit.
* `control_unit.sv`: Multi-cycle FSM managing execution states and data routing.
* `alu.sv`: Arithmetic Logic Unit for standard math and bitwise operations.
* `registers.sv`: 32-entry register file with synchronous writes and combinational reads.
* `instruction_decoder.sv`: Combinational logic that parses the hierarchical instruction word.
* `program_counter.sv`: Instruction pointer supporting jumps, branches, and subroutine returns.
* `cpu_memory.sv`: Parameterized RAM module used for both instruction and data memory.

**Software & Automation (Python):**
* `sim/assembler/assembler.py`: The main assembler script mapping assembly text to hex machine code.
* `sim/run.py`: Automation script for Xcelium compilation, simulation, and waveform visualization.
* `git.py`: Custom wrapper for streamlined version control, compilation checking, and code pushing.

---

## Usage Guide

### 1. Writing Assembly
Place your `.asm` text files inside the `sim/assembler/asm/` directory.

### 2. Simulation & Assembly Execution
The project uses `run.py` to seamlessly assemble your code, compile the SystemVerilog RTL, load the `.hex` file into memory, and run the simulation using Cadence Xcelium.

```bash
# Navigate to the simulation directory
cd sim/

# Compile the RTL and run the simulation using the latest .asm file
python run.py

# Select a specific .asm file, compile, simulate, and open waveforms in SimVision
python run.py --asm --waves

# Compile the RTL only (no simulation)
python run.py --compile
