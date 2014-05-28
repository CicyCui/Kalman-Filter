// $Id: $
// File name:   tb_scl_edge.sv
// Created:     3/7/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: edge

`timescale 1ns / 100ps

module tb_scl_edge();
  
  // Define clk parameter
	parameter CLK_PERIOD				= 10;
	parameter DATA_PERIOD = 300;
	
	//system clock
	reg tb_clk;
	
	always
	begin : CLK_GEN
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2);
		tb_clk = 1'b1;
		#(CLK_PERIOD / 2);
	end
	
	//scl clock
	reg tb_scl;

	
	//tb variables
	reg [3:0] tb_testcase;
	
	reg tb_n_rst;
	wire tb_rising_edge_found;
	wire tb_falling_edge_found;
		
	//function call
	scl_edge DUT(.clk(tb_clk), .n_rst(tb_n_rst), .scl(tb_scl), .rising_edge_found(tb_rising_edge_found), .falling_edge_found(tb_falling_edge_found));
		
	//test bench process
	initial
	begin
	  //case 1: falling found
	  tb_testcase = 1;
	  tb_n_rst = 1'b0;
	  tb_scl = 1'b1;
	  
	  //to the edge of the clock period
	  @(posedge tb_clk);
	  #(CLK_PERIOD);
	  tb_n_rst = 1'b1;
	  
	  #(CLK_PERIOD * 0.2); //hold time
	  tb_scl = 1'b0;
	  #(CLK_PERIOD * 2);
	  
	  if (tb_falling_edge_found == 1'b1 && tb_rising_edge_found == 1'b0)
	    begin
	      $info("test case %d pass!", tb_testcase);
	    end
	  else
	    begin
	      $error("test case %d fail! startfound", tb_testcase);
	    end
	    
	  #(CLK_PERIOD); //hold time
	  
	  
	  
	  //case 2: rising found
	  //start at pos edge of clk clock
	  tb_testcase = 2;
	  tb_scl = 1'b0;
	  @(posedge tb_clk);
	  #(CLK_PERIOD * 1.2);
	  
	  tb_scl = 1'b1;
	  #(CLK_PERIOD * 2); // done AFTER 2 clk period
	  	  
	  if (tb_falling_edge_found == 1'b0 && tb_rising_edge_found == 1'b1)
	    begin
	      $info("test case %d pass!", tb_testcase);
	    end
	  else
	    begin
	      $error("test case %d fail! stopfound", tb_testcase);
	    end
	  
	  //case 3: no edge
	  tb_testcase = 3;
	  #(CLK_PERIOD); // done AFTER 3 clk period
    if (tb_falling_edge_found == 1'b0 && tb_rising_edge_found == 1'b0)
	    begin
	      $info("test case %d pass!", tb_testcase);
	    end
	  else
	    begin
	      $error("test case %d fail! stopfound", tb_testcase);
	    end
	end
	
	
endmodule