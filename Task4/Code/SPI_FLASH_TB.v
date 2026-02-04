`timescale 1ns/1ps

module tb_spi_flash_ip;

reg clk;
reg rst_n;

reg wr_en;
reg rd_en;
reg [7:0] addr;
reg [31:0] wdata;
wire [31:0] rdata;

wire spi_cs_n;
wire spi_clk;
wire spi_mosi;
reg spi_miso;

spi_flash_ip dut (
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .addr(addr),
    .wdata(wdata),
    .rdata(rdata),
    .spi_cs_n(spi_cs_n),
    .spi_clk(spi_clk),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("spi_flash_tb.vcd");
    $dumpvars(0, tb_spi_flash_ip);

    clk = 0;
    rst_n = 0;
    wr_en = 0;
    rd_en = 0;
    addr = 0;
    wdata = 0;
    spi_miso = 0;

    #20;
    rst_n = 1;

    #20;
    write_reg(8'h00, 32'h00000003);
    write_reg(8'h04, 32'h00000010);
    write_reg(8'h08, 32'h00000004);
    write_reg(8'h14, 32'h000000AA);
    write_reg(8'h0C, 32'h00000001);

    #500;
    read_reg(8'h10);

    #100;
    $finish;
end

task write_reg(input [7:0] a, input [31:0] d);
begin
    @(posedge clk);
    wr_en <= 1;
    addr <= a;
    wdata <= d;
    @(posedge clk);
    wr_en <= 0;
    addr <= 0;
    wdata <= 0;
end
endtask

task read_reg(input [7:0] a);
begin
    @(posedge clk);
    rd_en <= 1;
    addr <= a;
    @(posedge clk);
    rd_en <= 0;
    addr <= 0;
end
endtask

always @(negedge spi_clk) begin
    spi_miso <= $random;
end

endmodule
