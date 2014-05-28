// $Id: $
// File name:   tb_i2c_slave.sv
// Created:     3/16/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: test bench for i2c slave
`timescale 1ns/1ps

module tb_i2c_slave ();
  
  localparam SCL_PERIOD = 300;
  localparam CLK_PERIOD = 10;
    
  reg clk,n_rst;
  reg scl_clk;
  reg tb_scl_in;
  reg tb_sda_in;
  
  wire [20:0] device_addr;
  assign device_addr = {7'b1111000, 7'b1111001, 7'b1111010};
  wire [23:0] addr_byte;
  assign addr_byte = {7'b1111000, 1'b1, 7'b1111001, 1'b1, 7'b1111010, 1'b1};
  
  reg tb_acc_read, tb_gyro_read, tb_mag_read;
  
  reg acc_ready, gyro_ready, mag_ready;
  reg tb_acc_ready, tb_gyro_ready, tb_mag_ready;
  
  reg [47:0] acc_data;
  reg [47:0] gyro_data;
  reg [47:0] mag_data;
  
  reg [47:0] tb_acc_data;
  reg [47:0] tb_gyro_data;
  reg [47:0] tb_mag_data;
  
  
  
  //sys clock
  always
  begin
    clk = 1'b0;
    #(CLK_PERIOD/2);
    clk = 1'b1;
    #(CLK_PERIOD/2);
  end
  
  //clk for scl
  always
  begin
    scl_clk = 1'b0;
    #(SCL_PERIOD/2);
    scl_clk = 1'b1;
    #(SCL_PERIOD/2);
  end
  
  
  i2c_slave DUT (
  .clk(clk),
  .n_rst(n_rst),
  .scl(tb_scl_in),
  .sda_in(tb_sda_in),
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
  
  wire [2:0] tb_flags;
  wire [2:0] flags;
  
  wire [143:0] tb_datas;
  wire [143:0] datas;
  
  assign tb_flags = {tb_mag_ready, tb_gyro_ready, tb_acc_ready};
  assign flags = {mag_ready, gyro_ready, acc_ready};
  
  assign tb_datas = {tb_mag_data, tb_gyro_data, tb_acc_data};
  assign datas = {mag_data, gyro_data, acc_data};
  
  integer testcase;
  integer i,j, k;
  integer correct;
  
  initial
  begin
    #5;
    n_rst = 1'b0;
    //initialize the input data
    tb_acc_data = 48'h0123456789AB;
    tb_gyro_data = 48'h23456789ABCD;
    tb_mag_data = 48'h456789ABCDEF;
    
    tb_acc_read = 1'b0;
    tb_gyro_read = 1'b0;
    tb_mag_read = 1'b0;
    
    tb_acc_ready = 1'b0;
    tb_gyro_ready = 1'b0;
    tb_mag_ready = 1'b0;
    
    tb_scl_in = 1'b0;
    tb_sda_in = 1'b0;
    
    //power on
    testcase = 1;
    
    @(posedge clk);
    @(posedge clk);
    $info("Testing Reset");
    if (flags == tb_flags) $info(" flag PASSED!");
    if (datas == 0) $info(" data PASSED!");
    
    //no longer need reset
    n_rst = 1'b1;
    //shift in first set of data
    testcase = 2;
    //constructing start bit
    tb_scl_in = 1'b1;
    tb_sda_in = 1'b1;
    @(posedge scl_clk);
    tb_sda_in = 1'b0;
    #160;
    tb_scl_in = 1'b0;
    
    //start tansmitting the acc address
    for (i = 7; i >=0 ; i--)
    begin
      //next positive edge of scl clk
      @(posedge scl_clk);
      tb_scl_in = 1'b1; //pull the actual clock signal high
      
      tb_sda_in = addr_byte[i];
      
      @(negedge scl_clk);
      tb_scl_in = 1'b0; //pull the actual clock signal low
    end
    
    //ack bit
    @(posedge scl_clk);
    tb_scl_in = 1'b1; //pull the actual clock signal high
    tb_sda_in = 1'b0;
    @(negedge scl_clk);
    tb_scl_in = 1'b0; //pull the actual clock signal low
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    
    //transmitting the 6 byte value
    for (j = 5; j >= 0; j--)
    begin
      //for each byte
      //start tansmitting the byte
      for (i = 7; i >=0 ; i--)
      begin
        //next positive edge of scl clk
        @(posedge scl_clk);
        tb_scl_in = 1'b1; //pull the actual clock signal high
      
        tb_sda_in = tb_acc_data[j * 8 + i];
      
        @(negedge scl_clk);
        tb_scl_in = 1'b0; //pull the actual clock signal low
      end
    
      //ack bit
      if (j > 0)
        begin
          @(posedge scl_clk);
          tb_scl_in = 1'b1; //pull the actual clock signal high
          tb_sda_in = 1'b0;
          @(negedge scl_clk);
          tb_scl_in = 1'b0; //pull the actual clock signal low
          tb_sda_in = 1'b1;
          @(negedge scl_clk);
        end
    end //end for
    
    //nack final bit
    @(posedge scl_clk);
    tb_scl_in = 1'b1; //pull the actual clock signal high
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    tb_scl_in = 1'b0; //pull the actual clock signal low
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    
    $info("Case %d: shift in first set of data", testcase);
    //check data and flag
    if (acc_data == tb_acc_data) $info(" data correct!");
    if (acc_ready == 1'b1) $info(" flag correct!");
    
    //raise read flag and turn to turn off the ready flag
    @(negedge clk);
    tb_acc_read = 1'b1;
    @(posedge clk);
    @(negedge clk);
    if (acc_ready == 1'b0) $info(" flag correct after read signal!");
    tb_acc_read = 1'b0;
    @(posedge clk);
    
    //gyro
    testcase = 3;
    //constructing start bit
    tb_scl_in = 1'b1;
    tb_sda_in = 1'b1;
    @(posedge scl_clk);
    tb_sda_in = 1'b0;
    #160;
    tb_scl_in = 1'b0;
    
    //start tansmitting the acc address
    for (i = 15; i >=8 ; i--)
    begin
      //next positive edge of scl clk
      @(posedge scl_clk);
      tb_scl_in = 1'b1; //pull the actual clock signal high
      
      tb_sda_in = addr_byte[i];
      
      @(negedge scl_clk);
      tb_scl_in = 1'b0; //pull the actual clock signal low
    end
    
    //ack bit
    @(posedge scl_clk);
    tb_scl_in = 1'b1; //pull the actual clock signal high
    tb_sda_in = 1'b0;
    @(negedge scl_clk);
    tb_scl_in = 1'b0; //pull the actual clock signal low
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    
    //transmitting the 6 byte value
    for (j = 5; j >= 0; j--)
    begin
      //for each byte
      //start tansmitting the byte
      for (i = 7; i >=0 ; i--)
      begin
        //next positive edge of scl clk
        @(posedge scl_clk);
        tb_scl_in = 1'b1; //pull the actual clock signal high
      
        tb_sda_in = tb_gyro_data[j * 8 + i];
      
        @(negedge scl_clk);
        tb_scl_in = 1'b0; //pull the actual clock signal low
      end
    
      //ack bit
      if (j > 0)
        begin
          @(posedge scl_clk);
          tb_scl_in = 1'b1; //pull the actual clock signal high
          tb_sda_in = 1'b0;
          @(negedge scl_clk);
          tb_scl_in = 1'b0; //pull the actual clock signal low
          tb_sda_in = 1'b1;
          @(negedge scl_clk);
        end
    end //end for
    
    //nack final bit
    @(posedge scl_clk);
    tb_scl_in = 1'b1; //pull the actual clock signal high
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    tb_scl_in = 1'b0; //pull the actual clock signal low
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    
    $info("Case %d: shift in first set of data", testcase);
    //check data and flag
    if (gyro_data == tb_gyro_data) $info(" data correct!");
    if (gyro_ready == 1'b1) $info(" flag correct!");
    
    //raise read flag and turn to turn off the ready flag
    @(negedge clk);
    tb_gyro_read = 1'b1;
    @(posedge clk);
    @(negedge clk);
    if (gyro_ready == 1'b0) $info(" flag correct after read signal!");
    tb_gyro_read = 1'b0;
    @(posedge clk);
    
    //mag
    testcase = 4;
    //constructing start bit
    tb_scl_in = 1'b1;
    tb_sda_in = 1'b1;
    @(posedge scl_clk);
    tb_sda_in = 1'b0;
    #160;
    tb_scl_in = 1'b0;
    
    //start tansmitting the acc address
    for (i = 23; i >=16 ; i--)
    begin
      //next positive edge of scl clk
      @(posedge scl_clk);
      tb_scl_in = 1'b1; //pull the actual clock signal high
      
      tb_sda_in = addr_byte[i];
      
      @(negedge scl_clk);
      tb_scl_in = 1'b0; //pull the actual clock signal low
    end
    
    //ack bit
    @(posedge scl_clk);
    tb_scl_in = 1'b1; //pull the actual clock signal high
    tb_sda_in = 1'b0;
    @(negedge scl_clk);
    tb_scl_in = 1'b0; //pull the actual clock signal low
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    
    //transmitting the 6 byte value
    for (j = 5; j >= 0; j--)
    begin
      //for each byte
      //start tansmitting the byte
      for (i = 7; i >=0 ; i--)
      begin
        //next positive edge of scl clk
        @(posedge scl_clk);
        tb_scl_in = 1'b1; //pull the actual clock signal high
      
        tb_sda_in = tb_mag_data[j * 8 + i];
      
        @(negedge scl_clk);
        tb_scl_in = 1'b0; //pull the actual clock signal low
      end
    
      //ack bit
      if (j > 0)
        begin
          @(posedge scl_clk);
          tb_scl_in = 1'b1; //pull the actual clock signal high
          tb_sda_in = 1'b0;
          @(negedge scl_clk);
          tb_scl_in = 1'b0; //pull the actual clock signal low
          tb_sda_in = 1'b1;
          @(negedge scl_clk);
        end
    end //end for
    
    //nack final bit
    @(posedge scl_clk);
    tb_scl_in = 1'b1; //pull the actual clock signal high
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    tb_scl_in = 1'b0; //pull the actual clock signal low
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    
    $info("Case %d: shift in first set of data", testcase);
    //check data and flag
    if (mag_data == tb_mag_data) $info(" data correct!");
    if (mag_ready == 1'b1) $info(" flag correct!");
    
    //raise read flag and turn to turn off the ready flag
    @(negedge clk);
    tb_mag_read = 1'b1;
    @(posedge clk);
    @(negedge clk);
    if (mag_ready == 1'b0) $info(" flag correct after read signal!");
    tb_mag_read = 1'b0;
    @(posedge clk);
    
    ///////////////////////////////////////
    //multiple transmission
    correct = 0;
    for (k = 0; k < 100; k++)
    begin
      
      tb_acc_data = tb_acc_data + 1;
      tb_gyro_data = tb_gyro_data + 1;
      tb_mag_data = tb_mag_data + 1;
      
      //shift in first set of data
    testcase = 1;
    //constructing start bit
    tb_scl_in = 1'b1;
    tb_sda_in = 1'b1;
    @(posedge scl_clk);
    tb_sda_in = 1'b0;
    #160;
    tb_scl_in = 1'b0;
    
    //start tansmitting the acc address
    for (i = 7; i >=0 ; i--)
    begin
      //next positive edge of scl clk
      @(posedge scl_clk);
      tb_scl_in = 1'b1; //pull the actual clock signal high
      
      tb_sda_in = addr_byte[i];
      
      @(negedge scl_clk);
      tb_scl_in = 1'b0; //pull the actual clock signal low
    end
    
    //ack bit
    @(posedge scl_clk);
    tb_scl_in = 1'b1; //pull the actual clock signal high
    tb_sda_in = 1'b0;
    @(negedge scl_clk);
    tb_scl_in = 1'b0; //pull the actual clock signal low
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    
    //transmitting the 6 byte value
    for (j = 5; j >= 0; j--)
    begin
      //for each byte
      //start tansmitting the byte
      for (i = 7; i >=0 ; i--)
      begin
        //next positive edge of scl clk
        @(posedge scl_clk);
        tb_scl_in = 1'b1; //pull the actual clock signal high
      
        tb_sda_in = tb_acc_data[j * 8 + i];
      
        @(negedge scl_clk);
        tb_scl_in = 1'b0; //pull the actual clock signal low
      end
    
      //ack bit
      if (j > 0)
        begin
          @(posedge scl_clk);
          tb_scl_in = 1'b1; //pull the actual clock signal high
          tb_sda_in = 1'b0;
          @(negedge scl_clk);
          tb_scl_in = 1'b0; //pull the actual clock signal low
          tb_sda_in = 1'b1;
          @(negedge scl_clk);
        end
    end //end for
    
    //nack final bit
    @(posedge scl_clk);
    tb_scl_in = 1'b1; //pull the actual clock signal high
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    tb_scl_in = 1'b0; //pull the actual clock signal low
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    
    $info("Case %d.%d: shift in first set of data", k,testcase);
    //check data and flag
    if (acc_data == tb_acc_data) 
    begin
      $info(" data correct!");
      correct = correct + 1;
    end
    if (acc_ready == 1'b1) $info(" flag correct!");
    
    //raise read flag and turn to turn off the ready flag
    @(negedge clk);
    tb_acc_read = 1'b1;
    @(posedge clk);
    @(negedge clk);
    if (acc_ready == 1'b0) $info(" flag correct after read signal!");
    tb_acc_read = 1'b0;
    @(posedge clk);
    
    //gyro
    testcase = 2;
    //constructing start bit
    tb_scl_in = 1'b1;
    tb_sda_in = 1'b1;
    @(posedge scl_clk);
    tb_sda_in = 1'b0;
    #160;
    tb_scl_in = 1'b0;
    
    //start tansmitting the acc address
    for (i = 15; i >=8 ; i--)
    begin
      //next positive edge of scl clk
      @(posedge scl_clk);
      tb_scl_in = 1'b1; //pull the actual clock signal high
      
      tb_sda_in = addr_byte[i];
      
      @(negedge scl_clk);
      tb_scl_in = 1'b0; //pull the actual clock signal low
    end
    
    //ack bit
    @(posedge scl_clk);
    tb_scl_in = 1'b1; //pull the actual clock signal high
    tb_sda_in = 1'b0;
    @(negedge scl_clk);
    tb_scl_in = 1'b0; //pull the actual clock signal low
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    
    //transmitting the 6 byte value
    for (j = 5; j >= 0; j--)
    begin
      //for each byte
      //start tansmitting the byte
      for (i = 7; i >=0 ; i--)
      begin
        //next positive edge of scl clk
        @(posedge scl_clk);
        tb_scl_in = 1'b1; //pull the actual clock signal high
      
        tb_sda_in = tb_gyro_data[j * 8 + i];
      
        @(negedge scl_clk);
        tb_scl_in = 1'b0; //pull the actual clock signal low
      end
    
      //ack bit
      if (j > 0)
        begin
          @(posedge scl_clk);
          tb_scl_in = 1'b1; //pull the actual clock signal high
          tb_sda_in = 1'b0;
          @(negedge scl_clk);
          tb_scl_in = 1'b0; //pull the actual clock signal low
          tb_sda_in = 1'b1;
          @(negedge scl_clk);
        end
    end //end for
    
    //nack final bit
    @(posedge scl_clk);
    tb_scl_in = 1'b1; //pull the actual clock signal high
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    tb_scl_in = 1'b0; //pull the actual clock signal low
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    
    $info("Case %d.%d: shift in gyro set of data", k,testcase);
    //check data and flag
    if (gyro_data == tb_gyro_data) 
    begin
      $info(" data correct!");
      correct = correct + 1;
    end
    if (gyro_ready == 1'b1) $info(" flag correct!");
    
    //raise read flag and turn to turn off the ready flag
    @(negedge clk);
    tb_gyro_read = 1'b1;
    @(posedge clk);
    @(negedge clk);
    if (gyro_ready == 1'b0) $info(" flag correct after read signal!");
    tb_gyro_read = 1'b0;
    @(posedge clk);
    
    //mag
    testcase = 3;
    //constructing start bit
    tb_scl_in = 1'b1;
    tb_sda_in = 1'b1;
    @(posedge scl_clk);
    tb_sda_in = 1'b0;
    #160;
    tb_scl_in = 1'b0;
    
    //start tansmitting the acc address
    for (i = 23; i >=16 ; i--)
    begin
      //next positive edge of scl clk
      @(posedge scl_clk);
      tb_scl_in = 1'b1; //pull the actual clock signal high
      
      tb_sda_in = addr_byte[i];
      
      @(negedge scl_clk);
      tb_scl_in = 1'b0; //pull the actual clock signal low
    end
    
    //ack bit
    @(posedge scl_clk);
    tb_scl_in = 1'b1; //pull the actual clock signal high
    tb_sda_in = 1'b0;
    @(negedge scl_clk);
    tb_scl_in = 1'b0; //pull the actual clock signal low
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    
    //transmitting the 6 byte value
    for (j = 5; j >= 0; j--)
    begin
      //for each byte
      //start tansmitting the byte
      for (i = 7; i >=0 ; i--)
      begin
        //next positive edge of scl clk
        @(posedge scl_clk);
        tb_scl_in = 1'b1; //pull the actual clock signal high
      
        tb_sda_in = tb_mag_data[j * 8 + i];
      
        @(negedge scl_clk);
        tb_scl_in = 1'b0; //pull the actual clock signal low
      end
    
      //ack bit
      if (j > 0)
        begin
          @(posedge scl_clk);
          tb_scl_in = 1'b1; //pull the actual clock signal high
          tb_sda_in = 1'b0;
          @(negedge scl_clk);
          tb_scl_in = 1'b0; //pull the actual clock signal low
          tb_sda_in = 1'b1;
          @(negedge scl_clk);
        end
    end //end for
    
    //nack final bit
    @(posedge scl_clk);
    tb_scl_in = 1'b1; //pull the actual clock signal high
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    tb_scl_in = 1'b0; //pull the actual clock signal low
    tb_sda_in = 1'b1;
    @(negedge scl_clk);
    
    $info("Case %d.%d: shift in mag set of data", k,testcase);
    //check data and flag
    if (mag_data == tb_mag_data) 
    begin
      $info(" data correct!");
      correct = correct + 1;
    end
    if (mag_ready == 1'b1) $info(" flag correct!");
    
    //raise read flag and turn to turn off the ready flag
    @(negedge clk);
    tb_mag_read = 1'b1;
    @(posedge clk);
    @(negedge clk);
    if (mag_ready == 1'b0) $info(" flag correct after read signal!");
    tb_mag_read = 1'b0;
    @(posedge clk);
    
      end /////////////////////////////////////////////
    if (correct == 300) 
    begin
      $info("PASSED 100 CASE!");
    end
    else 
    begin
      $error("failed 100 CASE!");
    end
  end// initial
endmodule