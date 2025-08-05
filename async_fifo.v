`timescale 1ns / 1ps

module async_fifo #(parameter DEPTH=8, DATA_WIDTH=8) (
  input wclk, wrst_n,
  input rclk, rrst_n,
  input w_en, r_en,
  input [DATA_WIDTH-1:0] data_in,
  output [DATA_WIDTH-1:0] data_out,
  output full, empty
);

  parameter PTR_WIDTH = $clog2(DEPTH);

  wire [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync;
  wire [PTR_WIDTH:0] b_wptr, b_rptr;
  wire [PTR_WIDTH:0] g_wptr, g_rptr;

  wire [PTR_WIDTH-1:0] waddr = b_wptr[PTR_WIDTH-1:0];
  wire [PTR_WIDTH-1:0] raddr = b_rptr[PTR_WIDTH-1:0];

  synchronizer #(PTR_WIDTH+1) sync_wptr (
    .clk(rclk),
    .rst_n(rrst_n),
    .d(g_wptr),
    .q(g_wptr_sync)
  );

  synchronizer #(PTR_WIDTH+1) sync_rptr (
    .clk(wclk),
    .rst_n(wrst_n),
    .d(g_rptr),
    .q(g_rptr_sync)
  );

  wptr_handler #(PTR_WIDTH) wptr_h (
    .wclk(wclk),
    .wrst_n(wrst_n),
    .w_en(w_en),
    .g_rptr_sync(g_rptr_sync),
    .b_wptr(b_wptr),
    .g_wptr(g_wptr),
    .full(full)
  );

  rptr_handler #(PTR_WIDTH) rptr_h (
    .rclk(rclk),
    .rrst_n(rrst_n),
    .r_en(r_en),
    .g_wptr_sync(g_wptr_sync),
    .b_rptr(b_rptr),
    .g_rptr(g_rptr),
    .empty(empty)
  );

  fifo_mem #(DEPTH, DATA_WIDTH, PTR_WIDTH) fifom (
    .wclk(wclk),
    .w_en(w_en),
    .rclk(rclk),
    .r_en(r_en),
    .waddr(waddr),
    .raddr(raddr),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
  );

endmodule
