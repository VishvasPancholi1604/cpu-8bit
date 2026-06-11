module spi_isp(
    input  logic        clk,
    input  logic        rst_n,      // System reset (ISP only works when rst_n == 0)

    // SPI Interface
    input  logic        spi_sck,
    input  logic        spi_mosi,
    output logic        spi_miso,
    input  logic        spi_cs_n,

    // ISP Control
    output logic        isp_mode,   // Asserted when rst_n is low and cs_n is low

    // Instruction Memory Interface
    output logic [15:0] instr_mem_addr,
    output logic [15:0] instr_mem_wr_data,
    output logic        instr_mem_wr_en,
    input  logic [15:0] instr_mem_rd_data,

    // Data Memory Interface
    output logic [15:0] data_mem_addr,
    output logic [7:0]  data_mem_wr_data,
    output logic        data_mem_wr_en,
    input  logic [7:0]  data_mem_rd_data
);

    // Synchronize SPI signals to system clock
    logic [2:0] sck_sync;
    logic [2:0] cs_n_sync;
    logic [1:0] mosi_sync;

    initial begin
        sck_sync = 3'b000;
        cs_n_sync = 3'b111;
        mosi_sync = 3'b00;
    end

    // Use pure clock for synchronizers to catch signals even if CPU is in reset
    always_ff @(posedge clk) begin
        sck_sync  <= {sck_sync[1:0], spi_sck};
        cs_n_sync <= {cs_n_sync[1:0], spi_cs_n};
        mosi_sync <= {mosi_sync[0], spi_mosi};
    end

    wire sck_rise  = (sck_sync[2:1] == 2'b01);
    wire sck_fall  = (sck_sync[2:1] == 2'b10);
    wire cs_active = !cs_n_sync[1];
    wire mosi_val  = mosi_sync[1];

    // Enable ISP mode only when CPU is in hardware reset and CS is active
    assign isp_mode = !rst_n && cs_active;

    typedef enum logic [2:0] {
        IDLE,
        CMD,
        ADDR_HI,
        ADDR_LO,
        DATA_PHASE
    } spi_state_e;

    spi_state_e state;
    logic [2:0]  bit_cnt;
    logic [7:0]  shift_reg;
    logic [7:0]  cmd_reg;
    logic [15:0] addr_reg;
    logic [7:0]  data_hi;
    logic        word_half; 
    logic [7:0]  out_shift_reg;
    logic        miso_out;

    initial begin
        state = IDLE;
        bit_cnt = 3'b0;
        shift_reg = 8'b0;
        cmd_reg = 8'b0;
        addr_reg = 16'b0;
        data_hi = 8'b0;
        word_half = 1'b0;
        out_shift_reg = 8'b0;
        miso_out = 1'b0;
    end

    assign spi_miso = (isp_mode) ? miso_out : 1'bz;
    assign instr_mem_addr = addr_reg;
    assign data_mem_addr  = addr_reg;

    always_ff @(posedge clk) begin
        if (!isp_mode) begin
            state <= CMD;
            bit_cnt <= 3'b000;
            instr_mem_wr_en <= 1'b0;
            data_mem_wr_en <= 1'b0;
            word_half <= 1'b0;
            shift_reg <= 8'b0;
            miso_out <= 1'b0;
            out_shift_reg <= 8'b0;
        end else begin
            // Default write enables to 0 (pulse for 1 clock cycle only)
            instr_mem_wr_en <= 1'b0;
            data_mem_wr_en <= 1'b0;

            if (sck_rise) begin
                shift_reg <= {shift_reg[6:0], mosi_val};
                bit_cnt <= bit_cnt + 1;
            end

            if (sck_fall) begin
                // Shift out data on MISO for read commands
                if (state == DATA_PHASE) begin
                    if (bit_cnt == 3'b000) begin
                        // Just entered a new byte, load data from memory
                        if (cmd_reg == 8'h11) begin // Read Instr (16-bit)
                            miso_out <= (word_half == 1'b0) ? instr_mem_rd_data[15] : instr_mem_rd_data[7];
                            out_shift_reg <= (word_half == 1'b0) ? {instr_mem_rd_data[14:8], 1'b0} : {instr_mem_rd_data[6:0], 1'b0};
                        end else if (cmd_reg == 8'h21) begin // Read Data (8-bit)
                            miso_out <= data_mem_rd_data[7];
                            out_shift_reg <= {data_mem_rd_data[6:0], 1'b0};
                        end
                    end else begin
                        miso_out <= out_shift_reg[7];
                        out_shift_reg <= {out_shift_reg[6:0], 1'b0};
                    end
                end
            end

            if (sck_rise && bit_cnt == 3'b111) begin
                logic [7:0] rcv_byte;
                rcv_byte = {shift_reg[6:0], mosi_val};
                case (state)
                    CMD: begin
                        cmd_reg <= rcv_byte;
                        state <= ADDR_HI;
                    end
                    ADDR_HI: begin
                        addr_reg[15:8] <= rcv_byte;
                        state <= ADDR_LO;
                    end
                    ADDR_LO: begin
                        addr_reg[7:0] <= rcv_byte;
                        state <= DATA_PHASE;
                        word_half <= 1'b0;
                    end
                    DATA_PHASE: begin
                        if (cmd_reg == 8'h10) begin // Write Instr Mem
                            if (word_half == 1'b0) begin
                                data_hi <= rcv_byte;
                                word_half <= 1'b1;
                            end else begin
                                instr_mem_wr_data <= {data_hi, rcv_byte};
                                instr_mem_wr_en <= 1'b1;
                                addr_reg <= addr_reg + 1;
                                word_half <= 1'b0;
                            end
                        end
                        else if (cmd_reg == 8'h20) begin // Write Data Mem
                            data_mem_wr_data <= rcv_byte;
                            data_mem_wr_en <= 1'b1;
                            addr_reg <= addr_reg + 1;
                        end
                        else if (cmd_reg == 8'h11) begin // Read Instr Mem
                            if (word_half == 1'b1) begin
                                addr_reg <= addr_reg + 1;
                                word_half <= 1'b0;
                            end else begin
                                word_half <= 1'b1;
                            end
                        end
                        else if (cmd_reg == 8'h21) begin // Read Data Mem
                            addr_reg <= addr_reg + 1;
                        end
                    end
                endcase
            end
        end
    end
endmodule
