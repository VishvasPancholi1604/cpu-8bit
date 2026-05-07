module program_counter(
    input logic i_clk,
    input logic i_rst_n,
    input logic i_pc_load_en,
    input logic i_pc_count_en,
    input logic[15:0] i_pc_data,
    output logic[15:0] o_pc_data 
);
    reg[15:0] pc;
    assign o_pc_data = pc;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            pc <= 0;
        end else begin
            if(i_pc_load_en) begin
                pc <= i_pc_data;
            end else if(i_pc_count_en) begin
                pc <= pc+1;
            end
        end
    end
endmodule
