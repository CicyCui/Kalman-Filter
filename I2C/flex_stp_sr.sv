// $Id: $
// File name:   flex_stp_sr.sv
// Created:     2/5/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: the previous file does not have .sv

module flex_stp_sr
#(
  parameter NUM_BITS = 4,
  parameter SHIFT_MSB = 1
)
(
  input wire clk,
  input wire n_rst,
  input wire shift_enable,
  input wire serial_in,
  output wire [NUM_BITS-1:0] parallel_out  
);

reg [NUM_BITS - 1:0] val;

assign parallel_out = val;

always_ff @ (posedge clk, negedge n_rst)
begin
  //reset
  if (n_rst == 1'b0)
  begin
    val = '1;
  end
  
  //not reset
  else begin
    //enable shift
    if (shift_enable == 1'b1)
    begin
      //shift left
      if (SHIFT_MSB == 1)
      begin
        val = { val[NUM_BITS - 2:0], serial_in };     
      end
      else
      //shift right
      begin
        val = { serial_in, val[NUM_BITS - 1:1] };
      end
    end //end enable shift
      
  end
  
end

endmodule