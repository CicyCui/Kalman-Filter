// $Id: $
// File name:   kalman_alu6.sv
// Created:     4/5/2014
// Author:      Haichao Xu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: kalman alu step 6, update the state
module kalman_alu6
  (
  input wire [12:0] K0_out, // from step 5
  input wire [12:0] K1_out,
  input wire [15:0] y_out, // from step 3
  input wire [15:0] bias_in, // from last bias, same with step 1
  input wire [15:0] angle_out, // from step 1
  output wire [15:0] angle_out_out, // new angle output after step 6
  output wire [15:0] bias_out
  );
  wire sign;
  wire [28:0] temp1;
  wire [28:0] temp2;
  assign temp1 = K0_out * y_out;    // floating * degree
  assign temp2 = K1_out * y_out;    // floating * degree
  assign sign = y_out[0];
  assign angle_out_out = sign == 0 ? temp1[28:13] + angle_out : angle_out - temp1[28:13]; // Kalman gain is float points
  assign bias_out = temp2[28:13] + bias_in;
endmodule
  