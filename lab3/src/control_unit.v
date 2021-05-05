`timescale 1ns/1ns

module control_unit # (
  parameter WIDTH = 5
) (
  input clk,
  input rst,
  input [3:0] buttons_pressed,
  input [1:0] SWITCHES,

  output [WIDTH-1:0] keypad_value,

  output mem_addr_cen,
  output op_a_cen,
  output op_b_cen,
  output result_cen,

  output mem_read,
  output mem_write,
  output write_sel,
  output displ_sel,
  output idle
);

  // buttons_pressed[0] -- increment
  // buttons_pressed[1] -- decrement
  // buttons_pressed[2] -- set
  // SWITCHES[1:0] = 2'b00 -- buttons_pressed[3] -> addr -> buttons_pressed[2] -> data -> buttons_pressed[2]
  // SWITCHES[1:0] = 2'b01 -- buttons_pressed[3] -> addr -> buttons_pressed[2] -> display read result
  // SWITCHES[1:0] = 2'b10 -- buttons_pressed[3] -> addr_op_a -> buttons_pressed[2] -> addr_op_b -> buttons_pressed[2] -> addr_result -> buttons_pressed[2] -> display add result
  // SWITCHES[1:0] = 2'b11 -- buttons_pressed[3] -> reset

  // displ_sel: 0 -- keypad_value, 1 -- result_value
  // write_sel: 0 -- keypad_value, 1 -- result_value

  // TODO: Your code to implement the Control logic for your Calculator
  // Some code has been provided, but please feel free to modify them
  // You might also need to write your own testbench to verify the functionality

  // What states do we need?
  localparam STATE_IDLE = 3'b0;
  localparam STATE_WRITE_ADDR = 3'b001;
  localparam STATE_WRITE_DATA = 3'b010;
  localparam STATE_READ_ADDR = 3'b011;
  localparam STATE_COMPUTE_OPERAND_FIRST = 3'b100;
  localparam STATE_COMPUTE_OPERAND_SECOND = 3'b101;
  localparam STATE_COMPUTE_WRITE_RESULT = 3'b110;
  localparam STATE_RST = 3'b111;

  // state register. Make sure that you change the width according to
  // the number of states you have in your design
  // At reset, the state register should be reset to STATE_IDLE
  reg  [2:0] state_next; // it is declared as 'reg', but it is not an actual reg
  wire [2:0] state_value;

  REGISTER_R #(.N(2), .INIT(STATE_IDLE)) state_reg (
    .clk(clk),
    .rst(rst),
    .d(state_next),
    .q(state_value)
  );

  // The keypad register holds the value when we press BTNS[0] or BTNS[1]
  wire [WIDTH-1:0] keypad_reg_value, keypad_reg_next;
  wire keypad_reg_ce, keypad_reg_rst;

  REGISTER_R_CE #(.N(WIDTH), .INIT(0)) keypad_reg (
    .clk(clk),
    .d(keypad_reg_next),
    .q(keypad_reg_value),
    .ce(keypad_reg_ce),
    .rst(keypad_reg_rst)
  );

  // We use the combinational always block to build the combinational logic
  // for updating state_next
  // Good practice: just use '*' for the sensitivity list
  always @(*) begin
    // Within the scope of a combinational always block, last assign statement wins (blocking assigment)
    // Therefore, it is safe to have this statement here (we won't get multi-driven signal error)
    // And this is also a good practice. If you forget to set all possible inputs for
    // 'state_next' here, the Synthesis tool will infer it as "latch". Latch is a level-sensitive
    // storage element. We don't want it here, since all we want is just a combinational circuit
    // that setups 'state_next'.
    // Another way of avoiding the latch issue is to ensure that your case statement has a default case
    // to assign default value to 'state_next'
    state_next = state_value;

    case (state_value)
      STATE_IDLE: begin
        // FIXME
        if (SWITCHES[1:0] == 2'b00 && buttons_pressed[3]) begin
          state_next = STATE_WRITE_ADDR;
        end else if (SWITCHES[1:0] == 2'b01 && buttons_pressed[3]) begin
          state_next = STATE_READ_ADDR;
        end else if (SWITCHES[1:0] == 2'b10 && buttons_pressed[3]) begin
          state_next = STATE_COMPUTE_OPERAND_FIRST;
        end else if (SWITCHES[1:0] == 2'b11 && buttons_pressed[3]) begin
          state_next = STATE_RST;
        end
      end
      STATE_WRITE_ADDR: begin
        if (buttons_pressed[2]) state_next = STATE_WRITE_DATA; 
      end
      STATE_WRITE_DATA: begin
        if (buttons_pressed[2]) state_next = STATE_IDLE;
      end
      STATE_READ_ADDR: begin
        if (buttons_pressed[2]) state_next = STATE_IDLE;
      end
      STATE_COMPUTE_OPERAND_FIRST: begin
        if (buttons_pressed[2]) state_next = STATE_COMPUTE_OPERAND_SECOND;
      end
      STATE_COMPUTE_OPERAND_SECOND: begin
        if (buttons_pressed[2]) state_next = STATE_COMPUTE_WRITE_RESULT;
      end
      STATE_COMPUTE_WRITE_RESULT: begin
        if (buttons_pressed[2]) state_next = STATE_IDLE;
      end
      STATE_RST: begin
        state_next = STATE_IDLE;
      end
    endcase
  end

  assign keypad_reg_next = (buttons_pressed[0] == 1'b1) ? keypad_reg_value + 1 :
                           (buttons_pressed[1] == 1'b1) ? keypad_reg_value - 1 : keypad_reg_value;
  assign keypad_reg_rst  = rst || (state_value == STATE_RST) || (buttons_pressed[2]);
  assign keypad_reg_ce   = !(state_value == STATE_IDLE);

  assign op_a_cen     = state_value == STATE_COMPUTE_OPERAND_FIRST;
  assign op_b_cen     = state_value == STATE_COMPUTE_OPERAND_SECOND;
  assign result_cen   = state_value == STATE_READ_ADDR || state_value == STATE_COMPUTE_WRITE_RESULT;
  assign mem_addr_cen = !(state_value == STATE_IDLE) && buttons_pressed[2];

  assign mem_read  = state_value == STATE_READ_ADDR; // FIXME
  assign mem_write = (state_value == STATE_WRITE_DATA || state_value == STATE_COMPUTE_WRITE_RESULT) && buttons_pressed[2];

  assign write_sel = result_cen;
  assign displ_sel = result_cen;

  assign keypad_value = keypad_reg_value;
  assign idle = (state_value == STATE_IDLE);

endmodule
