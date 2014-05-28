// $Id: $
// File name:   kalman_alu2.sv
// Created:     4/2/2014
// Author:      Haichao Xu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: kalman filter alu step2
//Update P matrix
module kalman_alu2
  (
  //For subtraction, I just use the abs
  //P 2^10(integer) . 2^13 (floating)
  //P and constants and delta t are 2^-(8)per bit   degree such as angle_in and gyro are 360 * 2^-16 per bit
    input wire [22:0] P00_in,
    input wire [22:0] P01_in,
    input wire [22:0] P10_in,
    input wire [22:0] P11_in,
    input wire [7:0] dt_in,
    input wire [15:0] Q_gyrobias_in, // 0.003    16'h00C5 constant  all float
    input wire [15:0] Q_angle_in, // 0.001     16'h0042 constant all float
    output wire [22:0] P00_out,  // will feed to step 4 and step 5
    output wire [22:0] P01_out,
    output wire [22:0] P10_out,
    output wire [22:0] P11_out
    );
    wire [22:0] temp_P_all_2;
    wire [30:0] temp_P11_in;
    wire [30:0] temp_P11_in_temp;
    wire [22:0] temp_P_all;
    wire [30:0] temp_P_all_1;
        wire [30:0] temp_P_all_1_temp;
    wire [30:0] temp_P01;
        wire [30:0] temp_P01_temp;
    wire [23:0] temp_gyro;
    //assign Q_gyrobias_in = 16'h00C5;
    //assign Q_angle_in = 16'h0042;
    assign temp_P11_in_temp = P11_in * dt_in; // 23 + 8 bits
    assign temp_P11_in = {15'b000000000000000,temp_P11_in_temp[30:23]};
    assign temp_P_all_2 = (temp_P11_in[30:8] > P01_in)? temp_P11_in[30:8] - P01_in : P01_in - temp_P11_in[30:8]; 
    assign temp_P_all = (temp_P_all_2 > P10_in)? temp_P_all_2 - P10_in + 16'b0000000000001000 : P10_in - temp_P_all_2 + 16'b0000000000001000; //temp_P11_in truncate from 40 bits to 32 bits, I didn't apply +36000 here
    assign temp_P_all_1_temp = dt_in * temp_P_all;//temp_P_all_1 from 40bits to 32bits
    assign temp_P_all_1 = {15'b000000000000000,temp_P_all_1_temp[30:23]};
    
    assign temp_P01_temp = P11_in * dt_in;
    assign temp_P01 = {15'b000000000000000,temp_P01_temp[30:23]};
    assign temp_gyro = 16'b0000000000011001 * dt_in; // check here
    
    assign P00_out = temp_P_all_1[30:8] + P00_in; 
    assign P01_out = (P01_in < {7'b0000000,temp_P01[30:15]})? (temp_P01[30:8] - P01_in) : (P01_in - temp_P01[30:8]);  //check here 
    assign P10_out = (P10_in > {7'b0000000,temp_P01[30:15]})? (P10_in - temp_P01[30:8]) : (temp_P01[30:8] - P10_in);   //check here
    assign P11_out = temp_gyro[23:8] + P11_in;
  endmodule
  
  /*
  NOTE:
  Q_angle_in = 0.001  16 bits 0000000000001000 8*2^-13 = 0.001
  Q_gyrobias_in = 0.003 16 bits 0000000000011001 25*2^-13 = 0.003
  
  */
  