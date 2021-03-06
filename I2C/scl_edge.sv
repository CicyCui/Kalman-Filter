// $Id: $
// File name:   scl_edge.sv
// Created:     3/7/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: edge detector
module scl_edge
(
input wire clk,
input wire n_rst,
input wire scl,
output reg rising_edge_found,
output reg falling_edge_found
);

reg newscl;
reg currentscl;
reg lastscl;

//sync
always_ff @ (posedge clk, negedge n_rst)
begin
  if (n_rst == 1'b0)
    begin
      newscl <= 1'b1;
    end
  else
    begin
      newscl <= scl;
    end  
end

//current
always_ff @ (posedge clk, negedge n_rst)
begin
  if (n_rst == 1'b0)
    begin
      currentscl <= 1'b1;
    end
  else
    begin
      currentscl <= newscl;
    end  
end

//last
always_ff @ (posedge clk, negedge n_rst)
begin
  if (n_rst == 1'b0)
    begin
      lastscl <= 1'b1;
    end
  else
    begin
      lastscl <= currentscl;
    end  
end

//output logic
always_comb
begin
  rising_edge_found = 1'b0;
  falling_edge_found = 1'b0;
  
  if (lastscl == 1'b1 && currentscl == 1'b0)
    begin
      falling_edge_found = 1'b1;
    end
  if (lastscl == 1'b0 && currentscl == 1'b1)
    begin
      rising_edge_found = 1'b1;
    end  
end

endmodule