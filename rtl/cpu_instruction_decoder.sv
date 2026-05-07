module instruction_decoder(
    input  logic[15:0]     i_cpu_instruction,
    output cpu_opcodes_e   o_instr_opcode,
    output cpu_registers_e o_instr_src_reg,
    output cpu_registers_e o_instr_dest_reg,
    output logic[7:0]      o_instr_imm_data
);
    assign o_instr_opcode = cpu_opcodes_e'(i_cpu_instruction[15:12]);
    assign o_instr_dest_reg = cpu_registers_e'(i_cpu_instruction[11:10]);
    assign o_instr_src_reg = cpu_registers_e'(i_cpu_instruction[9:8]);
    assign o_instr_imm_data = i_cpu_instruction[7:0];
endmodule
