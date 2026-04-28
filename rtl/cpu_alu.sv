module alu(
    input logic[7:0] a,
    input logic[7:0] b,
    input cpu_opcodes_e opcode,
    input cpu_alu_operation_e alu_operation,
    output logic[7:0] result,
    output logic carry,
    output logic zero
);
    reg[8:0] lcl_result;
    always_comb begin
        lcl_result = 9'b0;
        if(opcode == ALU_REG) begin
            case (alu_operation)
                ADD: lcl_result = a + b;
                SUB, CMP: lcl_result = a - b;
                AND: lcl_result = {1'b0, a & b};
                OR: lcl_result = {1'b0, a | b};
                XOR: lcl_result = {1'b0, a ^ b};
                LSL: lcl_result = {a, 1'b0}; // logical shift left
                LSR: lcl_result = {a[0], 1'b0, a[7:1]}; // logical shift right
                default: lcl_result = 9'b0;
            endcase
        end
    end
    assign result = lcl_result[7:0];
    assign carry = lcl_result[8];
    assign zero = (lcl_result[7:0] == 8'b0);
endmodule
