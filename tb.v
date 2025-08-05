`timescale 1ns/1ps

module tb;

  parameter DATA_WIDTH = 8;

  wire [DATA_WIDTH-1:0] data_out;
  wire full;
  wire empty;
  reg [DATA_WIDTH-1:0] data_in;
  reg w_en, wclk, wrst_n;
  reg r_en, rclk, rrst_n;

  reg [DATA_WIDTH-1:0] wdata_q [0:255];
  integer write_ptr = 0;
  integer read_ptr = 0;
  integer i;

  async_fifo #(8, DATA_WIDTH) as_fifo (
    .wclk(wclk),
    .wrst_n(wrst_n),
    .rclk(rclk),
    .rrst_n(rrst_n),
    .w_en(w_en),
    .r_en(r_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
  );

  always #10 wclk = ~wclk;
  always #35 rclk = ~rclk;

  initial begin
    wclk = 0; wrst_n = 0;
    w_en = 0; data_in = 0;

    repeat(5) @(posedge wclk);
    wrst_n = 1;

    repeat(2) begin
      for (i = 0; i < 30; i = i + 1) begin
        @(posedge wclk);
        if (!full) begin
          w_en = (i % 2 == 0);
          if (w_en) begin
            data_in = $random;
            wdata_q[write_ptr] = data_in;
            write_ptr = write_ptr + 1;
          end
        end
      end
      #50;
    end
  end

  initial begin
    rclk = 0; rrst_n = 0;
    r_en = 0;

    repeat(10) @(posedge rclk);
    rrst_n = 1;

    repeat(2) begin
      for (i = 0; i < 30; i = i + 1) begin
        @(posedge rclk);
        if (!empty) begin
          r_en = (i % 2 == 0);
          if (r_en && read_ptr < write_ptr) begin
            if (data_out !== wdata_q[read_ptr]) begin
              $error("Time = %0t: Mismatch! Expected: %h, Got: %h", $time, wdata_q[read_ptr], data_out);
            end else begin
              $display("Time = %0t: PASS: Data = %h", $time, data_out);
            end
            read_ptr = read_ptr + 1;
          end
        end
      end
      #50;
    end
    $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
  end

endmodule
