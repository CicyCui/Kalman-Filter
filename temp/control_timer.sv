// $Id: $
// File name:   control_timer.sv
// Created:     4/21/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: this is the timer for the controller.
module control_timer
(
  input wire clk,
  input wire n_rst,
  input wire clear,
  input wire roll_pitch_enable,
  input wire yaw_enable,
  output wire kalman_done
);


typedef enum bit [1:0] { IDLE, ROLL_PITCH, YAW} stateType;


stateType state;
stateType next_state;


reg count_enable;
wire clear;
wire [3:0] count_out;
wire [3:0] rollover_val;
wire rollover_flag;

assign rollover_val = 10; // 1000 ns 

defparam XI.NUM_CNT_BITS = 4;

flex_counter XI(.clk(clk), .n_rst(n_rst), .clear(clear), .count_enable(count_enable), .rollover_val(rollover_val), .count_out(count_out), .rollover_flag(rollover_flag));

assign kalman_done = rollover_flag;

//flip flop
always_ff @ (posedge clk, negedge n_rst)
begin
  if (n_rst == 1'b0)
    begin
      state <= IDLE;
    end
  else
    begin
      state <= next_state;
    end  
end

//next state logic
always_comb
begin
  next_state = state;
  case(state)
    IDLE:
      begin
        if (roll_pitch_enable == 1'b1)
          begin
            next_state = ROLL_PITCH;
          end
        else if (yaw_enable == 1'b1)
          begin
            next_state = YAW;
          end
      end
    ROLL_PITCH:
      begin
        if (rollover_flag == 1'b1)
          begin
            next_state = IDLE;
          end
      end
    YAW:
      begin
        if (rollover_flag == 1'b1)
          begin
            next_state = IDLE;
          end
      end
  endcase
end

//output logic
always_comb
begin
  rollover_val = 10;
  count_enable = 1'b0;
  case(state)
    IDLE:
      begin
        
      end
    ROLL_PITCH:
      begin
        count_enable = 1'b1;
        rollover_val = 10;
      end
    YAW:
      begin
        count_enable = 1'b1;
        rollover_val = 10;
      end
  endcase
end


endmodule