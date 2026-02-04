module spi_flash_ip (
    input clk,
    input rst_n,

    input wr_en,
    input rd_en,
    input [7:0] addr,
    input [31:0] wdata,
    output reg [31:0] rdata,

    output reg spi_cs_n,
    output reg spi_clk,
    output reg spi_mosi,
    input spi_miso
);

reg [7:0] cmd_reg;
reg [23:0] addr_reg;
reg [15:0] len_reg;
reg start_reg;
reg [31:0] status_reg;
reg [7:0] data_reg;

reg [7:0] shift_tx;
reg [7:0] shift_rx;
reg [4:0] bit_cnt;
reg [15:0] byte_cnt;

reg [15:0] clk_div;
reg [15:0] clk_cnt;
reg spi_clk_en;

reg [2:0] state;
localparam IDLE = 3'd0;
localparam SEND_CMD = 3'd1;
localparam SEND_ADDR = 3'd2;
localparam TRANSFER = 3'd3;
localparam DONE = 3'd4;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cmd_reg <= 0;
        addr_reg <= 0;
        len_reg <= 0;
        start_reg <= 0;
        status_reg <= 0;
        data_reg <= 0;
        clk_div <= 4;
    end else begin
        if(wr_en) begin
            case(addr)
                8'h00: cmd_reg <= wdata[7:0];
                8'h04: addr_reg <= wdata[23:0];
                8'h08: len_reg <= wdata[15:0];
                8'h0C: start_reg <= wdata[0];
                8'h14: data_reg <= wdata[7:0];
            endcase
        end
        if(rd_en) begin
            case(addr)
                8'h10: rdata <= status_reg;
                8'h14: rdata <= {24'd0,data_reg};
                default: rdata <= 0;
            endcase
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        clk_cnt <= 0;
        spi_clk_en <= 0;
    end else begin
        if(clk_cnt == clk_div) begin
            clk_cnt <= 0;
            spi_clk_en <= 1;
        end else begin
            clk_cnt <= clk_cnt + 1;
            spi_clk_en <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        spi_clk <= 0;
    end else if(spi_clk_en && state != IDLE && state != DONE) begin
        spi_clk <= ~spi_clk;
    end else if(state == IDLE || state == DONE) begin
        spi_clk <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
        spi_cs_n <= 1;
        spi_mosi <= 0;
        bit_cnt <= 0;
        byte_cnt <= 0;
        status_reg <= 0;
    end else begin
        case(state)
            IDLE: begin
                spi_cs_n <= 1;
                status_reg[0] <= 0;
                status_reg[1] <= 0;
                if(start_reg) begin
                    spi_cs_n <= 0;
                    shift_tx <= cmd_reg;
                    bit_cnt <= 7;
                    byte_cnt <= 0;
                    status_reg[0] <= 1;
                    state <= SEND_CMD;
                end
            end

            SEND_CMD: begin
                if(spi_clk_en && !spi_clk) begin
                    spi_mosi <= shift_tx[bit_cnt];
                    if(bit_cnt == 0) begin
                        shift_tx <= addr_reg[23:16];
                        bit_cnt <= 7;
                        state <= SEND_ADDR;
                    end else begin
                        bit_cnt <= bit_cnt - 1;
                    end
                end
            end

            SEND_ADDR: begin
                if(spi_clk_en && !spi_clk) begin
                    spi_mosi <= shift_tx[bit_cnt];
                    if(bit_cnt == 0) begin
                        if(byte_cnt == 0) shift_tx <= addr_reg[15:8];
                        else if(byte_cnt == 1) shift_tx <= addr_reg[7:0];
                        byte_cnt <= byte_cnt + 1;
                        bit_cnt <= 7;
                        if(byte_cnt == 2) begin
                            shift_tx <= data_reg;
                            byte_cnt <= 0;
                            state <= TRANSFER;
                        end
                    end else begin
                        bit_cnt <= bit_cnt - 1;
                    end
                end
            end

            TRANSFER: begin
                if(spi_clk_en && spi_clk) begin
                    shift_rx[bit_cnt] <= spi_miso;
                end
                if(spi_clk_en && !spi_clk) begin
                    spi_mosi <= shift_tx[bit_cnt];
                    if(bit_cnt == 0) begin
                        data_reg <= shift_rx;
                        bit_cnt <= 7;
                        byte_cnt <= byte_cnt + 1;
                        if(byte_cnt == len_reg - 1) begin
                            state <= DONE;
                        end
                    end else begin
                        bit_cnt <= bit_cnt - 1;
                    end
                end
            end

            DONE: begin
                spi_cs_n <= 1;
                status_reg[0] <= 0;
                status_reg[1] <= 1;
                if(!start_reg) state <= IDLE;
            end
        endcase
    end
end

endmodule
