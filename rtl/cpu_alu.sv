module alu(
    input logic[7:0] i_reg_a,
    input logic[7:0] i_reg_b,
    input cpu_opcodes_e i_instr_opcode,
    input cpu_alu_operation_e i_instr_alu_operation,
    output logic[7:0] o_alu_result,
    output logic o_status_carry,
    output logic o_status_zero
);
    reg[8:0] lcl_result;
    always_comb begin
        lcl_result = 9'b0;
        if(i_instr_opcode == ALU_REG) begin
            case (i_instr_alu_operation)
                ADD: lcl_result = i_reg_a + i_reg_b;
                SUB, CMP: lcl_result = i_reg_a - i_reg_b;
                AND: lcl_result = {1'b0, i_reg_a & i_reg_b};
                OR: lcl_result = {1'b0, i_reg_a | i_reg_b};
                XOR: lcl_result = {1'b0, i_reg_a ^ i_reg_b};
                LSL: lcl_result = {i_reg_a, 1'b0}; // logical shift left
                LSR: lcl_result = {i_reg_a[0], 1'b0, i_reg_a[7:1]}; // logical shift right
                default: lcl_result = 9'b0;
            endcase
        end
    end
    assign o_alu_result = lcl_result[7:0];
    assign o_status_carry = lcl_result[8];
    assign o_status_zero = (lcl_result[7:0] == 8'b0);
endmodule
