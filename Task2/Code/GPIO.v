module GPIO (
    input  clk,
    input  reset,
    input  we,
    input  re,
    input  [31:0] data_in,
    output [31:0] data_out,
    output [31:0] gpio_out
);
  reg [31:0] data;
  
  always @(posedge clk) begin
    if (reset) begin
      data <= 32'b0;
    end else if (we) begin
      data <= data_in;
    end
  end
  
  always @(posedge clk) begin
    if (re)
      data_out = data;
    else
      data_out = 32'b0;
  end
  
  always @(posedge clk) begin
    if (reset)
      gpio_out <= 32'b0;
    else
      gpio_out <= data;
  end
endmodule
