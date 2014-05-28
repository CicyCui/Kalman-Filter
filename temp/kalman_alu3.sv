// $Id: $
// File name:   kalman_alu3.sv
// Created:     4/5/2014
// Author:      Haichao Xu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: kalman alu step3 update measurement
module kalman_alu3
  (
  input wire [15:0] new_angle_in, //from the accelermeter
  input wire [15:0] angle_out, //from the kalman alu step1 (predict angle based on last angle)
  output wire [15:0] y_out
  );
  //assign y_out = (new_angle_in > angle_out)? new_angle_in - angle_out : ( {1'b1,angle_out[15:1] - new_angle_in[15:1]}); // ask God Chen
  assign y_out = (angle_out > new_angle_in)?  {angle_out[15:1]-new_angle_in[15:1],1'b1}: ( {new_angle_in[15:1] - angle_out[15:1],1'b0});
endmodule