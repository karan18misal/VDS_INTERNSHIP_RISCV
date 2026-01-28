`timescale 1ns/1ps

module tb_GPIO;

  reg clk;
  reg reset;
  reg we;
  reg re;
  reg [3:0] addr;
  reg [31:0] wdata;
  reg [31:0] gpio_in;
  wire [31:0] rdata;
  wire [31:0] gpio_out;
  wire [31:0] gpio_dir;

  gpio_control_ip dut (
    .clk(clk),
    .reset(reset),
    .we(we),
    .re(re),
    .addr(addr),
    .wdata(wdata),
    .rdata(rdata),
    .gpio_in(gpio_in),
    .gpio_out(gpio_out),
    .gpio_dir(gpio_dir)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("gpio.vcd");
    $dumpvars(0, tb_GPIO);

    clk = 0;
    reset = 1;
    we = 0;
    re = 0;
    addr = 4'h0;
    wdata = 32'h0;
    gpio_in = 32'h0;

    #10;
    reset = 0;

    #10;
    we = 1;
    addr = 4'h4;
    wdata = 32'h0000000F;

    #10;
    we = 0;

    #10;
    we = 1;
    addr = 4'h0;
    wdata = 32'h00000005;

    #10;
    we = 0;

    #10;
    re = 1;
    addr = 4'h8;

    #10;
    re = 0;

    #10;
    gpio_in = 32'h000000A0;

    #10;
    re = 1;
    addr = 4'h8;

    #10;
    re = 0;

    #20;
    $finish;
  end

endmodule
