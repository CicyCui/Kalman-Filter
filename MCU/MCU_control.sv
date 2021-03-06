// $Id: $
// File name:   MCU_control.sv
// Created:     4/19/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: controller module
module MCU_control(
  input wire clk,
  input wire n_rst,
  input wire rolloverR_in, //rollover flag of rising edge counter 
  input wire rolloverF_in, //rollover flag of falling edge counter
  input wire write_enable_in, //write_enable from KF controller
  input wire MOSI_in, //master out slave in data from microcontroller
  input wire SS_in,//slave select
  output wire done_out, // tell the KF controller that current output is done
  output wire [2:0] addr_out, //tell the register map which value to load
  output wire configured_out, //tell the KF controller that register map has been configured
  output wire output_ready_out,//tell the microcontroller that it can read current output value
  output wire load_data_out, //tell PTS register to load output value
  output wire r_clear_out, // clear signal to rising edge counter
  output wire f_clear_out, //clear signal to falling edge counter
  output wire [3:0] state
  );
  

  reg [2:0] addr; //set to tell register map which value to load
  reg done_flag,configured_flag,ready_flag,load_data;
  reg r_clear,f_clear,curr_config,next_config;
  
  typedef enum bit [3:0] {Idle, Load_acc, Store_acc, Load_gyro, Store_gyro, Load_mag, Store_mag, Load_dec, Store_dec, Load_dt, Store_dt,
                          Load_data, Output_data, Done} StateType;
  
  StateType curr_state,next_state;
  
  //assign state = curr_state;
 
  assign done_out = done_flag;
  assign configured_out = curr_config; 
  assign output_ready_out = ready_flag;
  assign addr_out = addr;
  assign load_data_out = load_data;
  
  assign r_clear_out = r_clear;
  assign f_clear_out = f_clear;
   
  always_ff @(posedge clk,negedge n_rst) begin
    if(n_rst == 1'b0) begin
      curr_state <= Idle;
      curr_config <= 1'b0;
    end else begin
      curr_state <= next_state;
      curr_config <= next_config;
    end
  end
  
  always_comb begin
    
    next_state = curr_state;
    r_clear = 1'b0;
    f_clear = 1'b0;
    done_flag = 1'b0;
    configured_flag = 1'b0;
    ready_flag = 1'b0;
    addr = 3'b111;
    load_data = 1'b0;
    next_config = curr_config;
    
    if(SS_in == 1'b1) begin
    case(curr_state) 
    Idle:
    begin
      r_clear = 1'b1;
      f_clear = 1'b1;
      if(MOSI_in == 1'b1 && curr_config == 1'b0) begin
        next_state = Load_acc;
      end else if ( write_enable_in == 1'b1) begin
        next_state = Load_data;
      end
    end
    Load_acc:
    begin
      //f_clear = 1'b1;
      if(rolloverR_in == 1'b1) begin
        next_state = Store_acc;
      end
    end
    Store_acc:
    begin
      addr = 3'b000;
      next_state = Load_gyro;
      r_clear = 1'b1;
    end
    Load_gyro:
    begin
      //f_clear = 1'b1;
      if(rolloverR_in == 1'b1) begin
        next_state = Store_gyro;
      end
    end
    Store_gyro:
    begin
      //f_clear = 1'b1;
      addr = 3'b001;
      next_state = Load_mag;
      r_clear = 1'b1;
    end
    Load_mag:
    begin
      //f_clear = 1'b1;
      if(rolloverR_in == 1'b1) begin
        next_state = Store_mag;
      end
    end
    Store_mag:
    begin
    //  f_clear = 1'b1;
      addr = 3'b010;
      next_state = Load_dec;
      r_clear = 1'b1;
    end
    Load_dec:
    begin
 
      if(rolloverR_in == 1'b1) begin
        next_state = Store_dec;
      end
    end
    Store_dec:
    begin
      addr = 3'b011;
      next_state = Load_dt;
      r_clear = 1'b1;
    end
    Load_dt:
    begin
      if(rolloverR_in == 1'b1) begin
        next_state = Store_dt;
      end
    end
    Store_dt:
    begin
      addr = 3'b100;
      configured_flag = 1'b1;
      next_state = Idle;
      r_clear = 1'b1;
      next_config = 1'b1;
    end
    
    Load_data:
    begin
      f_clear = 1'b1;
      next_state = Output_data;
      load_data = 1'b1;
    end
    Output_data:
    begin
      ready_flag = 1'b1;
      if(rolloverF_in == 1'b1) begin
        next_state = Done;
      end
    end
    Done:
    begin
      done_flag = 1'b1;
      f_clear = 1'b1;
      next_state = Idle;
    end
  endcase
  end
    
  end
  
endmodule