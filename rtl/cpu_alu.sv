module alu(
    input logic[7:0] a,
    input logic[7:0] b,
    input cpu_opcodes_e opcode,
    output logic[7:0] result,
    output logic carry,
    output logic zero
);
    reg[8:0] lcl_result;
    always_comb begin
        case (opcode)
            ADD : lcl_result = a + b;
            SUB : lcl_result = a - b;
            default: lcl_result = a;
        endcase
    end

    assign result = lcl_result[7:0];
    assign carry = lcl_result[8];
    assign zero = (lcl_result[7:0] == 0);
endmodule
