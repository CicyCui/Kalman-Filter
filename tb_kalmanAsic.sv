// $Id: $
// File name:   tb_kalmanAsic.sv
// Created:     4/27/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: this is the final kalman filter test bench
`timescale 10ns/1ns

module tb_kalmanAsic();
  




  localparam SCL_PERIOD = 300;
  localparam CLK_PERIOD = 10;
    
  reg clk,n_rst;
  reg scl_clk;
  reg tb_scl_in;
  reg tb_sda_in;
  
  
  //input file
 	parameter		INPUT_FILENAME		= "./docs/indata";
	parameter		RESULT_FILENAME		= "./docs/outdata";
	parameter		TEST_FILENAME		= "./docs/testdata";
	integer in_file;							// Input file handle
	integer res_file;							// Result file handle
	integer test_file;
  
  
  wire [20:0] device_addr;
  assign device_addr = {7'b1111000, 7'b1111001, 7'b1111010};
  wire [23:0] addr_byte;
  assign addr_byte = {7'b1111000, 1'b1, 7'b1111001, 1'b1, 7'b1111010, 1'b1};

  
  reg [47:0] tb_acc_data;
  reg [47:0] tb_gyro_data;
  reg [47:0] tb_mag_data;
  
  
  
  //////////MCU test variables
  reg [7:0] MOSI_data;//data from microcontroller
  int ct; // counter
  reg data_ready;
  reg [47:0] SPI_output; 
  reg MOSI_in;
  reg SS_in;
  reg sclk_in;
  reg MISO_out;
  
  
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
  
  
  integer testcase;
  integer i,j, k;
  
  reg [15:0] roll, pitch, yaw;
  
  kalmanAsic DUT(
  .clk(clk),
  .n_rst(n_rst),
  .scl(tb_scl_in),
  .sda_in(tb_sda_in),
  .MOSI_in(MOSI_in),//master out slave in data
  .sclk_in(sclk_in),//SPI master clk
  .SS_in(SS_in),//SPI slave select 
  .MISO_out(miso), //master in slave out data
  .data_ready_out(data_ready) //NEW ADDED
  ,.roll(roll),
  .pitch(pitch),
  .yaw(yaw)
  );
  
  
  initial
  begin
    #5;
    //power on
    testcase = 1;
    //reseting
    n_rst = 1'b0;
    tb_scl_in = 1'b0;
    tb_sda_in = 1'b0;
    MOSI_in = 1'b0;
    sclk_in = 1'b0;
    SS_in = 1'b1;
    @(posedge clk);
    @(posedge clk);
    $info("Testing Reset");
    
    //no longer need reset
    n_rst = 1'b1;
   
    ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////
    //MCU configuration 
    //(master use sclk to clock in the data on mosi)
    //configuration must be done in the following steps:
    //1.master pull MOSI high to signal configuration start
    //2.send 1-byte accelerometer address via mosi
    //3.send 1-byte gyroscope address via mosi
    //4.send 1-byte magnetic compass address via mosi
    //5.send 1-byte declination via mosi
    //6.send 1-byte time interval via mosi
    //**once configured, MCU will not listen to master for 
    //**configuration without reset
    //////////MCU test variables
    //reg MOSI_data[7:0];//data from microcontroller
    //int ct; // counter
    ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////
    @(posedge clk);
    MOSI_in = 1'b1;
    @(posedge clk);
    @(posedge clk);
    MOSI_in = 1'b0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    
    //set acc
    MOSI_data = {1'b0,device_addr[20:14]};
    @(posedge clk);
    for( ct=0;ct<8;ct++) //clock data into MCU
    begin
    MOSI_in = MOSI_data[7];
    MOSI_data = {MOSI_data[6:0],1'b0};
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk_in = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk_in = 1'b0;
    end
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    //set gyro
    MOSI_data = {1'b0,device_addr[13:7]};
    @(posedge clk);
    for( ct=0;ct<8;ct++) //clock data into MCU
    begin
    MOSI_in = MOSI_data[7];
    MOSI_data = {MOSI_data[6:0],1'b0};
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk_in = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk_in = 1'b0;
    end
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    //set mag
    MOSI_data = {1'b0,device_addr[6:0]};
    @(posedge clk);
    for( ct=0;ct<8;ct++) //clock data into MCU
    begin
    MOSI_in = MOSI_data[7];
    MOSI_data = {MOSI_data[6:0],1'b0};
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk_in = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk_in = 1'b0;
    end
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    //set dec
    MOSI_data = 8'b00000101;
    @(posedge clk);
    for( ct=0;ct<8;ct++) //clock data into MCU
    begin
    MOSI_in = MOSI_data[7];
    MOSI_data = {MOSI_data[6:0],1'b0};
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk_in = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk_in = 1'b0;
    end
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    //set dt
    MOSI_data = 8'b00000100;
    @(posedge clk);
    for( ct=0;ct<8;ct++) //clock data into MCU
    begin
    MOSI_in = MOSI_data[7];
    MOSI_data = {MOSI_data[6:0],1'b0};
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk_in = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    sclk_in = 1'b0;
    end
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    //END of configuration
    
    @(posedge clk);
    //initialize the input file
    in_file = $fopen(INPUT_FILENAME, "r");
    res_file = $fopen(RESULT_FILENAME, "w");
    test_file = $fopen(TEST_FILENAME, "w");
    
    //while loop for shifting in each data and each operation would be in there
    while (!$feof(in_file)) begin
      //read data
      $fscanf(in_file, "%d %d %d %d %d %d %d %d %d \n", 
      tb_acc_data[15:0], tb_acc_data[31:16], tb_acc_data[47:32],
      tb_gyro_data[15:0], tb_gyro_data[31:16], tb_gyro_data[47:32],
      tb_mag_data[15:0], tb_mag_data[31:16], tb_mag_data[47:32]);
      
      $info("DATA LOADED \n %d %d %d %d %d %d %d %d %d \n", 
      tb_acc_data[15:0], tb_acc_data[31:16], tb_acc_data[47:32],
      tb_gyro_data[15:0], tb_gyro_data[31:16], tb_gyro_data[47:32],
      tb_mag_data[15:0], tb_mag_data[31:16], tb_mag_data[47:32]);
      
      ///////////////////////////////
      //transmitting acc data
      ///////////////////////////////
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
    
    $info("ACC TRANSMITTED");
    
    ///////////////////////////////
    //transmitting gyro data
    ///////////////////////////////
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
    
    $info("GYRO TRANSMITTED");
    
    ///////////////////////////////
    //transmitting mag data
    ///////////////////////////////
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
    
    $info("MAG TRANSMITTED");
    
    ////////////////////////
    //checking output
    //MCU output 
    //Once data_ready is set, the output data is ready to be read
    //It is assumed that the data will be read in the order of: roll,pitch,yaw
    //the output will be stored in test bench variable SPI_output 
    ////////////////////////
    //read roll
    while(data_ready == 1'b0) @(posedge clk);;
    $fwrite(test_file,"%d ",roll);
      for( ct=0;ct<16;ct++) 
      begin
       @(posedge clk);
       @(posedge clk);
       @(posedge clk);
       sclk_in = 1'b1;
       @(posedge clk);
       @(posedge clk);
       @(posedge clk);
       @(posedge clk);
       @(posedge clk);
       sclk_in = 1'b0;
       @(posedge clk);
       @(posedge clk);
       SPI_output = {SPI_output[47:0],miso};
      end  
    
    //read pitch
    while (data_ready == 1'b0)@(posedge clk);
    $fwrite(test_file,"%d ",pitch);
      for( ct=0;ct<16;ct++) 
      begin
       @(posedge clk);
       @(posedge clk);
       @(posedge clk);
       sclk_in = 1'b1;
       @(posedge clk);
       @(posedge clk);
       @(posedge clk);
       @(posedge clk);
       @(posedge clk);
       sclk_in = 1'b0;
       @(posedge clk);
       @(posedge clk);
       SPI_output = {SPI_output[47:0],miso};
      end  
 
    //read yaw
    while(data_ready == 1'b0) @(posedge clk);;
    $fwrite(test_file,"%d\n",yaw);
      for( ct=0;ct<16;ct++) 
      begin
       @(posedge clk);
       @(posedge clk);
       @(posedge clk);
       sclk_in = 1'b1;
       @(posedge clk);
       @(posedge clk);
       @(posedge clk);
       @(posedge clk);
       @(posedge clk);
       sclk_in = 1'b0;
       @(posedge clk);
       @(posedge clk);
       SPI_output = {SPI_output[47:0],miso};
      end  
 
    //output example
    $fwrite(res_file,"%d %d %d\n",SPI_output[47:32],SPI_output[31:16],SPI_output[15:0]);
    $info("OUTPUTED VALUE");
    
    end //main while loop
    $fclose(in_file);
    $fclose(res_file);
    $fclose(test_file);
  end

endmodule