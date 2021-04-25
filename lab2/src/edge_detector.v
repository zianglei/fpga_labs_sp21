`timescale 1ns/1ns

module edge_detector #(
  parameter WIDTH = 1
)(
  input clk,
  input [WIDTH-1:0] signal_in,
  output [WIDTH-1:0] edge_detect_pulse
);

  // TODO: implement a multi-bit edge detector that detects a rising edge of 'signal_in[x]'
  // and outputs a one-cycle pulse 'edge_detect_pulse[x]' at the next clock edge
  // Feel free to use as many number of registers you like

  wire [WIDTH - 1: 0] oldval;
  wire [WIDTH - 1: 0] old_oldval;

  genvar i;
  generate for(i = 0; i < WIDTH; i = i + 1) begin
    REGISTER r1(
      .clk(clk),
      .d(signal_in[i]),
      .q(oldval[i])
    );

    REGISTER r2(
      .clk(clk),
      .d(oldval[i]),
      .q(old_oldval[i])
    );

    assign edge_detect_pulse[i] = oldval[i] & (~old_oldval[i]);
  end
  endgenerate

endmodule
