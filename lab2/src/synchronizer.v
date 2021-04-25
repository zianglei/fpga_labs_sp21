`timescale 1ns/1ns

module synchronizer #(parameter WIDTH = 1) (
  input [WIDTH-1:0] async_signal,
  input clk,
  output [WIDTH-1:0] sync_signal
);
  // TODO: Create your 2 flip-flop synchronizer here
  // This module takes in a vector of WIDTH-bit asynchronous
  // (from different clock domain or not clocked, such as button press) signals
  // and should output a vector of WIDTH-bit synchronous signals
  // that are synchronized to the input clk
  wire [WIDTH-1: 0] inter_signal;
  
  REGISTER #(.N(WIDTH)) r1 (
    .clk(clk),
    .d(async_signal),
    .q(inter_signal)
  );

  REGISTER #(.N(WIDTH)) r2 (
    .clk(clk),
    .d(inter_signal),
    .q(sync_signal)
  );

endmodule
