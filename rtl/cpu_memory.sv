module cpu_memory #(parameter MEM_WIDTH=16, parameter MEM_LENGTH=4096)(
    input  logic                          clk,
    input  logic                          wr_en,
    input  logic [$clog2(MEM_LENGTH)-1:0] addr,
    input  logic[MEM_WIDTH-1:0]           wr_data,
    output logic[MEM_WIDTH-1:0]           data
);
    logic [MEM_WIDTH-1:0] memory [0:MEM_LENGTH-1];
    assign data = memory[addr];
    always_ff @(posedge clk) begin
        if (wr_en) begin
            memory[addr] <= wr_data;
        end
    end
endmodule
