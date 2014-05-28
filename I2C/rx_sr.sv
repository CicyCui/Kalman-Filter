// $Id: $
// File name:   rx_sr.sv
// Created:     3/7/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: wo shi shift register
module rx_sr
(
  input wire clk,
  input wire n_rst,
  input wire sda_in,
  input wire rising_edge_found,
  input wire rx_enable,
  output wire [7:0] rx_data
);

defparam IX.NUM_BITS = 8;

wire shift_enable;
reg newsda;

assign shift_enable = (rising_edge_found == 1'b1 && rx_enable == 1'b1) ? 1'b1 : 1'b0;

//sync
always_ff @ (posedge clk, negedge n_rst)
begin
  if (n_rst == 1'b0)
    begin
      newsda <= 1'b1;
    end
  else
    begin
      newsda <= sda_in;
    end  
end

flex_stp_sr IX(.clk(clk), .n_rst(n_rst), .shift_enable(shift_enable), .serial_in(newsda), .parallel_out(rx_data));

endmodule