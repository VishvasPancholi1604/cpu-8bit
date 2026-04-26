module program_counter(
    input logic clk,
    input logic rst_n,
    input logic load_en,
    input logic count_en,
    input logic[15:0] pc_data,
    output logic[15:0] pc_out 
);
    reg[15:0] pc;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pc <= 0;
        end else begin
            if(load_en) begin
                pc <= pc_data;
            end else if(count_en) begin
                pc <= pc+1;
            end
        end
    end
endmodule
