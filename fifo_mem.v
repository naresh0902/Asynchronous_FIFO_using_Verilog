module fifo_mem #(parameter DEPTH=8, DATA_WIDTH=8, PTR_WIDTH=3) (
  input wclk, w_en,
  input rclk, r_en,
  input [PTR_WIDTH-1:0] waddr, raddr,
  input [DATA_WIDTH-1:0] data_in,
  input full, empty,
  output reg [DATA_WIDTH-1:0] data_out
);

  reg [DATA_WIDTH-1:0] fifo [0:DEPTH-1];

  always @(posedge wclk) begin
    if (w_en && !full)
      fifo[waddr] <= data_in;
  end

  always @(posedge rclk) begin
    if (r_en && !empty)
      data_out <= fifo[raddr];
  end

endmodule
