module control_unit(
    input logic clk,
    input logic rst_n,
    input cpu_opcodes_e opcode,
    input cpu_alu_operation_e alu_operation,
    output logic reg_write_en,
    output logic halt_en,
    output logic reg_bus_ctrl,
    output logic reg_bus_direct,
    output logic status_flag_update,
    output logic data_mem_wr_en,
    output logic data_mem_wr_ind_en,
    output logic pc_load_en
);
    // DEPRICATED
    cpu_states_e cpu_state;
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cpu_state <= CPU_RESET;
        end else begin
            case (opcode)
                NOP: cpu_state <= CPU_IDLE;
                HALT: cpu_state <= CPU_HALT;
                default: cpu_state <= CPU_ACTIVE;
            endcase
        end
    end

    always_comb begin
        reg_write_en = 0;
        halt_en = 0;
        reg_bus_ctrl = 0;
        reg_bus_direct = 0;
        status_flag_update = 0;
        data_mem_wr_en = 0;
        data_mem_wr_ind_en = 0;
        pc_load_en = 0;
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
                reg_write_en = (alu_operation != CMP) ? 1 : 0; // no need to update dest register for comparision
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
            HALT: begin
                halt_en = 1;
            end
        endcase
    end
endmodule
