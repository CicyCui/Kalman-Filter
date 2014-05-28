// $Id: $
// File name:   flex_stp_sr.sv
// Created:     2/5/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: flexible and scalable serial-to-parallel shift register

/* Specifications:
All flip-flops use the same clock signal and only update their values on 
same clock signal edge (rising edges for this class)

Shift MSB first :Each bit to get the value of its less significant 
neighbor bit (or the serial input in the case of the least significant bit) 
while the shift enable is active

Shift LSB first :Each bit to get the value of its more significant 
neighbor bit (or the serial input in the case of the least significant bit) 
while the shift enable is active

Each bit retains its current value while the shift enable is in-active.

All flip-flops must asynchronously reset to a predetermined value while the reset signal is
active (usually the idle/default value for the serial input of the shift register which is
normally a logic 1)*/

module flex_stp_sr
#(
  parameter NUM_BITS = 4, //number of bits default to 4
  parameter SHIFT_MSB = 1 //true = shift MSB first, false = shift LSB first
 )
 (
  input wire clk,n_rst,shift_enable,serial_in,
  output wire [NUM_BITS-1:0] parallel_out
  );
 
 reg [NUM_BITS-1:0] data; // parallel output data
 
 assign parallel_out = data;
 
 always_ff @(posedge clk, negedge n_rst) begin
   if( n_rst == 0) begin
     data <= 2**NUM_BITS - 1; //reset output data to 1
   end else if(shift_enable == 1) begin
     if(SHIFT_MSB) begin //shift MSB first
       data <= {data[NUM_BITS - 2:0],serial_in};
       //data[0] <= serial_in;
     end else begin //shift LSB first
       data <= {serial_in,data[NUM_BITS - 1:1]};
       //data <= data[1:NUM_BITS - 1];
       //data[NUM_BITS - 1] <= serial_in;
     end
   end 
 end
 
endmodule