// $Id: $
// File name:   sync.sv
// Created:     1/31/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Synchronizer Design
module sync (
  input wire clk,n_rst,async_in,
  output wire sync_out
  );
  reg Q;
  reg s_out;
  
  assign sync_out = s_out;
  
  always @ (posedge clk, negedge n_rst) begin
    if ( n_rst == 1'b0) begin 
      Q <= 1'b0;
      s_out <= 1'b0;
      end 
    else begin
      Q <= async_in;
      s_out <= Q;
      end
  end
endmodule