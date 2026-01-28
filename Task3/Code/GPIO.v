module gpio_control_ip (
    input               clk,
    input               reset,
    input               we,
    input               re,
    input       [3:0]   addr,
    input       [31:0]  wdata,
    output reg  [31:0]  rdata,
    input       [31:0]  gpio_in,
    output      [31:0]  gpio_out,
    output      [31:0]  gpio_dir
);

    reg [31:0] gpio_data_reg;
    reg [31:0] gpio_dir_reg;

    always @(posedge clk) begin
        if (reset) begin
            gpio_data_reg <= 32'h0;
            gpio_dir_reg  <= 32'h0;
        end else if (we) begin
            case (addr)
                4'h0: gpio_data_reg <= wdata;
                4'h4: gpio_dir_reg  <= wdata;
                default: ;
            endcase
        end
    end

    always @(*) begin
        if (re) begin
            case (addr)
                4'h0: rdata = gpio_data_reg;
                4'h4: rdata = gpio_dir_reg;
                4'h8: rdata = (gpio_dir_reg & gpio_data_reg) |
                              (~gpio_dir_reg & gpio_in);
                default: rdata = 32'h0;
            endcase
        end else begin
            rdata = 32'h0;
        end
    end

    assign gpio_out = gpio_data_reg & gpio_dir_reg;
    assign gpio_dir = gpio_dir_reg;

endmodule
