`timescale 1ns/1ps

module tb_GPIO;

  reg clk;
  reg reset;
  reg we;
  reg re;
  reg [31:0] data_in;
  wire [31:0] data_out;
  wire [31:0] gpio_out;

  GPIO dut (
    .clk(clk),
    .reset(reset),
    .we(we),
    .re(re),
    .data_in(data_in),
    .data_out(data_out),
    .gpio_out(gpio_out)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("gpio.vcd");
    $dumpvars(0, tb_GPIO);

    clk = 0;
    reset = 1;
    we = 0;
    re = 0;
    data_in = 32'h0;

    #10;
    reset = 0;

    #10;
    we = 1;
    data_in = 32'hA5A5A5A5;

    #10;
    we = 0;

    #10;
    re = 1;

    #10;
    re = 0;

    #10;
    we = 1;
    data_in = 32'h12345678;

    #10;
    we = 0;

    #10;
    re = 1;

    #10;
    re = 0;

    #20;
    $finish;
  end

endmodule
