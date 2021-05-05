
module uart #(
  parameter CLOCK_FREQ = 100_000_000,
  parameter BAUD_RATE  = 115_200
) (
  input clk,
  input rst,

  input  serial_in,
  output serial_out
);

  wire enq_data_ready, enq_data_valid;
  wire deq_data_ready, deq_data_valid;

  wire[7:0] rx_data_out, tx_data_in;

  uart_receiver #(
    .CLOCK_FREQ(CLOCK_FREQ),
    .BAUD_RATE(BAUD_RATE)
  ) uart_rx (
    .clk(clk),
    .rst(rst),
    .data_out_ready(enq_data_ready),
    .data_out_valid(enq_data_valid),
    .data_out(rx_data_out),
    .serial_in(serial_in)
  );

  uart_transmitter #(
    .CLOCK_FREQ(CLOCK_FREQ),
    .BAUD_RATE(BAUD_RATE)
  ) uart_tx (
    .clk(clk),
    .rst(rst),
    .data_in(tx_data_in),
    .data_in_valid(deq_data_valid),
    .data_in_ready(deq_data_ready),
    .serial_out(serial_out)
  );

  wire [7:0] inverse_out, enq_data;

  assign inverse_out = rx_data_out ^ 8'd32;
  assign enq_data = ((rx_data_out >= 8'd65 && rx_data_out <= 8'd90) || 
      (rx_data_out >= 8'd97 && rx_data_out <= 8'd122)) ? inverse_out : rx_data_out;


  fifo #(
    .WIDTH(8), 
    .LOGDEPTH(8)
  ) buffer (
    .clk(clk),
    .rst(rst),
    .enq_valid(enq_data_valid),
    .enq_ready(enq_data_ready),
    .enq_data(enq_data),

    .deq_valid(deq_data_valid),
    .deq_ready(deq_data_ready),
    .deq_data(tx_data_in)
  );

endmodule
