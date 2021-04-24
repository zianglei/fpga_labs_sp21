`timescale 1ns/1ns

module z1top_counter (
  input CLK_100MHZ_FPGA,
  input [3:0] BUTTONS,
  output [3:0] LEDS
);

  // Some initial code has been provided for you
  wire [3:0] led_cnt_value;
  wire [3:0] led_cnt_next;
  wire led_cnt_ce;

  assign LEDS[3:0] = led_cnt_value;

  // This register will be updated every one second,
  // and the value will be displayed on the LEDs
  REGISTER_CE #(.N(4)) led_cnt (
    .clk(CLK_100MHZ_FPGA),
    .ce(led_cnt_ce),
    .d(led_cnt_next),
    .q(led_cnt_value));

  assign led_cnt_next = led_cnt_value + 1;

  // TODO: Instantiate another REGISTER module to count the number of cycles
  // required to reach one second. Note that our clock period is 10ns.
  // You also need to think of how many bits are needed for your register
  wire [26:0] clk_cnt_value;
  wire [26:0] clk_cnt_next;

  REGISTER #(.N(27)) clk_cnt (
    .clk(CLK_100MHZ_FPGA),
    .d(clk_cnt_next),
    .q(clk_cnt_value)
  );

  assign clk_cnt_next = (clk_cnt_value == 27'd100_000_000 - 1) ? 27'd0 : clk_cnt_value + 1;

  // TODO: Correct the following assignment
  assign led_cnt_ce = (clk_cnt_value == 27'd100_000_000 - 1) ? 1'b1 : 1'b0;

endmodule
