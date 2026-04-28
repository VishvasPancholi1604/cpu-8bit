module control_unit(
    input logic clk,
    input logic rst_n,
    input cpu_opcodes_e opcode,
    output logic reg_write_en
);

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
        end else begin
        end
    end
endmodule
