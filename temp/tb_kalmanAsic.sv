// $Id: $
// File name:   tb_kalmanAsic.sv
// Created:     4/27/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: this is the final kalman filter test bench
`timescale 10ns/1ns

module tb_kalmanAsic();
  

kalmanAsic DUT(
  .clk(clk),
  .n_rst(n_rst),
  .scl(scl),
  .sda_in(sda_in),
  .MOSI_in(MOSI_in),//master out slave in data
  .sclk_in(sclk_in),//SPI master clk
  .SS_in(SS_in),//SPI slave select 
  .MISO_out(miso), //master in slave out data
);


  localparam SCL_PERIOD = 300;
  localparam CLK_PERIOD = 10;
    
  reg clk,n_rst;
  reg scl_clk;
  reg tb_scl_in;
  reg tb_sda_in;
  
  
  //input file
 	parameter		INPUT_FILENAME		= "./docs/indata";
	parameter		RESULT_FILENAME		= "./docs/outdata";
	integer in_file;							// Input file handle
	integer res_file;							// Result file handle
  
  
  wire [20:0] device_addr;
  assign device_addr = {7'b1111000, 7'b1111001, 7'b1111010};
  wire [23:0] addr_byte;
  assign addr_byte = {7'b1111000, 1'b1, 7'b1111001, 1'b1, 7'b1111010, 1'b1};

  
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
  
  
  integer testcase;
  integer i,j, k;
  
  initial
  begin
    #5;
    //power on
    testcase = 1;
    //reseting
    n_rst = 1'b0;
    tb_scl_in = 1'b0;
    tb_sda_in = 1'b0;
    
    @(posedge clk);
    @(posedge clk);
    $info("Testing Reset");
    
    //no longer need reset
    n_rst = 1'b1;
    
    ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////
    //MUC configuration
    //
    ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////
    
    //initialize the input file
    in_file = $fopen(INPUT_FILENAME, "r");
    res_file = $fopen(RESULT_FILENAME, "w");
    
    //while loop for shifting in each data and each operation would be in there
    while (!$feof(in)) begin
      //read data
      $fscanf(in, "%h %h %h %h %h %h %h %h %h\n", 
      acc_data[15:0], acc_data[31:0], acc_data[47:32],
      gyro_data[15:0], gyro_data[31:0], gyro_data[47:32],
      mag_data[15:0], mag_data[31:0], mag_data[47:32]);
      
      
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
    
    ////////////////////////
    //checking output
    ////////////////////////
    
    
    //output example
    // $fwrite(res_file,"%h %h\n",dout[31:16],dout[15:0]);
    
    
    end //main while loop
    $fclose(in_file);
    $fclose(res_file);
  end

endmodule