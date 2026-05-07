module alu(
    input logic[7:0] i_reg_a,
    input logic[7:0] i_reg_b,
    input cpu_alu_operation_e i_instr_alu_operation,
    output logic[7:0] o_alu_result,
    output logic o_status_carry,
    output logic o_status_zero
);
    reg[8:0] lcl_result;
    always_comb begin
        lcl_result = 9'b0;
        case (i_instr_alu_operation)
            ALU_ADD: lcl_result = i_reg_a + i_reg_b;
            ALU_SUB, ALU_CMP: lcl_result = i_reg_a - i_reg_b;
            ALU_AND: lcl_result = {1'b0, i_reg_a & i_reg_b};
            ALU_OR: lcl_result = {1'b0, i_reg_a | i_reg_b};
            ALU_XOR: lcl_result = {1'b0, i_reg_a ^ i_reg_b};
            ALU_LSL: lcl_result = {i_reg_a, 1'b0};
            ALU_LSR: lcl_result = {i_reg_a[0], 1'b0, i_reg_a[7:1]};
            default: lcl_result = 9'b0;
        endcase
    end
    assign o_alu_result = lcl_result[7:0];
    assign o_status_carry = lcl_result[8];
    assign o_status_zero = (lcl_result[7:0] == 8'b0);
endmodule
