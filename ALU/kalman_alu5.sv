// $Id: $
// File name:   kalman_alu5.sv
// Created:     4/5/2014
// Author:      Haichao Xu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: kalman alu step 5  calculate the kalman gain
module kalman_alu5
  (
  input wire [22:0] S_out, // from step 4
  input wire [22:0] P00_out, // from step 2
  input wire [22:0] P10_out, //from step2
  output wire [12:0] K0_out, // kalman gain K[0], assume kalman gain is 16bits
  output wire [12:0] K1_out //kalman gain K[1]
  );
  assign K0_out = {P00_out,13'b0000000000000}/S_out;  //NOTE: because the Kalman gain is always less than 1
  assign K1_out = {P10_out,13'b0000000000000}/S_out;  //K is 2^-13 per bit
endmodule