module control_unit(
    input logic i_clk,
    input logic i_rst_n,
    input cpu_opcodes_e i_instr_opcode,
    input logic[7:0] i_status_reg,
    output cpu_alu_operation_e o_instr_alu_operation,
    output logic o_pc_count_en,
    output logic o_reg_file_write_en,
    output logic o_reg_bus_ctrl,
    output logic o_reg_bus_direct,
    output logic o_ctrl_reg_file_transfer,
    output logic o_status_flag_update_en,
    output logic o_data_mem_wr_en,
    output logic o_data_mem_wr_ind_en,
    output logic o_pc_load_en,
    output logic o_load_stack_en,
    output logic o_decr_stack,
    output logic o_incr_stack,
    output logic o_fetch_instr_en,
    output logic o_load_stack_ind_en,
    output logic o_pc_load_ind_en,
    output logic[1:0] o_pc_field_sel,
    output logic o_halt_en
);
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
                    CALL, CALL_IND: next_state = CALL_HI;
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
        o_ctrl_reg_file_transfer = 0;
        o_load_stack_ind_en = 0;
        o_pc_load_ind_en = 0;
        o_pc_field_sel = 2'b0;
        o_instr_alu_operation = ALU_ADD;
        case (current_state)
            FETCH: begin
                o_pc_count_en = 1;
                o_fetch_instr_en = 1;
            end
            DECODE: begin
            end
            EXECUTE: begin
                case (i_instr_opcode)
                    NOP: begin
                    end
                    LOAD_IMM: begin
                        o_reg_bus_ctrl = 1;
                        o_reg_file_write_en = 1;
                        o_reg_bus_direct = 0;
                    end
                    LOAD_DIR: begin
                        o_reg_bus_ctrl = 1;
                        o_reg_file_write_en = 1;
                        o_reg_bus_direct = 1;
                        o_data_mem_wr_ind_en = 0;
                    end
                    LOAD_REG: begin
                        o_reg_bus_ctrl = 1;
                        o_reg_file_write_en = 1;
                        o_ctrl_reg_file_transfer = 1;
                    end
                    STORE_DIR: begin
                        o_data_mem_wr_en = 1;
                        o_data_mem_wr_ind_en = 0;
                        o_pc_field_sel[1] = 0;
                    end
                    ADD, SUB, CMP, AND, OR, XOR, MUL, DIV, LSL, LSR, INC, DEC: begin
                        case (i_instr_opcode)
                            ADD: o_instr_alu_operation = ALU_ADD;
                            SUB: o_instr_alu_operation = ALU_SUB;
                            CMP: o_instr_alu_operation = ALU_CMP;
                            AND: o_instr_alu_operation = ALU_AND;
                            OR : o_instr_alu_operation = ALU_OR;
                            XOR: o_instr_alu_operation = ALU_XOR;
                            MUL: o_instr_alu_operation = ALU_MUL;
                            DIV: o_instr_alu_operation = ALU_DIV;
                            LSL: o_instr_alu_operation = ALU_LSL;
                            LSR: o_instr_alu_operation = ALU_LSR;
                            INC: o_instr_alu_operation = ALU_INC;
                            DEC: o_instr_alu_operation = ALU_DEC;
                        endcase
                        o_reg_file_write_en = (i_instr_opcode != CMP) ? 1 : 0;
                        o_status_flag_update_en = 1;
                    end
                    LOAD_SP, LOAD_SP_IND: begin
                        o_load_stack_en = 1;
                        o_load_stack_ind_en = (i_instr_opcode == LOAD_SP_IND) ? 1 :0;
                    end
                    JMP, JZ, JNZ, JC, JNC, JMP_IND, JZ_IND, JNZ_IND, JC_IND, JNC_IND: begin
                        case (i_instr_opcode)
                            JMP, JMP_IND: o_pc_load_en = 1;
                            JZ , JZ_IND : o_pc_load_en = (i_status_reg[0]!=0);
                            JNZ, JNZ_IND: o_pc_load_en = (i_status_reg[0]==0);
                            JC , JC_IND : o_pc_load_en = (i_status_reg[1]!=0);
                            JNC, JNC_IND: o_pc_load_en = (i_status_reg[1]==0);
                        endcase
                        o_pc_load_ind_en = (i_instr_opcode inside {JMP_IND, JZ_IND, JNZ_IND, JC_IND, JNC_IND}) ? 1 : 0;
                    end
                    LOAD_IND: begin
                        o_reg_file_write_en = 1;
                        o_reg_bus_ctrl = 1;
                        o_reg_bus_direct = 1;
                        o_data_mem_wr_ind_en = 1;
                    end
                    STORE_IND: begin
                        o_data_mem_wr_en = 1;
                        o_data_mem_wr_ind_en = 1;
                    end
                    PUSH: begin
                        o_decr_stack = 1;
                        o_data_mem_wr_en = 1;
                    end
                    POP: begin
                        o_incr_stack = 1;
                        o_data_mem_wr_en = 0;
                        o_reg_file_write_en = 1;
                        o_reg_bus_ctrl = 1;
                        o_reg_bus_direct = 1;
                    end
                    CALL, CALL_IND, RET: begin
                        o_pc_load_en = 1;
                        o_pc_load_ind_en = (i_instr_opcode==CALL_IND) ? 1 : 0;
                        o_pc_field_sel[1] = (i_instr_opcode==RET) ? 1 : 0;
                    end
                    default: begin
                        $display("instruction %s not implemented yet..", i_instr_opcode.name());
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
