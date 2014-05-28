// $Id: $
// File name:   tb_i2c_slave2.sv
// Created:     3/23/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: testing it!!!
`timescale 1ns/1ps

module tb_i2c_slave ();
  
  // Define parameters
	parameter CLK_PERIOD				= 10;
	parameter BUS_PERIOD    = 300;
	
	