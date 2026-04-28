// if wr_en can write to destination register
// output has value of two registers
// dest_reg & src_reg 
module registers(
    input logic clk,
    input logic wr_en,
    input cpu_registers_e src_addr,
    input cpu_registers_e dest_addr,
    input logic[7:0] write_data,
    output logic[7:0] dest_data,
    output logic[7:0] src_data,
    output logic[15:0] data_mem_addr
);
    reg[7:0] registers[0:3];

    assign dest_data = registers[int'(dest_addr)];
    assign src_data  = registers[int'(src_addr)];
    assign data_mem_addr = {registers[int'(REG3)], registers[int'(REG2)]};
    always_ff @(posedge clk) begin
        if(wr_en) begin
            registers[int'(dest_addr)] <= write_data;
        end
    end
endmodule
