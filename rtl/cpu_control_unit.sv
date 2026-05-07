module control_unit(
    input logic i_clk,
    input logic i_rst_n,
    input cpu_opcodes_e i_instr_opcode,
    input cpu_alu_operation_e i_instr_alu_operation,
    input cpu_jmp_type_e i_instr_jmp_operation,
    input logic[7:0] i_status_reg,
    output logic o_pc_count_en,
    output logic o_reg_file_write_en,
    output logic o_reg_bus_ctrl,  // 0 will write ALU result to register file
    output logic o_reg_bus_direct, // 1 will write immidiate bits to register file, 0 will write from data memory output
    output logic o_status_flag_update_en,
    output logic o_data_mem_wr_en,
    output logic o_data_mem_wr_ind_en, // 1: addr={reg3,reg2}, 0: addr=immidiate bits
    output logic o_pc_load_en,
    output logic o_load_stack_en,
    output logic o_decr_stack,
    output logic o_incr_stack,
    output logic o_fetch_instr_en,
    output logic[1:0] o_pc_field_sel,
    output logic o_halt_en
);
    // DEPRICATED
    cpu_states_e current_state, next_state;
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            current_state <= FETCH;
        end else begin
            current_state <= next_state; 
        end
    end

    always_comb begin
        case (current_state)
            FETCH: next_state = DECODE;
            DECODE: begin
                case (i_instr_opcode)
                    CALL: next_state = CALL_HI;
                    RET: next_state = RET_LO;
                    default: next_state = EXECUTE;
                endcase
            end
            EXECUTE: begin
                case (i_instr_opcode)
                    HALT: next_state = HALTED;
                    default: next_state = FETCH;
                endcase
            end
            CALL_HI: next_state = CALL_LO;
            CALL_LO: next_state = EXECUTE;
            RET_LO: next_state = RET_HI;
            RET_HI: next_state = EXECUTE;
            HALTED: next_state = HALTED;
            default: next_state = FETCH;
        endcase
    end

    always_comb begin
        o_pc_count_en = 0;
        o_reg_file_write_en = 0;
        o_halt_en = 0;
        o_reg_bus_ctrl = 0;
        o_reg_bus_direct = 0;
        o_status_flag_update_en = 0;
        o_data_mem_wr_en = 0;
        o_data_mem_wr_ind_en = 0;
        o_pc_load_en = 0;
        o_load_stack_en = 0;
        o_decr_stack = 0;
        o_incr_stack = 0;
        o_fetch_instr_en = 0;
        o_pc_field_sel = 2'b0;
        case (current_state)
            FETCH: begin
                o_pc_count_en = 1;
                o_fetch_instr_en = 1;
            end
            DECODE: begin
                // necessary since register file needs one clock cycle to update register values.
            end
            EXECUTE: begin
                case (i_instr_opcode)
                    LOAD_IMM: begin
                        o_reg_file_write_en = 1;
                        o_reg_bus_ctrl = 1;
                        o_reg_bus_direct = 1;
                    end
                    LOAD_DIR: begin
                        o_reg_file_write_en = 1;
                        o_reg_bus_ctrl = 1;
                        o_reg_bus_direct = 0;
                        o_data_mem_wr_ind_en = 0;
                    end
                    LOAD_IND: begin
                        o_reg_file_write_en = 1;
                        o_reg_bus_ctrl = 1;
                        o_reg_bus_direct = 0;
                        o_data_mem_wr_ind_en = 1;
                    end
                    ALU_REG: begin
                        o_reg_file_write_en = (i_instr_alu_operation != CMP) ? 1 : 0;
                        o_status_flag_update_en = 1;
                    end
                    STORE_DIR: begin
                        o_data_mem_wr_en = 1;
                    end
                    STORE_IND: begin
                        o_data_mem_wr_en = 1;
                        o_data_mem_wr_ind_en = 1;
                    end
                    JMP: begin
                        o_pc_load_en = 1;
                    end
                    BCC: begin
                        case (i_instr_jmp_operation)
                            JZ  : o_pc_load_en = (i_status_reg[0]!=0);
                            JNZ : o_pc_load_en = (i_status_reg[0]==0);
                            JC  : o_pc_load_en = (i_status_reg[1]!=0);
                            JNC : o_pc_load_en = (i_status_reg[1]==0);
                        endcase
                    end
                    LOAD_SP: begin
                        o_load_stack_en = 1;
                    end
                    PUSH: begin
                        o_decr_stack = 1;
                        o_data_mem_wr_en = 1;
                    end
                    POP: begin
                        o_incr_stack = 1;
                        o_data_mem_wr_en = 1;
                        o_reg_file_write_en = 1;
                        o_reg_bus_ctrl = 1;
                        o_reg_bus_direct = 0;
                    end
                    CALL, RET: begin
                        o_pc_load_en = 1;
                        o_pc_field_sel[1] = (i_instr_opcode==RET) ? 1 : 0;
                    end
                    HALT: begin
                        o_halt_en = 1;
                    end
                endcase
            end
            CALL_HI, CALL_LO: begin
                o_data_mem_wr_en = 1;
                o_decr_stack = 1;
                o_pc_field_sel = (current_state == CALL_HI) ? 2'b11 : 2'b10;
            end
            RET_LO, RET_HI: begin
                o_incr_stack = 1;
                o_pc_field_sel = (current_state == RET_LO) ? 2'b10 : 2'b11;
            end
        endcase
    end
endmodule
