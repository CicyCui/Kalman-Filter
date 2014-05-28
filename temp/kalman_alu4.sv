// $Id: $
// File name:   kalman_alu4.sv
// Created:     4/5/2014
// Author:      Haichao Xu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: kalman alu step 4 update innovation matrix
module kalman_alu4
  (
    input wire [22:0] P00_out, // from step 2
    input wire [15:0] R_angle_in,//constant  0.03     16 bits, all float  11000101 (decimal is 197)
    output wire [22:0] S_out //innovation  will feed to step5
    //  Assume the size of S_out is 32 bits ,  ask God Chen
    );
    assign S_out = P00_out + 23'b00000000000000011111010; // 250 * 2^-13 = 0.03 ,P00_out should be always less than 1, 16bits is float points, plus R_angle_in, which is also 16bits float 
  endmodule