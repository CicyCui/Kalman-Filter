// $Id: $
// File name:   kalman_alu1.sv
// Created:     4/1/2014
// Author:      Haichao Xu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: kalman filter alu
module kalman_alu1
  (
    //input wire clk,
    //input wire n_rst,
    input reg [15:0] angle_in,//from last state
    input reg [15:0] bias_in, // from last bias
    input reg [15:0] new_rate_in,//from gyro
    input reg [7:0] dt_in, //from counter
    //bias_in will not change in this step
    //output reg [15:0] bias_out,  
    output wire [15:0] angle_out // new angle out(will feed to step3 and step 6)
    );
    
    //Step1 predict state
    wire [15:0] rate;
    wire [23:0] dt_angle;
    assign rate = (new_rate_in[15] == 0)? bias_in - {1'b0,new_rate_in[14:0]} : bias_in + {1'b0,new_rate_in[14:0]};  //16 bits   if angle is negative
    //convert it to positive by adding 360 degree on it
      //truncate from 24 bits to 16 bits, assume dt_in is .00000000(all float), rate is 00000000.0000......(4500 is 45.00 degree)
      //first digit is sign, remaining digits are float points
    //assign dt_angle = rate * dt_in; //8+8 bits
      //angle += dt_angle
     assign angle_out = angle_in + rate;
     
    
  endmodule