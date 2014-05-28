// $Id: $
// File name:   Register_map.sv
// Created:     4/15/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: register map for storing sensor addresses and declination angle upon configuration
module Register_map(
  input wire n_rst,
  input wire clk,
  input wire [7:0] data_in,
  input wire [2:0] addr_in, // 000->acc_add  001->gyro_add  010->mag_add  011->declination degree  3'b100-> time interval 3'b111->do not load (MSB is module enable)
  output wire [7:0] gyro_add_out,
  output wire [7:0] acc_add_out,
  output wire [7:0] mag_add_out,
  output wire [7:0] declination_out,
  output wire [7:0] dt_out
  );
  
  reg [7:0] gyro_curr,acc_curr,mag_curr,dec_curr,dt_curr,gyro_next,acc_next,mag_next,dec_next,dt_next;
  
  assign gyro_add_out = gyro_curr;
  assign acc_add_out = acc_curr;
  assign mag_add_out = mag_curr;
  assign declination_out = dec_curr;
  assign dt_out = dt_curr;
  
  always_ff @ (posedge clk, negedge n_rst) begin
    if( n_rst == 1'b0) begin
      gyro_curr <= '0;
      acc_curr <= '0;
      mag_curr <= '0;
      dec_curr <= '0;
      dt_curr <= '0;
    end else begin
      gyro_curr <= gyro_next;
      acc_curr <= acc_next;
      mag_curr <= mag_next;
      dec_curr <= dec_next;
      dt_curr <= dt_next;
    end
  end
  
  
  always_comb begin
    gyro_next = gyro_curr;
    acc_next = acc_curr;
    mag_next = mag_curr;
    dec_next = dec_curr;
    dt_next = dt_curr;
    
    // 000->acc_add  001->gyro_add  010->mag_add  011->declination degree 100-> dt else->do not load

    if( addr_in == 3'b000) begin
      acc_next = data_in;
    end else if (addr_in == 3'b001) begin
      gyro_next = data_in;
    end else if (addr_in == 3'b010) begin
      mag_next = data_in;
    end else if (addr_in == 3'b011) begin
      dec_next = data_in;
    end else if (addr_in == 3'b100) begin
      dt_next = data_in;
    end 
    
  end
  
  
endmodule
  