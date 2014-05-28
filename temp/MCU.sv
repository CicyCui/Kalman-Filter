// $Id: $
// File name:   MCU.sv
// Created:     4/15/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: microcontroller SPI interface top-level
module MCU (
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
  output wire data_ready_out //signal to micro telling it the output data is ready to be read
  );
  

  reg rollover_flag_R,rollover_flag_F;
  //reg done_flag,configured_flag, clear;
  //reg [2:0] addr; //set to tell register map which value to load
  

  reg rising_found,falling_found;
  reg load_data;//from controller to 16bit pts
  reg [15:0] input_data;
  reg mosi,ss;//synchronized input data
  reg r_clear,f_clear;
  
  //input select MUX
  assign input_data = output_select_in == 2'b00 ? roll_angle_in:
                      (output_select_in == 2'b01 ? pitch_angle_in:
                      (output_select_in == 2'b10 ? yaw_angle_in:0 ));
                      
  MCU_control CONTROLLER (
  .clk(clk),
  .n_rst(n_rst),
  .rolloverR_in(rollover_flag_R), //rollover flag of rising edge counter 
  .rolloverF_in(rollover_flag_F), //rollover flag of falling edge counter
  .write_enable_in(write_enable_in), //write_enable from KF controller
  .MOSI_in(mosi), //master out slave in data from microcontroller
  .SS_in(SS_in),
  .done_out(done_out), // tell the KF controller that current output is done
  .addr_out(addr_out), //tell the register map which value to load
  .configured_out(configured_out), //tell the KF controller that register map has been configured
  .output_ready_out(data_ready_out),//tell the microcontroller that it can read current output value
  .load_data_out(load_data), //tell PTS register to load output value
  .r_clear_out(r_clear),
  .f_clear_out(f_clear)
  );
  
  sync SYNC1(
  .clk(clk),
  .n_rst(n_rst),
  .async_in(MOSI_in),
  .sync_out(mosi)
  );
  
  sync SYNC2(
  .clk(clk),
  .n_rst(n_rst),
  .async_in(SS_in),
  .sync_out(ss)
  );
flex_stp_sr REG_8BIT
 (
  .clk(clk),
  .n_rst(n_rst),
  .shift_enable(rising_found),
  .serial_in(mosi),
  .parallel_out(config_data_out)
  );
   
flex_pts_sr REG_16BIT
(
  .clk(clk),
  .n_rst(n_rst),
  .shift_enable(falling_found),
  .load_enable(load_data),
  .parallel_in(input_data),
  .serial_out(MISO_out)
  );
 
sclk_edge EDGE_DEC (
  .clk(clk),
  .n_rst(n_rst),
  .sclk(sclk_in),
  .rising_edge_found(rising_found),
  .falling_edge_found(falling_found)
  );

 flex_counter RISING_COUNTER (
    .clk(clk),
    .n_rst(n_rst),
    .count_enable(rising_found),
    .clear(r_clear),
    .rollover_val(5'b01000),
    .rollover_flag(rollover_flag_R)
  );
  
flex_counter FALLING_COUNTER (
    .clk(clk),
    .n_rst(n_rst),
    .count_enable(falling_found),
    .clear(f_clear),
    .rollover_val(5'b10000),
    .rollover_flag(rollover_flag_F)
  );
  
endmodule
  
  