module control_unit(
    input logic clk,
    input logic rst_n,
    input cpu_opcodes_e opcode,
    output logic reg_write_en,
    input logic[7:0] reg_write_data,
    output logic[7:0] o_reg_write_data,
    output logic halt_en
);
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
        o_reg_write_data = reg_write_data;
        case (opcode)
            LOAD_IMM: begin
                reg_write_en = 1;
            end
            HALT: begin
                halt_en = 1;
            end
        endcase
    end
endmodule
