module registers(
    input logic clk,
    input logic wr_en,
    input logic status_wr_en,
    input cpu_registers_e src_addr,
    input cpu_registers_e dest_addr,
    input logic[7:0] write_data,
    input logic[7:0] status_data,
    output logic[7:0] dest_data,
    output logic[7:0] src_data,
    output logic[15:0] data_mem_addr,
    output logic[7:0] o_status_reg
);
    reg[7:0] status_reg;
    reg[7:0] registers[0:3];
    // OLD: assign dest_data = registers[int'(dest_addr)];
    // OLD: assign src_data  = registers[int'(src_addr)];
    // OLD: assign o_status_reg = status_reg;
    assign data_mem_addr = {registers[int'(REG3)], registers[int'(REG2)]};
    always_ff @(posedge clk) begin
        if(wr_en) begin
            registers[int'(dest_addr)] <= write_data;
        end
        if(status_wr_en) begin
            status_reg <= status_data;
        end
        dest_data <= registers[int'(dest_addr)];
        src_data  <= registers[int'(src_addr)];
        o_status_reg <= status_reg;
    end
endmodule
