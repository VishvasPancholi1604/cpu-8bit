module registers(
    input logic i_clk,
    input logic i_reg_wr_en,
    input logic i_status_wr_en,
    input cpu_registers_e i_src_addr,
    input cpu_registers_e i_dest_addr,
    input logic[7:0] i_reg_write_data,
    input logic[7:0] i_status_write_data,
    output logic[7:0] o_dest_reg_data,
    output logic[7:0] o_src_reg_data,
    output logic[15:0] o_reg_indirect_addr,
    output logic[7:0] o_status_reg
);
    reg[7:0] status_reg;
    reg[7:0] registers[0:31];
    // OLD: assign dest_data = registers[int'(dest_addr)];
    // OLD: assign src_data  = registers[int'(src_addr)];
    // OLD: assign o_status_reg = status_reg;
    assign o_reg_indirect_addr = {registers[int'(REG31)], registers[int'(REG30)]};
    always_ff @(posedge i_clk) begin
        if(i_reg_wr_en) begin
            registers[int'(i_dest_addr)] <= i_reg_write_data;
        end
        if(i_status_wr_en) begin
            status_reg <= i_status_write_data;
        end
        o_dest_reg_data <= registers[int'(i_dest_addr)];
        o_src_reg_data  <= registers[int'(i_src_addr)];
        o_status_reg <= status_reg;
    end
endmodule
