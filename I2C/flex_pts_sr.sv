// $Id: $
// File name:   flex_pts_sr.sv
// Created:     2/5/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: p to s

module flex_pts_sr
#(
  parameter NUM_BITS = 4,
  parameter SHIFT_MSB = 1
)
(
  input wire clk,
  input wire n_rst,
  input wire shift_enable,
  input wire load_enable,
  input wire [NUM_BITS-1:0] parallel_in,  
  output wire serial_out
);

reg [NUM_BITS - 1:0] val;
reg [NUM_BITS - 1:0] temp;


assign serial_out = SHIFT_MSB? val[NUM_BITS - 1]:val[0];

always @ ( parallel_in, val, shift_enable, load_enable) begin

      //enable load
      if ((load_enable == 1'b1) )
      begin
        temp = parallel_in;
      end
      else
      begin
        //enable shift
        if ((shift_enable == 1'b1) )
        begin
        //shift left
        
         if (SHIFT_MSB == 1)
          begin
            temp = {val[NUM_BITS - 2:0], 1'b1 }; 
          end
          else
          //shift right
          begin
            temp = { 1'b1 , val[NUM_BITS - 1 : 1]};
          end
        end //end enable shift
        else
        begin
          temp = val;
        end 
      end
end

always_ff @ (posedge clk, negedge n_rst)
begin
  //reset
  if (n_rst == 1'b0)
  begin
    val = '1;
  end
  //not reset
  else begin
    val = temp;
  end //end reset
end


endmodule