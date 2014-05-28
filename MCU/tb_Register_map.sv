// $Id: $
// File name:   tb_Register_map.sv
// Created:     4/15/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: test bench for register map
`timescale 1ns/1ps

module tb_Register_map();
  
  reg n_rst,clk;
  reg [7:0] data,gyro_add,acc_add,mag_add,declination;
  reg [2:0] addr;
  
  always begin
    clk = 1'b1;
    #100;
    clk = 1'b0;
    #100;
  end
  
  initial
  begin
    #0.1;
    n_rst = 1'b0;
    addr = 3'b111;
    #50;
    n_rst = 1'b1;
    @(posedge clk);
    //set acc
    addr = 3'b000;
    data = 8'b10101010;
    @(posedge clk);
    @(negedge clk);
    if(acc_add == data) $info("Set ACC address PASSED!");
    else $error("Set ACC address FAILED!");
    //set gyro
    addr = 3'b001;
    data = 8'b10100010;
    @(posedge clk);
    @(negedge clk);
    if(gyro_add == data) $info("Set GYRO address PASSED!");
    else $error("Set GYRO address FAILED!");
    //set mag
    addr = 3'b010;
    data = 8'b10111010;
    @(posedge clk);
    @(negedge clk);
    if(mag_add == data) $info("Set MAG address PASSED!");
    else $error("Set MAG address FAILED!");
    //set dec
    addr = 3'b011;
    data = 8'b00101010;
    @(posedge clk);
    @(negedge clk);
    if(declination == data) $info("Set DEC PASSED!");
    else $error("Set DEC FAILED!");
  end
  
  Register_map MAP (
  .n_rst(n_rst),
  .clk(clk),
  .data_in(data),
  .addr_in(addr), // 000->acc_add  001->gyro_add  010->mag_add  011->declination degree else->do not load
  .gyro_add_out(gyro_add),
  .acc_add_out(acc_add),
  .mag_add_out(mag_add),
  .declination_out(declination)
  );
  
  
endmodule