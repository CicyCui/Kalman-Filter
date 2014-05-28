// $Id: $
// File name:   scl_edge.sv
// Created:     3/8/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Edge detector
module sclk_edge(
  input wire clk,
  input wire n_rst,
  input wire sclk,
  output wire rising_edge_found,
  output wire falling_edge_found
  );
   
  reg q_1,q_2,q_3; //q_2 is current scl, q_3 is previous scl
  
  assign rising_edge_found = n_rst ? ((q_3 == 0) && (q_2 == 1) ? 1:0):0;
  assign falling_edge_found = n_rst ? ((q_3 == 1) && (q_2 == 0) ? 1:0):0;
  
  always_ff @ ( posedge clk, negedge n_rst) //flip-flops to synchronize the input
  begin
    if( n_rst == 0) begin
      q_1 <= 1'b1;
      q_2 <= 1'b1;
      q_3 <= 1'b1;
    end else begin
      q_1 <= sclk;
      q_2 <= q_1;
      q_3 <= q_2;
    end 
  end
  
  
  
endmodule