// $Id: $
// File name:   sda_sel.sv
// Created:     3/7/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: select
module sda_sel
(
  input wire tx_out,
  input wire [1:0] sda_mode,
  output reg sda_out
);

always_comb
begin
  sda_out = 0;
  case (sda_mode)
    2'b00:
      begin
        sda_out = 1'b1;
      end
    2'b01:
      begin
        sda_out = 1'b0;
      end
    2'b10:
      begin
        sda_out = 1'b1;
      end
    2'b11:
      begin
        sda_out = tx_out;
      end
  endcase
end

endmodule