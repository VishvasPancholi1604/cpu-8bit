`include "cpu_enums.sv"
`include "cpu_instruction_decoder.sv"
`include "cpu_memory.sv"
`include "cpu_registers.sv"
`include "cpu_alu.sv"
`include "cpu_program_counter.sv"
`include "cpu_control_unit.sv"

module top;
    bit clk;
    bit rst_n;
    reg       load_en;
    reg       count_en;
    reg[15:0] pc_addr_update;

    // global bus
    cpu_states_e cpu_state;
    wire[15:0] address_bus;
    wire[15:0] instruction;
    reg register_wr_en;
    reg[7:0] register_wr_data;
    reg[7:0] o_register_wr_data;
    reg reg_bus_ctrl;
    reg status_bus_ctrl;
    reg[7:0] status_bus;
    cpu_opcodes_e opcode;
    cpu_registers_e src_reg_addr;
    cpu_registers_e dest_reg_addr;
    reg[7:0] immidiate_bits;
    reg[7:0] reg_a, reg_b;
    reg[7:0] alu_result;
    reg alu_carry;
    reg alu_zero;
    reg data_mem_wr_en;
    reg[7:0] data_mem_data;
    reg[7:0] data_mem_out;
    reg[15:0] data_mem_address;

    // tb signals
    reg instr_mem_wr_en;
    reg[15:0] instr_mem_data;

    program_counter u_pc(
        .clk(clk),
        .rst_n(rst_n),
        .load_en(load_en), // need to figure out 
        .count_en(count_en), // need to figure out 
        .pc_data(pc_addr_update), // need to figure out 
        .pc_out(address_bus)
    );

    cpu_memory#(.MEM_WIDTH(16), .MEM_LENGTH(65536)) u_instruction_memory(
        .clk(clk),
        .addr(address_bus),
        .wr_en(instr_mem_wr_en),  // need to figure out
        .wr_data(instr_mem_data), // need to figure out
        .data(instruction)
    );

    cpu_memory#(.MEM_WIDTH(8), .MEM_LENGTH(65536)) u_data_memory(
        .clk(clk),
        .addr(data_mem_address),
        .wr_en(data_mem_wr_en),   // need to figure out
        .wr_data(data_mem_data), // need to figure out
        .data(data_mem_out)
    );

    instruction_decoder u_instr_decode(
        .instruction(instruction),
        .opcode(opcode),
        .src_reg(src_reg_addr),
        .dest_reg(dest_reg_addr),
        .immediate_data(immidiate_bits)
    );

    registers u_cpu_registers(
        .clk(clk),
        .wr_en(register_wr_en),  // need to figure out
        .status_wr_en(status_bus_ctrl),
        .src_addr(src_reg_addr), 
        .dest_addr(dest_reg_addr),
        .write_data(register_wr_data), // need to figure out
        .status_data(status_bus), // need to figure out
        .dest_data(reg_a), // need to figure out
        .src_data(reg_b), // need to figure out
        .data_mem_addr(data_mem_address)
    );
    
    alu u_alu(
        .a(reg_a),
        .b(reg_b),
        .opcode(opcode),
        .result(alu_result),
        .carry(alu_carry),
        .zero(alu_zero)
    );

    control_unit u_ctrl(
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .reg_write_en(register_wr_en),
        //.reg_write_data(register_wr_data),
        //.o_reg_write_data(o_register_wr_data),
        .reg_bus_ctrl(reg_bus_ctrl),
        .status_flag_update(status_bus_ctrl),
        .halt_en()
    );

    assign status_bus = {6'b0, alu_carry, alu_zero};
    assign register_wr_data = (reg_bus_ctrl===1) ? immidiate_bits : alu_result;


    // clk and reset initialization
    // temporary
    always #5 clk = ~clk;
    string hex_file_path;

    initial begin
        if (!$value$plusargs("HEX_FILE=%s", hex_file_path)) begin
            $display("ERROR: +HEX_FILE=<path> argument not provided.");
            $finish;
        end

        $display("Loading memory from: %s", hex_file_path);
        $readmemh(hex_file_path, u_instruction_memory.memory);        #1 rst_n = 1;
        count_en = 1;
        for(int i=0;i<10; i++) begin
            $display("u_instruction_memory.memory[%0d] = 0x%0h", i, u_instruction_memory.memory[i]);
        end
        #100 $finish();
    end
endmodule
