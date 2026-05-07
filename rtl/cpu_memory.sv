module cpu_memory #(parameter MEM_WIDTH=16, parameter MEM_LENGTH=4096)(
    input  logic                          i_clk,
    input  logic                          i_mem_wr_en,
    input  logic [$clog2(MEM_LENGTH)-1:0] i_mem_addr,
    input  logic[MEM_WIDTH-1:0]           i_mem_wr_data,
    output logic[MEM_WIDTH-1:0]           o_mem_data
);
    logic [MEM_WIDTH-1:0] memory [0:MEM_LENGTH-1];
    assign o_mem_data = memory[i_mem_addr];
    always_ff @(posedge i_clk) begin
        if (i_mem_wr_en) begin
            memory[i_mem_addr] <= i_mem_wr_data;
        end
    end
endmodule
