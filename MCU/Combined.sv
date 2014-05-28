// $Id: $
// File name:   Combined.sv
// Created:     4/21/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: MCU and register map
module Combined (
  input wire clk,
  input wire n_rst,
  input wire write_enable_in,// load one specified data into the register (set high for one clk period to load desired output data in)
  input wire [1:0] output_select_in, // select the data to output 00->roll 01->pitch 10->yaw
  input wire MOSI_in,//master out slave in data
  input wire sclk_in,//SPI master clk
  input wire SS_in,//SPI slave select 
  input wire [15:0] roll_angle_in,
  input wire [15:0] pitch_angle_in,
  input wire [15:0] yaw_angle_in,
  
  output wire [7:0] config_data_out,
  output wire [2:0] addr_out, //select address in register map
  output wire MISO_out, //master in slave out data
  output wire done_out, //signal to controller telling it one output cycle is finished
  output wire configured_out, //signal to contreller telling it the register map has been configured
  output wire data_ready_out, //signal to micro telling it the output data is ready to be read
  
  input wire [7:0] data_in,
  input wire [2:0] addr_in, // 000->acc_add  001->gyro_add  010->mag_add  011->declination degree  3'b1xx->do not load (MSB is module enable)
  
  output wire [7:0] gyro_add_out,
  output wire [7:0] acc_add_out,
  output wire [7:0] mag_add_out,
  output wire [7:0] declination_out,
  output wire [7:0] dt_out
  
  );
  
  wire [7:0] data;
  wire [2:0] addr;
  
  reg miso,done,configured,data_ready;

  assign config_data_out = data;
  assign addr_out = addr;
  assign MISO_out = miso;
  assign done_out = done;
  assign configured_out = configured;
  assign data_ready_out = data_ready;
  
   MCU DUT (
  .clk(clk),
  .n_rst(n_rst),
  .write_enable_in(write_enable_in),// load one specified data into the register (set high for one clk period to load desired output data in)
  .output_select_in(output_select_in), // select the data to output 00->roll 01->pitch 10->yaw
  .MOSI_in(MOSI_in),//master out slave in data
  .sclk_in(sclk_in),//SPI master clk
  .SS_in(SS_in),//SPI slave select 
  .roll_angle_in(roll_angle_in),
  .pitch_angle_in(pitch_angle_in),
  .yaw_angle_in(yaw_angle_in),
  
  .config_data_out(data),
  .addr_out(addr), //select address in register map
  .MISO_out(miso), //master in slave out data
  .done_out(done), //signal to controller telling it one output cycle is finished
  .configured_out(configured), //signal to contreller telling it the register map has been configured
  .data_ready_out(data_ready)
  );
  
  Register_map MAP (
  .n_rst(n_rst),
  .clk(clk),
  .data_in(data),
  .addr_in(addr), // 000->acc_add  001->gyro_add  010->mag_add  011->declination degree else->do not load
  
  .gyro_add_out(gyro_add_out),
  .acc_add_out(acc_add_out),
  .mag_add_out(mag_add_out),
  .declination_out(declination_out),
  .dt_out(dt_out)
  );
  
   
endmodule