module instruction_decoder(
    input  logic[15:0]     i_cpu_instruction,
    output cpu_opcodes_e   o_instr_opcode,
    output cpu_registers_e o_instr_src_reg,
    output cpu_registers_e o_instr_dest_reg,
    output logic[7:0]      o_instr_imm_data
);
    always_comb begin
        o_instr_opcode = NOP;
        o_instr_dest_reg = REG0;
        o_instr_src_reg = REG0;
        o_instr_imm_data = 0;
        if(i_cpu_instruction[15:14] != 'b00) begin
            case (i_cpu_instruction[15:14])
                2'b01: o_instr_opcode = STORE_DIR;
                2'b10: o_instr_opcode = LOAD_IMM;
                2'b11: o_instr_opcode = LOAD_DIR;
            endcase
            o_instr_imm_data = i_cpu_instruction[7:0];
            o_instr_dest_reg = cpu_registers_e'(i_cpu_instruction[12:8]);
        end else begin
            if(i_cpu_instruction[13:12] != 2'b11) begin
                case (i_cpu_instruction[13:10])
                    4'b0000: o_instr_opcode = ADD;
                    4'b0001: o_instr_opcode = SUB;
                    4'b0010: o_instr_opcode = CMP;
                    4'b0011: o_instr_opcode = AND;
                    4'b0100: o_instr_opcode = OR;
                    4'b0101: o_instr_opcode = XOR;
                    4'b0110: o_instr_opcode = MUL;
                    4'b0111: o_instr_opcode = DIV;
                    4'b1000: o_instr_opcode = LOAD_REG; // still have 7 instruction space here
                    default: $display("invalid value selected: 'b%4b", i_cpu_instruction[13:10]);
                endcase
                o_instr_dest_reg = cpu_registers_e'(i_cpu_instruction[9:5]);
                o_instr_src_reg = cpu_registers_e'(i_cpu_instruction[4:0]);
            end else begin
                if(i_cpu_instruction[11] == 1'b0) begin
                    case (i_cpu_instruction[10:8])
                        3'b000: o_instr_opcode = LOAD_SP;
                        3'b001: o_instr_opcode = JMP;
                        3'b010: o_instr_opcode = JZ;
                        3'b011: o_instr_opcode = JNZ;
                        3'b100: o_instr_opcode = JC;
                        3'b101: o_instr_opcode = JNC;
                        3'b110: o_instr_opcode = CALL; // still have 1 instruction space here
                        default: $display("invalid value selected: 'b%3b", i_cpu_instruction[10:8]);
                    endcase
                    o_instr_imm_data = i_cpu_instruction[7:0];
                end else begin
                    if(i_cpu_instruction[10:9] == 2'b00) begin
                        case (i_cpu_instruction[8:5])
                            4'b0000: o_instr_opcode = LOAD_IND;
                            4'b0001: o_instr_opcode = LSL;
                            4'b0010: o_instr_opcode = LSR;
                            4'b0011: o_instr_opcode = INC;
                            4'b0100: o_instr_opcode = DEC;
                            4'b0101: o_instr_opcode = PUSH;
                            4'b0110: o_instr_opcode = POP;
                            4'b0111: o_instr_opcode = STORE_IND; // still have 8 instruction space here
                            default: $display("invalid value selected: 'b%4b", i_cpu_instruction[8:5]);
                        endcase
                        o_instr_dest_reg = cpu_registers_e'(i_cpu_instruction[4:0]);
                    end else if(i_cpu_instruction[10:9] == 2'b01) begin
                        case (i_cpu_instruction[8:5])
                            4'b0000: o_instr_opcode = NOP;
                            4'b0001: o_instr_opcode = LOAD_SP_IND;
                            4'b0010: o_instr_opcode = JMP_IND;
                            4'b0011: o_instr_opcode = JZ_IND;
                            4'b0100: o_instr_opcode = JNZ_IND;
                            4'b0101: o_instr_opcode = JC_IND;
                            4'b0110: o_instr_opcode = JNC_IND;
                            4'b0111: o_instr_opcode = CALL_IND;
                            4'b1000: o_instr_opcode = RET;
                            4'b1001: o_instr_opcode = HALT; // still have 6 instruction space her
                            default: $display("invalid value selected: 'b%4b", i_cpu_instruction[8:5]);
                        endcase
                    end else begin
                        $display("invalid value selected: 'b%2b", i_cpu_instruction[10:9]);
                    end
                end
            end
        end
    end
endmodule
