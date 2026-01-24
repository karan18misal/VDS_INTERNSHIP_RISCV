module GPIO (
    input  clk,
    input  reset,
    input  we,
    input  re,
    input  [31:0] data_in,
    output reg [31:0] data_out,
    output reg [31:0] gpio_out
);

  reg [31:0] data1;

  always @(posedge clk) begin
    if (reset) begin
      data1    <= 32'b0;
      data_out <= 32'b0;
      gpio_out <= 32'b0;
    end else begin
      if (we)
        data1 <= data_in;

      if (re)
        data_out <= data1;
      else
        data_out <= 32'b0;

      gpio_out <= data1;
    end
  end

endmodule
