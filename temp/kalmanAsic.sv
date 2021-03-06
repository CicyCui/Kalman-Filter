// $Id: $
// File name:   kalmanAsic.sv
// Created:     4/26/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: top level
module kalmanAsic
(
  input wire clk,
  input wire n_rst,
  input wire scl,
  input wire sda_in,
  input wire MOSI_in,
  input wire sclk_in,
  input wire SS_in,
  output wire MISO_out
);

reg [23:0] device_addr;
reg acc_read, gyro_read, mag_read;
reg acc_ready, gyro_ready, mag_ready;
reg [47:0] acc_data;
reg [47:0] gyro_data;
reg [47:0] mag_data;

reg configured;
reg kalman_done;
reg output_done;
reg load_preprocessor1;
reg load_preprocessor2;
reg load_gyro;
reg roll_en;
reg pitch_en;
reg yaw_en;
reg yaw_enable;
reg roll_pitch_enable;
reg clear;
reg write_enable;
reg output_sel;


i2c_slave I2C (
  .clk(clk),
  .n_rst(n_rst),
  .scl(scl),
  .sda_in(sda_in),
  .device_addr(device_addr),
  .acc_read(tb_acc_read),
  .gyro_read(tb_gyro_read),
  .mag_read(tb_mag_read),
  .acc_ready(acc_ready),
  .gyro_ready(gyro_ready),
  .mag_ready(mag_ready),
  .acc_data(acc_data),
  .gyro_data(gyro_data),
  .mag_data(mag_data)
  );
  
  
controllerUnit CTR
(
  .clk(clk),
  .n_rst(n_rst),
  .configured(configured),
  .acc_ready(acc_ready),
  .gyro_ready(gyro_ready),
  .mag_ready(mag_ready),
  .kalman_done(kalman_done),
  .output_done(output_done),
  .acc_read(acc_read),
  .gyro_read(gyro_read),
  .mag_read(mag_read),
  .load_preprocessor1(load_preprocessor1),
  .load_preprocessor2(load_preprocessor2),
  .load_gyro(load_gyro),
  .roll_clk(roll_en),
  .pitch_clk(pitch_en),
  .yaw_clk(yaw_en),
  .yaw_enable(yaw_enable),
  .roll_pitch_enable(roll_pitch_enable),
  .clear(clear),
  .write_enable(write_enable),
  .output_sel(output_sel)
);

control_timer TIM
(
  .(clk)clk,
  .n_rst(n_rst),
  .clear(clear),
  .roll_pitch_enable(roll_pitch_enable),
  .yaw_enable(yaw_enable),
  .kalman_done(kalman_done)
);


  wire [7:0] data;
  wire [2:0] addr;
  wire [15:0] declination;
  wire [7:0] gyro_add_out;
  wire [7:0] acc_add_out;
  wire [7:0] mag_add_out;
  wire [15:0] roll_angle;
  wire [15:0] pitch_angle;
  wire [15:0] yaw_angle;
  wire [15:0] kroll_angle;
  wire [15:0] kpitch_angle;
  wire [15:0] kyaw_angle;
  wire [7:0] dt;
  
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
  .write_enable_in(write_enable),// load one specified data into the register (set high for one clk period to load desired output data in)
  .output_select_in(output_sel), // select the data to output 00->roll 01->pitch 10->yaw
  .MOSI_in(MOSI_in),//master out slave in data
  .sclk_in(sclk_in),//SPI master clk
  .SS_in(SS_in),//SPI slave select 
  .roll_angle_in(kroll_angle),
  .pitch_angle_in(kpitch_angle),
  .yaw_angle_in(kyaw_angle),
  
  .config_data_out(data),
  .addr_out(addr), //select address in register map
  .MISO_out(miso), //master in slave out data
  .done_out(outputdone), //signal to controller telling it one output cycle is finished
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
  .declination_out(declination),
  .dt_out(dt)
  );
  
  assign device_addr = {mag_add_out[6:0], mag_add_out[6:0], acc_add_out[6:0]};
  
  
  Preprocessor  PREPROC (
  .clk(clk),
  .n_rst(n_rst),
  .load_acc_in(load_preprocessor1), //signal from controller to load data from accelerometer registers and magnetic compass registers
  .load_mag_in(load_preprocessor2),
  .acc_x_in(acc_data[15:0]), //x
  .acc_y_in(acc_data[31:16]), //y
  .acc_z_in(acc_data[47:32]), //z
  .mag_x_in(mag_data[15:0]),//x
  .mag_y_in(mag_data[31:16]), //y
  .declination_in(declination), //constant value from register map
  .roll_angle_out(roll_angle_out),
  .pitch_angle_out(pitch_angle_out),
  .yaw_angle_out(yaw_angle_out),
  .data_done_out(data_done_out) //output data ready to be read
  );
  
  kalman_alu ALU(
  .clk(clk),
  .n_rst(n_rst),
  .gyro_data(gyro_data), 
  .dt_in(dt_in),
  .yaw_data(yaw_angle),
  .roll_data(roll_angle),
  .new_angle_in(pitch_angle),
  .load_gyro(load_gyro)
  .pitch_en(pitch_en),
  .yaw_en(yaw_en),
  .roll_en(roll_en),
  .pitch_out(kpitch_angle),
  .yaw_out(kyaw_angle),
  .roll_out(kroll_angle)
  );
  

endmodule
  