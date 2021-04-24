`timescale 1ns/1ns

module structural_adder_tb();
  parameter N = 3;

  reg clock;
  initial clock = 0;
  always #(4) clock <= ~clock;

  reg  [N-1:0] operand1, operand2;
  wire [N:0] adder_output;

  // Note: this assumes that you have the parameter N in your structural_adder code
  // (the bitwidth of your operands)
  structural_adder #(.N(3)) dut (
    .a(operand1),
    .b(operand2),
    .sum(adder_output)
  );

  initial begin
    #0;
    operand1 = 3'b001;
    operand2 = 3'b001;
    #100;
    operand1 = 3'b100;
    #300;
    operand2 = 3'b100;
    #500;
    $finish();
  end

endmodule
