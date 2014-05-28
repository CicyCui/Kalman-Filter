// $Id: $
// File name:   tb_sda_sel.sv
// Created:     3/7/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: select


`timescale 1ns / 100ps

module tb_sda_sel();
  

  reg [1:0] tb_sda_mode;
  reg tb_sda_out;
  reg tb_tx_out;
  wire [7:0] testdata;
  assign testdata = 8'b01010101;
  
  integer tb_testcase;
	
	sda_sel DUT(.tx_out(tb_tx_out), .sda_mode(tb_sda_mode), .sda_out(tb_sda_out));
	
	//test bench process
	initial
	begin
	  #10;
	  tb_testcase = 1;
	  tb_sda_mode = 0;
	  #1;
	  if (tb_sda_out == 1'b1)
	    begin
	      $info("test case %d pass!", tb_testcase);
	    end
	  else
	    begin
	      $error("test case %d fail! 1", tb_testcase);
	    end
	  #10;
	  tb_testcase = 2;
	  tb_sda_mode = 1;
	  #1;
	  if (tb_sda_out == 1'b0)
	    begin
	      $info("test case %d pass!", tb_testcase);
	    end
	  else
	    begin
	      $error("test case %d fail! 2", tb_testcase);
	    end
	  #10; 
	  tb_testcase = 3;
	  tb_sda_mode = 2;
	  #1;
	  if (tb_sda_out == 1'b1)
	    begin
	      $info("test case %d pass!", tb_testcase);
	    end
	  else
	    begin
	      $error("test case %d fail! 3", tb_testcase);
	    end
	  
	  #10; 
	  tb_sda_mode = 3;
	  for (tb_testcase = 4; tb_testcase - 4 < 8; tb_testcase = tb_testcase + 1)
	  begin
	    #5;
	    tb_tx_out = testdata[tb_testcase - 4];
	    #1;
	    if (tb_sda_out == testdata[tb_testcase - 4])
	       begin
	         $info("test case %d pass!", tb_testcase);
	       end
	    else
	       begin
	         $error("test case %d fail! tx_out", tb_testcase);
	       end
	       
	    #5;
	  end
	  
	  
	end
	
	
endmodule