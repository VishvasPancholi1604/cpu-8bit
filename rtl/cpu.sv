module cpu(
    input logic clk,
    input logic rst_n
);
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
    reg reg_bus_direct;
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
    reg data_mem_wr_ind_en;
    reg[7:0] data_mem_data;
    reg[7:0] data_mem_out;
    reg[15:0] reg_indirect_address;
    reg[15:0] data_mem_address;
    reg pc_load_en;

    // stack related variables
    reg[15:0] stack_pointer;
    reg load_stack_en;
    reg decr_stack, incr_stack;

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
        .data_mem_addr(reg_indirect_address)
    );
    
    alu u_alu(
        .a(reg_a),
        .b(reg_b),
        .opcode(opcode),
        .alu_operation(cpu_alu_operation_e'(instruction[3:0])),
        .result(alu_result),
        .carry(alu_carry),
        .zero(alu_zero)
    );

    control_unit u_ctrl(
        .clk(clk),
        .rst_n(rst_n),
        .count_en(count_en),
        .opcode(opcode),
        .alu_operation(cpu_alu_operation_e'(instruction[3:0])),
        .jmp_operation(cpu_jmp_type_e'(instruction[9:8])),
        .status(status_bus),
        .reg_write_en(register_wr_en),
        .reg_bus_ctrl(reg_bus_ctrl),
        .reg_bus_direct(reg_bus_direct),
        .status_flag_update(status_bus_ctrl),
        .data_mem_wr_en(data_mem_wr_en),
        .data_mem_wr_ind_en(data_mem_wr_ind_en),
        .pc_load_en(load_en),
        .load_stack_en(load_stack_en),
        .decr_stack(decr_stack),
        .incr_stack(incr_stack),
        .halt_en()
    );

    assign status_bus = {6'b0, alu_carry, alu_zero};
    assign register_wr_data = (reg_bus_ctrl===1) ? ((reg_bus_direct===0) ? data_mem_out : immidiate_bits) : alu_result;
    assign data_mem_data = reg_a;
    assign data_mem_address = (decr_stack===1) ? (stack_pointer-1) : ((incr_stack===1) ? (stack_pointer) : (data_mem_wr_ind_en ? (reg_indirect_address) : (immidiate_bits)));
    assign pc_addr_update = (instruction[11]) ? reg_indirect_address : immidiate_bits;

    always_ff @(posedge clk or negedge rst_n) begin : stack_process_always
        if(!rst_n) begin
            stack_pointer <= `STACK_PTR_HW_RST_VAL;
        end else begin
            if(load_stack_en) begin
                if(instruction[11]) begin
                    stack_pointer <= reg_indirect_address;
                end else begin
                    stack_pointer <= {8'b0, immidiate_bits};
                end
            end
            if(decr_stack) begin
                stack_pointer <= stack_pointer-1;
            end
            if(incr_stack) begin
                stack_pointer <= stack_pointer+1;
            end
        end
    end
endmodule
