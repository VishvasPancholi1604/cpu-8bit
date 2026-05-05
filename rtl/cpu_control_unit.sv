module control_unit(
    input logic clk,
    input logic rst_n,
    input cpu_opcodes_e opcode,
    input cpu_alu_operation_e alu_operation,
    input cpu_jmp_type_e jmp_operation,
    input logic[7:0] status,
    output logic count_en,
    output logic reg_write_en,
    output logic halt_en,
    output logic reg_bus_ctrl,
    output logic reg_bus_direct,
    output logic status_flag_update,
    output logic data_mem_wr_en,
    output logic data_mem_wr_ind_en,
    output logic pc_load_en,
    output logic load_stack_en,
    output logic decr_stack,
    output logic incr_stack,
    output logic ir_write_en,
    output logic[1:0] pc_field_sel
);
    // DEPRICATED
    cpu_states_e current_state, next_state;
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            current_state <= FETCH;
        end else begin
            current_state <= next_state; 
        end
    end

    always_comb begin
        case (current_state)
            FETCH: next_state = DECODE;
            DECODE: begin
                case (opcode)
                    CALL: next_state = CALL_HI;
                    RET: next_state = RET_LO;
                    default: next_state = EXECUTE;
                endcase
            end
            EXECUTE: begin
                case (opcode)
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
        count_en = 0;
        reg_write_en = 0;
        halt_en = 0;
        reg_bus_ctrl = 0;
        reg_bus_direct = 0;
        status_flag_update = 0;
        data_mem_wr_en = 0;
        data_mem_wr_ind_en = 0;
        pc_load_en = 0;
        load_stack_en = 0;
        decr_stack = 0;
        incr_stack = 0;
        ir_write_en = 0;
        pc_field_sel = 2'b0;
        case (current_state)
            FETCH: begin
                count_en = 1;
                ir_write_en = 1;
            end
            DECODE: begin
                // necessary since register file needs one clock cycle to update register values.
            end
            EXECUTE: begin
                case (opcode)
                    LOAD_IMM: begin
                        reg_write_en = 1;
                        reg_bus_ctrl = 1;
                        reg_bus_direct = 1;
                    end
                    LOAD_DIR: begin
                        reg_write_en = 1;
                        reg_bus_ctrl = 1;
                        reg_bus_direct = 0;
                        data_mem_wr_ind_en = 0;
                    end
                    LOAD_IND: begin
                        reg_write_en = 1;
                        reg_bus_ctrl = 1;
                        reg_bus_direct = 0;
                        data_mem_wr_ind_en = 1;
                    end
                    ALU_REG: begin
                        reg_write_en = (alu_operation != CMP) ? 1 : 0;
                        status_flag_update = 1;
                    end
                    STORE_DIR: begin
                        data_mem_wr_en = 1;
                    end
                    STORE_IND: begin
                        data_mem_wr_en = 1;
                        data_mem_wr_ind_en = 1;
                    end
                    JMP: begin
                        pc_load_en = 1;
                    end
                    BCC: begin
                        case (jmp_operation)
                            JZ  : pc_load_en = (status[0]!=0);
                            JNZ : pc_load_en = (status[0]==0);
                            JC  : pc_load_en = (status[1]!=0);
                            JNC : pc_load_en = (status[1]==0);
                        endcase
                    end
                    LOAD_SP: begin
                        load_stack_en = 1;
                    end
                    PUSH: begin
                        decr_stack = 1;
                        data_mem_wr_en = 1;
                    end
                    POP: begin
                        incr_stack = 1;
                        data_mem_wr_en = 1;
                        reg_write_en = 1;
                        reg_bus_ctrl = 1;
                        reg_bus_direct = 0;
                    end
                    CALL, RET: begin
                        pc_load_en = 1;
                        pc_field_sel[1] = (opcode==RET) ? 1 : 0;
                    end
                    HALT: begin
                        halt_en = 1;
                    end
                endcase
            end
            CALL_HI, CALL_LO: begin
                data_mem_wr_en = 1;
                decr_stack = 1;
                pc_field_sel = (current_state == CALL_HI) ? 2'b11 : 2'b10;
            end
            RET_LO, RET_HI: begin
                incr_stack = 1;
                pc_field_sel = (current_state == RET_LO) ? 2'b10 : 2'b11;
            end
        endcase
    end
endmodule
