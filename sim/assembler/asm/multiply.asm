LOAD_IMM REG0 0x0 // store output
LOAD_IMM REG1 0x2 // value to be multiplied
LOAD_IMM REG2 0x5 // multiplier number
LOAD_IMM REG3 0x1 // decrement constant
ADD REG0 REG1
SUB REG2 REG3
JNZ 0x4
STORE_DIR REG0 0 
