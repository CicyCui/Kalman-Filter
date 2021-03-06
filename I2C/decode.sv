// $Id: $
// File name:   decode.sv
// Created:     3/7/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: decoder!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
module decode
(
input wire clk,
input wire n_rst,
input wire scl,
input wire sda_in,
input wire [7:0] starting_byte,
output wire rw_mode,
output reg address_match,
output reg stop_found,
output reg start_found,
input wire [20:0] device_addr,
output reg [1:0] devicematch
);

assign rw_mode = starting_byte[0];

always_comb
begin
  devicematch = 0;
  if (starting_byte[7:1] == device_addr[6:0])
    begin
      devicematch = 1;
    end
  if (starting_byte[7:1] == device_addr[13:7])
    begin
      devicematch = 2;
    end
  if (starting_byte[7:1] == device_addr[20:14])
    begin
      devicematch = 3;
    end
end

always_comb
begin
  address_match = 0;
  if (devicematch != 0)
    begin
      address_match = 1;
    end
end

reg newscl;
reg newsda;
reg currentscl;
reg currentsda;
reg lastscl;
reg lastsda;

//sync
always_ff @ (posedge clk, negedge n_rst)
begin
  if (n_rst == 1'b0)
    begin
      newscl <= 1'b1;
      newsda <= 1'b1;
    end
  else
    begin
      newscl <= scl;
      newsda <= sda_in;
    end  
end

//current
always_ff @ (posedge clk, negedge n_rst)
begin
  if (n_rst == 1'b0)
    begin
      currentscl <= 1'b1;
      currentsda <= 1'b1;
    end
  else
    begin
      currentscl <= newscl;
      currentsda <= newsda;
    end  
end

//last
always_ff @ (posedge clk, negedge n_rst)
begin
  if (n_rst == 1'b0)
    begin
      lastscl <= 1'b1;
      lastsda <= 1'b1;
    end
  else
    begin
      lastscl <= currentscl;
      lastsda <= currentsda;
    end  
end

//output logic
always_comb
begin
  stop_found = 1'b0;
  start_found = 1'b0;
  
  //clock is 1
  if (lastscl == 1'b1 && currentscl == 1'b1)
    begin
      if (lastsda == 1'b1 && currentsda == 1'b0)
        begin
          start_found = 1'b1;
        end
      if (lastsda == 1'b0 && currentsda == 1'b1)
        begin
          stop_found = 1'b1;
        end
    end
  
end

endmodule
