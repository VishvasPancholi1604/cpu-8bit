module cpu(
    input logic clk,
    input logic rst_n
);
    reg ctrl_pc_load_en;
    reg ctrl_pc_count_en;
    reg ctrl_ir_wr_en; 
    reg[15:0] instr_reg;
    reg[15:0] pc_next_addr;

    // global bus
    cpu_states_e current_cpu_state;
    wire[15:0] pc_addr_bus;
    reg[15:0] pc_return_addr;
    reg[1:0] ctrl_pc_field_sel;
    reg[15:0] mem_instr_data;
    cpu_opcodes_e dec_opcode;
    cpu_registers_e dec_src_addr;
    cpu_registers_e dec_dest_addr;
    reg[7:0] dec_imm_data;
    reg ctrl_reg_wr_en;
    reg[7:0] reg_wr_data;
    reg[7:0] rf_dest_data;
    reg[7:0] rf_src_data;
    reg[15:0] rf_indirect_addr;
    reg ctrl_status_update_en;
    reg[7:0] rf_status_reg;
    reg[7:0] alu_status_bus;
    reg[7:0] alu_out_data;
    reg alu_out_carry;
    reg alu_out_zero;
    reg ctrl_data_mem_wr_en;
    reg ctrl_data_mem_wr_ind_en;
    reg[15:0] data_mem_addr;
    reg[7:0] data_mem_in_data;
    reg[7:0] data_mem_rd_data;
    reg ctrl_reg_bus_mux;
    reg ctrl_reg_bus_dir;

    // stack related variables
    reg[15:0] stack_ptr;
    reg ctrl_load_stack_en;
    reg ctrl_decr_stack;
    reg ctrl_incr_stack;

    // tb signals
    reg instr_mem_wr_en;
    reg[15:0] instr_mem_data;

    program_counter u_pc(
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_pc_load_en(ctrl_pc_load_en),
        .i_pc_count_en(ctrl_pc_count_en),
        .i_pc_data(pc_next_addr),
        .o_pc_data(pc_addr_bus)
    );

    cpu_memory#(.MEM_WIDTH(16), .MEM_LENGTH(65536)) u_instruction_memory(
        .i_clk(clk),
        .i_mem_addr(pc_addr_bus),
        .i_mem_wr_en(instr_mem_wr_en),
        .i_mem_wr_data(instr_mem_data),
        .o_mem_data(mem_instr_data)
    );

    cpu_memory#(.MEM_WIDTH(8), .MEM_LENGTH(65536)) u_data_memory(
        .i_clk(clk),
        .i_mem_addr(data_mem_addr),
        .i_mem_wr_en(ctrl_data_mem_wr_en),
        .i_mem_wr_data(data_mem_in_data),
        .o_mem_data(data_mem_rd_data)
    );

    instruction_decoder u_instr_decode(
        .i_cpu_instruction(instr_reg),
        .o_instr_opcode(dec_opcode),
        .o_instr_src_reg(dec_src_addr),
        .o_instr_dest_reg(dec_dest_addr),
        .o_instr_imm_data(dec_imm_data)
    );

    registers u_cpu_registers(
        .i_clk(clk),
        .i_reg_wr_en(ctrl_reg_wr_en),
        .i_status_wr_en(ctrl_status_update_en),
        .i_src_addr(dec_src_addr), 
        .i_dest_addr(dec_dest_addr),
        .i_reg_write_data(reg_wr_data),
        .i_status_write_data(alu_status_bus),
        .o_dest_reg_data(rf_dest_data),
        .o_src_reg_data(rf_src_data),
        .o_reg_indirect_addr(rf_indirect_addr),
        .o_status_reg(rf_status_reg)
    );
    
    alu u_alu(
        .i_reg_a(rf_dest_data),
        .i_reg_b(rf_src_data),
        .i_instr_opcode(dec_opcode),
        .i_instr_alu_operation(cpu_alu_operation_e'(instr_reg[3:0])),
        .o_alu_result(alu_out_data),
        .o_status_carry(alu_out_carry),
        .o_status_zero(alu_out_zero)
    );

    control_unit u_ctrl(
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_instr_opcode(dec_opcode),
        .i_instr_alu_operation(cpu_alu_operation_e'(instr_reg[3:0])),
        .i_instr_jmp_operation(cpu_jmp_type_e'(instr_reg[9:8])),
        .i_status_reg(rf_status_reg),
        .o_pc_count_en(ctrl_pc_count_en),
        .o_reg_file_write_en(ctrl_reg_wr_en),
        .o_reg_bus_ctrl(ctrl_reg_bus_mux),
        .o_reg_bus_direct(ctrl_reg_bus_dir),
        .o_status_flag_update_en(ctrl_status_update_en),
        .o_data_mem_wr_en(ctrl_data_mem_wr_en),
        .o_data_mem_wr_ind_en(ctrl_data_mem_wr_ind_en),
        .o_pc_load_en(ctrl_pc_load_en),
        .o_load_stack_en(ctrl_load_stack_en),
        .o_decr_stack(ctrl_decr_stack),
        .o_incr_stack(ctrl_incr_stack),
        .o_fetch_instr_en(ctrl_ir_wr_en),
        .o_pc_field_sel(ctrl_pc_field_sel),
        .o_halt_en()
    );

    assign alu_status_bus = {6'b0, alu_out_carry, alu_out_zero};
    assign reg_wr_data = (ctrl_reg_bus_mux===1) ? ((ctrl_reg_bus_dir===0) ? data_mem_rd_data : dec_imm_data) : alu_out_data;
    assign data_mem_in_data = (ctrl_pc_field_sel[1]===0) ? rf_dest_data : ((ctrl_pc_field_sel[0]===1) ? pc_addr_bus[15:8] : pc_addr_bus[7:0]);
    assign data_mem_addr = (ctrl_decr_stack===1) ? (stack_ptr-1) : ((ctrl_incr_stack===1) ? (stack_ptr) : (ctrl_data_mem_wr_ind_en ? (rf_indirect_addr) : (dec_imm_data)));
    assign pc_next_addr = (ctrl_pc_field_sel[1]===0) ? ((instr_reg[11]) ? rf_indirect_addr : dec_imm_data) : (pc_return_addr);

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            stack_ptr <= `STACK_PTR_HW_RST_VAL;
        end else begin
            if(ctrl_ir_wr_en) begin
                instr_reg <= mem_instr_data;
            end
            if(ctrl_load_stack_en) begin
                if(instr_reg[11]) begin
                    stack_ptr <= rf_indirect_addr;
                end else begin
                    stack_ptr <= {8'b0, dec_imm_data};
                end
            end
            if(ctrl_decr_stack) begin
                stack_ptr <= stack_ptr-1;
            end
            if(ctrl_incr_stack) begin
                stack_ptr <= stack_ptr+1;
            end
            if(ctrl_pc_field_sel[1]) begin
                if(ctrl_pc_field_sel[0]) begin
                    pc_return_addr[15:8] <= data_mem_rd_data;
                end else begin
                    pc_return_addr[7:0] <= data_mem_rd_data;
                end
            end 
        end
    end
endmodule
