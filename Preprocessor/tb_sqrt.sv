// $Id: $
// File name:   tb_sqrt.sv
// Created:     4/1/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: test bench for sqrt block
`timescale 1ns/1ps

module tb_sqrt();
  
  reg [31:0] num_in;
  reg [15:0] num_out;
  reg clk;
  reg data_ready;
  
  always begin
    #5;
    clk = 1'b1;
    #5;
    clk = 1'b0;
  end
  
  sqrt DUT (
  .clk(clk),
  .num_in(num_in),
  .num_out(num_out),
  .dataready_out(data_ready)
  );
  
  initial
  begin
    num_in = 0;
    #10;
    num_in = 9;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    num_in = 81;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    num_in = 1000000;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
      
  end
  
  
  
  
endmodule