`include "cpu_enums.sv"
`include "cpu_instruction_decoder.sv"
`include "cpu_memory.sv"
`include "cpu_registers.sv"
`include "cpu_alu.sv"
`include "cpu_program_counter.sv"
`include "cpu_control_unit.sv"
`include "spi_isp.sv"
`include "cpu.sv"

module top;
    bit clk, rst_n;
    // clk and reset initialization
    // temporary
    always #5 clk = ~clk;
    string hex_file_path;

    bit spi_sck, spi_mosi, spi_cs_n;
    wire spi_miso;

    cpu u_cpu(
        .clk(clk),
        .rst_n(rst_n),
        .spi_sck(spi_sck),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .spi_cs_n(spi_cs_n)
    );

    task spi_xfer(input logic [7:0] t_data, output logic [7:0] r_data);
        begin
            r_data = 8'h00;
            for (int i = 7; i >= 0; i--) begin
                spi_mosi = t_data[i];
                #10 spi_sck = 1;
                r_data[i] = spi_miso;
                #10 spi_sck = 0;
            end
        end
    endtask

    task spi_program_instr_mem(input string hex_file);
        logic [15:0] mem_data [0:65535];
        int num_words = 0;
        logic [7:0] dummy_rx;
        
        // Read hex file into temporary memory
        $readmemh(hex_file, mem_data);
        
        // Find how many words to program (find last non-x word, though we can just program a fixed amount or stop at X)
        for (int i = 0; i < 65536; i++) begin
            if (mem_data[i] !== 16'hxx) num_words = i + 1;
        end
        
        $display("Programming %0d words via SPI ISP...", num_words);
        
        // Enter ISP Mode
        spi_cs_n = 0;
        #20;
        
        // Send CMD: 0x10 (Write Instruction Memory Burst)
        spi_xfer(8'h10, dummy_rx);
        
        // Send Addr: 0x0000
        spi_xfer(8'h00, dummy_rx);
        spi_xfer(8'h00, dummy_rx);
        
        // Send Data (High Byte then Low Byte)
        for (int i = 0; i < num_words; i++) begin
            spi_xfer(mem_data[i][15:8], dummy_rx);
            spi_xfer(mem_data[i][7:0], dummy_rx);
        end
        
        #20 spi_cs_n = 1;
        $display("SPI Programming Complete.");
    endtask

    initial begin
        if (!$value$plusargs("HEX_FILE=%s", hex_file_path)) begin
            $display("ERROR: +HEX_FILE=<path> argument not provided.");
            $finish;
        end

        spi_cs_n = 1;
        spi_sck = 0;
        spi_mosi = 0;
        rst_n = 0;
        #20; // Let reset settle

        spi_program_instr_mem(hex_file_path);
        
        #20 rst_n = 1; // Release CPU reset, boot from programmed memory
        for(int i=0;i<10; i++) begin
            $display("u_instruction_memory.memory[%0d] = 0x%0h", i, u_cpu.u_instruction_memory.memory[i]);
        end
        #3000 $finish();
    end
endmodule
