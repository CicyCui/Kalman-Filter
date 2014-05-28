// $Id: $
// File name:   flex_counter.sv
// Created:     2/6/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Flexible Counter 
module flex_counter
  #(
    parameter NUM_CNT_BITS = 4
  )
  (
    input wire clk,n_rst,clear,
    input wire count_enable,
    input wire [NUM_CNT_BITS - 1:0] rollover_val,
    output wire rollover_flag
  );
  
  reg [NUM_CNT_BITS-1:0] curr_state;
  reg [NUM_CNT_BITS-1:0] next_state;
  reg flg,flg_n;
  
  assign rollover_flag = flg;
  
  
  always_ff @ (posedge clk, negedge n_rst) begin
    if( n_rst == 0 ) begin
      curr_state <= 0;
      flg <= 0;
    end else begin
      curr_state <= next_state;
      flg <= flg_n;
    end
  end
  
  always_comb
  begin
    next_state = 0;
    flg_n = 0;   
    if ( clear == 1 ) begin 
      next_state = 0;
    end else 
    if ( (count_enable == 1) && (curr_state >= rollover_val )) begin
      next_state = 1;
    end else if (count_enable == 1) begin
      next_state = curr_state + 1;
    end else begin
      next_state = curr_state; 
    end   
 
    if ( clear == 1 ) begin 
      flg_n = 0;
    end else
    if (count_enable && ((curr_state == rollover_val - 1) || (rollover_val == 1))) 
      flg_n = 1;
    else if (count_enable) 
      flg_n = 0;
    else 
      flg_n = flg;
                  
  end
  

      
  
endmodule
