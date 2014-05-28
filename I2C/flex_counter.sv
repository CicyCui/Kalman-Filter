// $Id: $
// File name:   flex_counter.sv
// Created:     2/6/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: counter hahahhahahahhahahahhahahahhahahhahahahhahahahhahaha
module flex_counter
#(
  parameter NUM_CNT_BITS = 4
)
(
  input wire clk,
  input wire n_rst,
  input wire clear,
  input wire count_enable,
  input wire [NUM_CNT_BITS - 1:0] rollover_val,
  output wire [NUM_CNT_BITS - 1:0] count_out,
  output wire rollover_flag
);

reg [NUM_CNT_BITS - 1:0] val;
reg [NUM_CNT_BITS - 1:0] temp;
reg rollover_state;
reg nextrollover_state;

assign count_out = val;

assign rollover_flag = rollover_state;

always_comb
begin
  nextrollover_state = 0;
  if (clear == 1)
    begin
      temp = 0;
      nextrollover_state = 0;
    end
  else if (count_enable == 0)
    begin
      temp = val;
      nextrollover_state = rollover_state;
    end
  else
    begin 
      if ( rollover_state == 1 ) 
      begin
        temp = 1;
      end
      else
      begin
        temp = val + 1;
      end  
      
      if ((val == rollover_val - 1) || ( rollover_val == 1))
        begin
          nextrollover_state = 1;
        end
      else
        begin
          nextrollover_state = 0;
        end
    end
    
end

always_ff @ (posedge clk, negedge n_rst)
begin
  //reset
  // rollover_state = 0;
  if (n_rst == 1'b0)
  begin
    val <= 0;
    rollover_state <= 0;
  end
  //not reset
  else begin
        val <= temp;
        rollover_state <= nextrollover_state;
      
  end //end reset
end

endmodule