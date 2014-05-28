// $Id: $
// File name:   timer.sv
// Created:     3/7/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: timer
module timer
(
input wire clk,
input wire n_rst,
input wire rising_edge_found,
input wire falling_edge_found,
input wire stop_found,
input wire start_found,
output wire byte_received,
output reg ack_prep,
output reg check_ack,
output reg ack_done
);

typedef enum bit [2:0] { IDLE, COUNTING, BYTERECEIVED , ACKPREP, CHECKACK, ACKDONE} stateType;


stateType state;
stateType next_state;
reg counter_clear;
wire clear;
wire [3:0] count_out;
wire [3:0] rollover_val;
wire rollover_flag;

assign rollover_val = 8;
assign byte_received = rollover_flag;
assign clear = (start_found == 1'b1)? 1'b1 : counter_clear;

defparam XI.NUM_CNT_BITS = 4;

flex_counter XI(.clk(clk), .n_rst(n_rst), .clear(clear), .count_enable(rising_edge_found), .rollover_val(rollover_val), .count_out(count_out), .rollover_flag(rollover_flag));

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
  next_state = IDLE;
  case(state)
    IDLE:
      begin
        next_state = IDLE;
        if (start_found == 1'b1)
          begin
            next_state = COUNTING;
          end
      end
    COUNTING:
      begin
        next_state = COUNTING;
        if (stop_found == 1'b1)
          begin
            next_state = IDLE;
          end
        else if (rollover_flag == 1'b1)
          begin
            next_state = BYTERECEIVED;
          end
      end
    BYTERECEIVED:
      begin
        next_state = BYTERECEIVED;
        if (falling_edge_found == 1'b1)
          begin
            next_state = ACKPREP;
          end
      end
    ACKPREP:
      begin
        next_state = ACKPREP;
        if (rising_edge_found == 1'b1)
          begin
            next_state = CHECKACK;
          end
      end
    CHECKACK:
      begin
        next_state = CHECKACK;
        if (falling_edge_found == 1'b1)
          begin
            next_state = ACKDONE;
          end
      end
    ACKDONE:
      begin
        next_state = COUNTING;
      end
  endcase
end

//output logic
always_comb
begin
  ack_prep = 1'b0;
  check_ack = 1'b0;
  ack_done = 1'b0;
  counter_clear = 1'b1;
  
  case(state)
    IDLE:
      begin
        ack_prep = 1'b0;
        check_ack = 1'b0;
        ack_done = 1'b0;
        counter_clear = 1'b1;
      end
    COUNTING:
      begin
        ack_prep = 1'b0;
        check_ack = 1'b0;
        ack_done = 1'b0;
        counter_clear = 1'b0;
      end
    BYTERECEIVED:
      begin
        ack_prep = 1'b0;
        check_ack = 1'b0;
        ack_done = 1'b0;
        counter_clear = 1'b1;
      end
    ACKPREP:
      begin
        ack_prep = 1'b1;
        check_ack = 1'b0;
        ack_done = 1'b0;
        counter_clear = 1'b1;
      end
    CHECKACK:
      begin
        ack_prep = 1'b0;
        check_ack = 1'b1;
        ack_done = 1'b0;
        counter_clear = 1'b1;
      end
    ACKDONE:
      begin
        ack_prep = 1'b0;
        check_ack = 1'b0;
        ack_done = 1'b1;
        counter_clear = 1'b1;
      end
  endcase
end

endmodule