module synchronizer #(parameter WIDTH = 4) (
  input clk,
  input rst_n,
  input [WIDTH-1:0] d,
  output reg [WIDTH-1:0] q
);

  reg [WIDTH-1:0] sync1;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sync1 <= 0;
      q <= 0;
    end else begin
      sync1 <= d;
      q <= sync1;
    end
  end

endmodule
