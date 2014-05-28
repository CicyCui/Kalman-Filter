// $Id: $
// File name:   kalman_alu7.sv
// Created:     4/5/2014
// Author:      Haichao Xu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: update P matrix
module kalman_alu7
  (
  input wire [22:0] P00_out,
  input wire [22:0] P01_out,
  input wire [22:0] P10_out,
  input wire [22:0] P11_out,
  input wire [12:0] K0_out,
  input wire [12:0] K1_out,
  output wire [22:0] P00_out_out,
  output wire [22:0] P01_out_out,
  output wire [22:0] P10_out_out,
  output wire [22:0] P11_out_out
  );
  wire [35:0] temp1;
  wire [35:0] temp2;
  wire [35:0] temp3;
  wire [35:0] temp4;
  assign temp1 = K0_out * P00_out; // floating * floating
  assign temp2 = K0_out * P01_out;
  assign temp3 = K1_out * P00_out;
  assign temp4 = K1_out * P01_out;
  assign P00_out_out = (P00_out > temp1[35:13])? P00_out - temp1[35:13] : temp1[35:13] -  P00_out; //Subtract is doing abs
  assign P01_out_out = (P01_out > temp2[35:13])? P01_out - temp2[35:13] : temp2[35:13] -  P01_out;
  assign P10_out_out = (P10_out > temp3[35:13])? P10_out - temp3[35:13] : temp3[35:13] -  P10_out;
  assign P11_out_out = (P11_out > temp4[35:13])? P11_out - temp4[35:13] : temp4[35:13] -  P11_out;
endmodule
  