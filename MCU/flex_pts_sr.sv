// $Id: $
// File name:   flex_pts_sr.sv
// Created:     2/5/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: flexible and scalable parallel-to-serial shift register
/*All flip-flops use the same clock signal and only update their values on same clock signal
edge (rising edges for this class)

Each bit will change to the value of its corresponding bit in the parallel input vector when
the load signal is active

Each bit will change to the value of its less/more significant neighbor bit (or the reset value in
the case of the least/most significant bit) while the shift enable is active and the load signal is
inactive

Each bit will retain its current value while both the load and shift enable signals are in-
active.

All flip-flops must asynchronously reset to a predetermined value while the reset signal is
active (usually the idle/default value for the serial output of the shift register which is
normally a logic 1)
*/

module flex_pts_sr
#(
  parameter NUM_BITS = 4, //number of bits default to 4
  parameter SHIFT_MSB = 1 //true = shift MSB first, false = shift LSB first
 )
 (
  input wire clk,n_rst,shift_enable,load_enable,
  input wire [NUM_BITS - 1:0] parallel_in,
  output wire serial_out
  );
  
  reg [NUM_BITS - 1:0] data;
  assign serial_out = SHIFT_MSB ? data[NUM_BITS - 1]:data[0];
   
  always_ff @ (posedge clk, negedge n_rst, posedge load_enable) begin
    if(n_rst == 0) begin
      data <= 2**(NUM_BITS) - 1;
    end else if(load_enable) begin
      data <= parallel_in;
    end else if(shift_enable) begin
      if (SHIFT_MSB) begin
         data <= {data[NUM_BITS - 2: 0],1'b1};
      end else begin 
         data <= {1'b1,data[NUM_BITS - 1: 1]};
      end
    end 
  end
  
  endmodule