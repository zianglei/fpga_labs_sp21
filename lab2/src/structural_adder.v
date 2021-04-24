`timescale 1ns/1ns

module structural_adder #(parameter N = 3) (
  input [N - 1:0] a,
  input [N - 1:0] b,
  output [N:0] sum
);

  // TODO: Insert your RTL here
  // Remove the assign statement once you write your own RTL
  wire[N:1] carry;

  full_adder f0(.a(a[0]), .b(b[0]), 
                .carry_in(0), 
                .sum(sum[0]), 
                .carry_out(carry[1]));

  genvar i;

  for(i = 1; i < N; i = i + 1) begin
    full_adder fi(.a(a[i]), .b(b[i]), .carry_in(carry[i]), .sum(sum[i]), .carry_out(carry[i+1]));
  end

  assign sum[N] = carry[N];

endmodule
