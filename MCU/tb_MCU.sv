// $Id: $
// File name:   tb_MCU.sv
// Created:     4/15/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: test bench for MCU
`timescale 1ns/1ps

module tb_MCU();
  
  
  reg n_rst,clk;
  reg [7:0] data,gyro_add,acc_add,mag_add,declination;
  reg [2:0] addr;
  
  reg write_enable,mosi,miso,sclk,ss,done,configured,data_ready;
  reg [1:0] output_select;
  reg [15:0] roll_angle,pitch_angle,yaw_angle;

  reg [15:0] SPI_output;
  reg [7:0] mosi_data;  
  
  
  int ct;
  
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
    write_enable = 1'b0;
    output_select = 2'b11;
    mosi = 1'b0;
    sclk = 1'b0;
    roll_angle = 16'b0000111100001111;
    pitch_angle = 16'b0010110100000111;
    yaw_angle = 16'b0101111000001101;
    #50;
    n_rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    mosi = 1'b1;
    @(posedge clk);
    @(posedge clk);
    mosi = 1'b0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
 
    
    //set acc
    mosi_data = 8'b01010101;
    for( ct=0;ct<8;ct++) //clock out data
    begin
    mosi = mosi_data[7];
    mosi_data = {mosi_data[6:0],1'b0};
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk = 1'b0;
    end
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    if(acc_add == 8'b01010101) $info("Set ACC address PASSED!");
    else $error("Set ACC address FAILED!");
      
    //set gyro
    @(posedge clk);
    @(negedge clk);
    mosi_data = 8'b00001111;
    for( ct=0;ct<8;ct++) //clock out data
    begin
    mosi = mosi_data[7];
    mosi_data = {mosi_data[6:0],1'b0};
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk = 1'b0;
    end
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    if(gyro_add == 8'b00001111) $info("Set GYRO address PASSED!");
    else $error("Set GYRO address FAILED!");
    //set mag
    @(posedge clk);
    @(negedge clk);
    mosi_data = 8'b10000001;
    for( ct=0;ct<8;ct++) //clock out data
    begin
    mosi = mosi_data[7];
    mosi_data = {mosi_data[6:0],1'b0};
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk = 1'b0;
    end
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    if(mag_add == 8'b10000001) $info("Set MAG address PASSED!");
    else $error("Set MAG address FAILED!");
    //set dec
    @(posedge clk);
    @(negedge clk);
    mosi_data = 8'b00000101;
    for( ct=0;ct<8;ct++) //clock out data
    begin
    mosi = mosi_data[7];
    mosi_data = {mosi_data[6:0],1'b0};
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk = 1'b0;
    end
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    if( declination == 8'b00000101) $info("Set DEC PASSED!");
    else $error("Set DEC FAILED!");
      
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
    
    mosi = 1'b0;
    //Read output data
    
    //testcase 1: output roll angle
    output_select = 2'b00;
    write_enable = 1'b1;
    @(posedge clk);
    write_enable = 1'b0;
    @(posedge clk);
    @(posedge clk);
    if(data_ready == 1'b1) $info("Data_ready successfully SET");
    else $error("Failed to set data_ready!");
    @(posedge clk);
    @(posedge clk);
    for( ct=0;ct<16;ct++) 
    begin
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk = 1'b0;
    @(posedge clk);
    @(posedge clk);
    SPI_output = {SPI_output[14:0],miso};
    end 
    if(SPI_output == roll_angle) $info("Output roll_angle PASSED!");
    else $error("Output roll_angle FAILED!");
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    
    //testcase 2: output pitch angle
    output_select = 2'b01;
    write_enable = 1'b1;
    @(posedge clk);
    write_enable = 1'b0;
    @(posedge clk);
    @(posedge clk);
    if(data_ready == 1'b1) $info("Data_ready successfully SET");
    else $error("Failed to set data_ready!");
    @(posedge clk);
    @(posedge clk);
    for( ct=0;ct<16;ct++) 
    begin
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk = 1'b0;
    @(posedge clk);
    @(posedge clk);
    SPI_output = {SPI_output[14:0],miso};
    end 
    if(SPI_output == pitch_angle) $info("Output pitch_angle PASSED!");
    else $error("Output pitch_angle FAILED!");
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    
     
    //testcase 3: output yaw angle
    output_select = 2'b10;
    write_enable = 1'b1;
    @(posedge clk);
    write_enable = 1'b0;
    @(posedge clk);
    @(posedge clk);
    if(data_ready == 1'b1) $info("Data_ready successfully SET");
    else $error("Failed to set data_ready!");
    @(posedge clk);
    @(posedge clk);
    for( ct=0;ct<16;ct++) 
    begin
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk = 1'b0;
    @(posedge clk);
    @(posedge clk);
    SPI_output = {SPI_output[14:0],miso};
    end 
    if(SPI_output == yaw_angle) $info("Output yaw_angle PASSED!");
    else $error("Output yaw_angle FAILED!");
    @(posedge clk);
    @(posedge clk);
  end
  
 Combined DUTT (
  .clk(clk),
  .n_rst(n_rst),
  .write_enable_in(write_enable),// load one specified data into the register (set high for one clk period to load desired output data in)
  .output_select_in(output_select), // select the data to output 00->roll 01->pitch 10->yaw
  .MOSI_in(mosi),//master out slave in data
  .sclk_in(sclk),//SPI master clk
  .SS_in(ss),//SPI slave select 
  .roll_angle_in(roll_angle),
  .pitch_angle_in(pitch_angle),
  .yaw_angle_in(yaw_angle),
  .config_data_out(data),
  .addr_out(addr), //select address in register map
  .MISO_out(miso), //master in slave out data
  .done_out(done), //signal to controller telling it one output cycle is finished
  .configured_out(configured), //signal to contreller telling it the register map has been configured
  .data_ready_out(data_ready),
  .data_in(data),
  .addr_in(addr), // 000->acc_add  001->gyro_add  010->mag_add  011->declination degree else->do not load
  .gyro_add_out(gyro_add),
  .acc_add_out(acc_add),
  .mag_add_out(mag_add),
  .declination_out(declination)
  );
  
endmodule