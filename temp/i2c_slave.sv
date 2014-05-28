// $Id: $
// File name:   i2c_slave.sv
// Created:     3/7/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: al;skdjf;lakjseoirpuqwpeoiruqwpokjflksxzjdlkjfsal;kdjfoipqwjheirjnqwkjdfs
module i2c_slave 
(
  input wire clk,
  input wire n_rst,
  input wire scl,
  input wire sda_in,
  input wire [20:0] device_addr,
  input wire acc_read,
  input wire gyro_read,
  input wire mag_read,
  output wire acc_ready,
  output wire gyro_ready,
  output wire mag_ready,
  output wire [47:0] acc_data,
  output wire [47:0] gyro_data,
  output wire [47:0] mag_data
);
  
  reg rising_edge_found,falling_edge_found;
  reg rw_mode,address_match,stop_found,start_found;
  reg [7:0] rx_data; 
  reg byte_received,ack_prep,check_ack,ack_done;
  reg rx_enable;
  reg load_address;
  reg shift_strobe;
  reg [1:0] devicematch;
  reg [7:0] addr;
  reg acc_ready_i;
  reg gyro_ready_i;
  reg mag_ready_i;


  scl_edge I1 (
  .clk(clk),
  .n_rst(n_rst),
  .scl(scl),
  .rising_edge_found(rising_edge_found),
  .falling_edge_found(falling_edge_found)
  );
  
  dataReg I2 (
  .clk(clk),
  .n_rst(n_rst),
  .devicematch(devicematch),
  .shift_strobe(shift_strobe),
  .load_address(load_address),
  .acc_ready(acc_ready_i),
  .gyro_ready(gyro_ready_i),
  .mag_ready(mag_ready_i),
  .acc_data(acc_data),
  .gyro_data(gyro_data),
  .mag_data(mag_data),
  .rx_write_data(rx_data)
  );

  
  decode I3(
  .clk(clk),
  .n_rst(n_rst),
  .scl(scl),
  .sda_in(sda_in),
  .starting_byte(rx_data),
  .rw_mode(rw_mode),
  .address_match(address_match),
  .stop_found(stop_found),
  .start_found(start_found),
  .device_addr(device_addr),
  .devicematch(devicematch)
  );
  
  rx_sr I4(
  .clk(clk),
  .n_rst(n_rst),
  .sda_in(sda_in),
  .rising_edge_found(rising_edge_found),
  .rx_enable(rx_enable),
  .rx_data(rx_data)
  );
  
  outputUnit I6(
  .clk(clk),
  .n_rst(n_rst),
  .acc_read(acc_read),
  .gyro_read(gyro_read),
  .mag_read(mag_read),
  .acc_ready_i(acc_ready_i),
  .gyro_ready_i(gyro_ready_i),
  .mag_ready_i(mag_ready_i),
  .acc_ready_o(acc_ready),
  .gyro_ready_o(gyro_ready),
  .mag_ready_o(mag_ready)
  );
  
  timer I7 (
  .clk(clk),
  .n_rst(n_rst),
  .rising_edge_found(rising_edge_found),
  .falling_edge_found(falling_edge_found),
  .stop_found(stop_found),
  .start_found(start_found),
  .byte_received(byte_received),
  .ack_prep(ack_prep),
  .check_ack(check_ack),
  .ack_done(ack_done)
  );
  
  controller I8 (
  .clk(clk),
  .n_rst(n_rst),
  .stop_found(stop_found),
  .start_found(start_found),
  .byte_received(byte_received),
  .ack_prep(ack_prep),
  .check_ack(check_ack),
  .ack_done(ack_done),
  .rw_mode(rw_mode),
  .address_match(address_match),
  .sda_in(sda_in),
  .rx_enable(rx_enable),
  .shift_strobe(shift_strobe),
  .load_address(load_address)
  );
   
endmodule