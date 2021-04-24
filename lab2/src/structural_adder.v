`timescale 1ns/1ns

module structural_adder (
  input [2:0] a,
  input [2:0] b,
  output [3:0] sum
);
  // TODO: Insert your RTL here
  // Remove the assign statement once you write your own RTL
  wire[3:1] carry;

  full_adder f0(.a(a[0]), .b(b[0]), 
                .carry_in(0), 
                .sum(sum[0]), 
                .carry_out(carry[1]));

  genvar i;

  for(i = 1; i < 3; i = i + 1) begin
    full_adder fi(.a(a[i]), .b(b[i]), .carry_in(carry[i]), .sum(sum[i]), .carry_out(carry[i+1]));
  end

  assign sum[3] = carry[3];

endmodule
