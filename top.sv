`include "cpu_enums.sv"
`include "cpu_instruction_decoder.sv"
`include "cpu_memory.sv"
`include "cpu_registers.sv"
`include "cpu_alu.sv"
`include "cpu_program_counter.sv"
`include "cpu_control_unit.sv"
`include "cpu.sv"

module top;
    bit clk, rst_n;
    logic [7:0] irq;
    // clk and reset initialization
    // temporary
    always #5 clk = ~clk;
    string hex_file_path;

    cpu u_cpu(
        .clk(clk),
        .rst_n(rst_n),
        .irq(irq)
    );

    initial begin
        if (!$value$plusargs("HEX_FILE=%s", hex_file_path)) begin
            $display("ERROR: +HEX_FILE=<path> argument not provided.");
            $finish;
        end

        irq = 8'b0;
        #200; // wait some time for initialization and main loop
        irq[0] = 1'b1;
        #10;
        irq[0] = 1'b0;
        
        #300; // wait some time for ISR to finish
        irq[1] = 1'b1;
        #10;
        irq[1] = 1'b0;
    end

    initial begin

        $display("Loading memory from: %s", hex_file_path);
        $readmemh(hex_file_path, u_cpu.u_instruction_memory.memory);
        #1 rst_n = 1;
        for(int i=0;i<10; i++) begin
            $display("u_instruction_memory.memory[%0d] = 0x%0h", i, u_cpu.u_instruction_memory.memory[i]);
        end
        #3000 $finish();
    end
endmodule
