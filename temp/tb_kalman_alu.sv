// $Id: $
// File name:   tb_kalman_alu.sv
// Created:     4/12/2014
// Author:      Haichao Xu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: testbench for all steps of kalman alu
`timescale 100ns/ 10ps   
//200 ns clk period

module tb_kalman_alu
  ();
  localparam CLK_PERIOD = 10;
  reg tb_clk;
  reg tb_n_rst;
  reg [47:0] tb_gyro_data;
  reg [7:0] tb_dt_in;
  reg [15:0] tb_yaw_data;
  reg [15:0] tb_roll_data;
  reg [15:0] tb_pitch_data; //from the accelermeter
  reg load_gyro;
  //outputs
  reg [15:0] angle_out_out_pitch; // new angle output after step 6
  reg [15:0] angle_out_out_yaw;
  reg [15:0] angle_out_out_roll;
  reg pitch_en;
  reg roll_en;
  reg yaw_en;
    //reg [15:0] tb_angle_out; //from the kalman alu step1 (predict angle based on last angle)
    //reg flag_of_done;


  kalman_alu dut1(.clk(tb_clk),.n_rst(tb_n_rst),.gyro_data(tb_gyro_data), .dt_in(tb_dt_in),.new_angle_in(tb_pitch_data),.pitch_out(angle_out_out_pitch),.yaw_data(tb_yaw_data),.roll_data(tb_roll_data),.yaw_out(angle_out_out_yaw),.roll_out(angle_out_out_roll),.load_gyro(load_gyro),.yaw_en(yaw_en),.pitch_en(pitch_en),.roll_en(roll_en));
     
   always begin : CLK_GEN
     tb_clk = 1'b0;
     #(CLK_PERIOD/2);
     tb_clk = 1'b1;
     #(CLK_PERIOD/2);
   end
   
   

   initial
   begin
  
     
     
     
     
     @(posedge tb_clk);
     tb_n_rst = 0;
      @(negedge tb_clk);
      @(posedge tb_clk);
      //reset and load gyro is 0
      @(negedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h8065809D000F; 
      tb_dt_in = 8'h28; // assume dt is 156.25 ns
      tb_pitch_data = 65445; // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63692;
      tb_roll_data = 99;
      pitch_en = 0;
      roll_en = 0;
      yaw_en = 0;
      load_gyro = 0;

      //@(negedge tb_clk);
      @(posedge tb_clk);
      //enable load_gyro
      tb_n_rst = 1;
      tb_gyro_data = 48'h8065809D000F; 
      tb_dt_in = 8'h28; // dt is     almost 0.125 ms = 125 us
      tb_pitch_data = 65455; // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63692;
      tb_roll_data = 99;
      pitch_en = 1;
      roll_en = 1;
      yaw_en = 1;
      load_gyro = 1;
      
      @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h8067809F0004; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65367; // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63724;
      tb_roll_data = 87;
      pitch_en = 0;
      roll_en = 1;
      yaw_en = 1;
      load_gyro = 1;
      //change gyro data value
      @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h8065808F0006; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65498; // 24.75 degree  accelerometer pitch data
      tb_yaw_data =  65370;
      tb_roll_data = 52;
      pitch_en = 1;
      roll_en = 0;
      yaw_en = 1;
      load_gyro = 1;
      //turn off the load gyro, angle out should remain the same
      @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h80618090000A;
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65450;   // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63692;
      tb_roll_data = 114;
      pitch_en = 1;
      roll_en = 1;
      yaw_en = 0;
      load_gyro = 1;
      //reopen the load gyro
      @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h8065809D001F; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65386;  // 24.75 degree  accelerometer pitch data
      tb_yaw_data =  63334;
      tb_roll_data = 108;
      pitch_en = 1;
      roll_en = 1;
      yaw_en = 1;
      load_gyro = 1;
      //change pitch data
      @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h8068808D000C; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65427;   // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63547;
      tb_roll_data = 23;
      load_gyro = 1;
      
            @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h8068808D000C; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65427;   // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63547;
      tb_roll_data = 23;
      load_gyro = 1;
      
            @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h8068808D000C; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65427;   // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63547;
      tb_roll_data = 23;
      load_gyro = 1;
      
            @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h8068808D000C; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65427;   // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63547;
      tb_roll_data = 23;
      load_gyro = 1;
      
            @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h8068808D000C; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65427;   // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63547;
      tb_roll_data = 23;
      load_gyro = 1;
      
            @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h8068808D000C; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65427;   // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63547;
      tb_roll_data = 23;
      load_gyro = 1;
      
            @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h8068808D000C; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65427;   // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63547;
      tb_roll_data = 23;
      load_gyro = 1;
      
            @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h8068808D000C; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65427;   // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63547;
      tb_roll_data = 23;
      load_gyro = 1;
      
 
      
      @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h80678092000F; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65323;   // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63547;
      tb_roll_data = 22;
      load_gyro = 1;
      @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h80678092000F; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65243;   // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63545;
      tb_roll_data = 45;
      load_gyro = 1;
      
      @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h80678092000F; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 65323;   // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 63444;
      tb_roll_data = 55;
      load_gyro = 1;
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
            @(negedge tb_clk);
      @(posedge tb_clk);
           @(negedge tb_clk);
      @(posedge tb_clk);
      tb_n_rst = 1;
      tb_gyro_data = 48'h80678092000F; 
      tb_dt_in = 8'h28; // assume dt is 2^-6 * 1 0.015625
      tb_pitch_data = 30000;   // 24.75 degree  accelerometer pitch data
      tb_yaw_data = 25000;
      tb_roll_data = 500;
      load_gyro = 1;
           @(negedge tb_clk);
      @(posedge tb_clk);

   end
 endmodule
