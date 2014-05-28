// $Id: $
// File name:   tb_Preprocessor.sv
// Created:     4/9/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: test bench for preprocessor
`timescale 1ns/1ps

module tb_Preprocessor();

  reg n_rst,load_acc_in,load_mag_in; //signal from controller to load data from accelerometer registers and magnetic compass registers
  reg [15:0] acc_x_in,acc_y_in,acc_z_in,mag_x_in,mag_y_in,declination_in; //constant value from register map
  reg [15:0] roll_angle_out,pitch_angle_out,yaw_angle_out;
  reg data_done_out; //output data ready to be read
  reg clk;
   
  parameter OUTPUT_FILE = "./docs/Preprocessed.txt";
  parameter INPUT_FILE = "./docs/raw_data.txt";
  
  integer results;
  integer raw_data;
   
   always begin
     clk = 1'b1;
     #100;
     clk = 1'b0;
     #100;
   end
   
   initial 
   begin
     
     results = $fopen(OUTPUT_FILE,"w");
     raw_data = $fopen(INPUT_FILE,"r");
     
     
     n_rst = 1'b1;
     @(posedge clk);
     n_rst = 1'b0;
     load_acc_in = 1'b0;
     load_mag_in = 1'b0;
     @(posedge clk);
     
     while(!$feof(raw_data)) begin
     $fscanf(raw_data, "%d %d %d %*d %*d %*d %d %d %*d %*f %*f %*f %*f %*f %*f\n",acc_x_in,acc_y_in,acc_z_in,mag_x_in,mag_y_in);
     $info("%d %d %d %d %d\n",acc_x_in,acc_y_in,acc_z_in,mag_x_in,mag_y_in);
     declination_in = 16'b0000000000000000;  
     @(posedge clk);
     @(posedge clk);
     @(posedge clk);
     n_rst = 1'b1;
     @(posedge clk);
     @(posedge clk);
     @(posedge clk);
     @(posedge clk);
     @(posedge clk);
     load_acc_in = 1'b1;
     @(posedge clk);
     load_acc_in = 1'b0;
     @(posedge clk);
     while( data_done_out != 1'b1) @(posedge clk);;
     $fwrite(results,"%d %d ",roll_angle_out,pitch_angle_out);
     @(posedge clk);
     @(posedge clk);
     load_mag_in = 1'b1;
     @(posedge clk);
     load_mag_in = 1'b0;
     @(posedge clk);
     @(posedge clk);
     while( data_done_out != 1'b1) @(posedge clk);;
     $fwrite(results,"%d\n",yaw_angle_out);
     @(posedge clk);
     @(posedge clk);
     @(posedge clk);
     @(posedge clk);
     @(posedge clk);
   end//while(!EOF)
   
     $flcose(raw_data);
     $fclose(results);
   end  

Preprocessor  DUT (
  .clk(clk),
  .n_rst(n_rst),
  .load_acc_in(load_acc_in), 
  .load_mag_in(load_mag_in),//signal from controller to load data from accelerometer registers and magnetic compass registers
  .acc_x_in(acc_x_in),
  .acc_y_in(acc_y_in),
  .acc_z_in(acc_z_in),
  .mag_x_in(mag_x_in),
  .mag_y_in(mag_y_in),
  .declination_in(declination_in), //constant value from register map
  .roll_angle_out(roll_angle_out),
  .pitch_angle_out(pitch_angle_out),
  .yaw_angle_out(yaw_angle_out),
  .data_done_out(data_done_out) //output data ready to be read
  );
  


endmodule