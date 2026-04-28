module instruction_decoder(
    input  logic[15:0]     instruction,
    output cpu_opcodes_e   opcode,
    output cpu_registers_e src_reg,
    output cpu_registers_e dest_reg,
    output logic[7:0]      immediate_data
);
    assign opcode = cpu_opcodes_e'(instruction[15:12]);
    assign dest_reg = cpu_registers_e'(instruction[11:10]);
    assign src_reg = cpu_registers_e'(instruction[9:8]);
    assign immediate_data = instruction[7:0];
endmodule
