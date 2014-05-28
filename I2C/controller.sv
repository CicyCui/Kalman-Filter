// $Id: $
// File name:   controller.sv
// Created:     3/7/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: controller.
module controller
(
  input wire clk,
  input wire n_rst,
  input wire stop_found,
  input wire start_found,
  input wire byte_received,
  input wire ack_prep,
  input wire check_ack,
  input wire ack_done,
  input wire rw_mode,
  input wire address_match,
  input wire sda_in,
  output reg rx_enable,
  output reg shift_strobe,
  output reg load_address
);

typedef enum bit [3:0] { IDLE, LISTEN, ADDRCHK , ADDRCHKDONE, ADDRACK, ACKDONE, READ, READDONE, ACKPREP, READACKCHK, READWAITDONE, SHIFTING} stateType;


stateType state;
stateType next_state;


reg newsda;

//sync
always_ff @ (posedge clk, negedge n_rst)
begin
  if (n_rst == 1'b0)
    begin
      newsda <= 1'b1;
    end
  else
    begin
      newsda <= sda_in;
    end  
end

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
            next_state = LISTEN;
          end
      end
    LISTEN:
      begin
        next_state = LISTEN;
        if (byte_received == 1'b1)
          begin
            next_state = ADDRCHK;
          end
      end
    ADDRCHK:
      begin
        next_state = ADDRCHK;
        if (ack_prep == 1'b1)
          begin
            next_state = ADDRCHKDONE;
          end
      end
    ADDRCHKDONE:
      begin
        if (address_match == 1'b0 || rw_mode == 1'b0)
          begin
            next_state = IDLE;
          end
        else
          begin
            next_state = ADDRACK;
          end
      end
    ADDRACK:
      begin
        next_state = ADDRACK;
        if (ack_done == 1'b1)
          begin
            next_state = ACKDONE;
          end
      end
    ACKDONE:
      begin
        next_state = READ;
      end
    READ:
      begin
        next_state = READ;
        if (byte_received == 1'b1)
          begin
            next_state = SHIFTING;
          end
      end
    READDONE:
      begin
        next_state = READDONE;
        if (ack_prep == 1'b1)
          begin
            next_state = ACKPREP;
          end
      end
    ACKPREP:
      begin
        next_state = ACKPREP;
        if (check_ack == 1'b1)
          begin
            next_state = READACKCHK;
          end
      end
    READACKCHK:
      begin
        if (newsda == 1'b1)
          begin
            next_state = IDLE;
          end
        else
          begin
            next_state = READWAITDONE;
          end
      end
    READWAITDONE:
      begin
        next_state = READWAITDONE;
        if (ack_done == 1'b1)
          begin
            next_state = READ;
          end
      end
    SHIFTING:
      begin
        next_state = READDONE;
      end
  endcase
end

//output logic
always_comb
begin
  rx_enable = 1'b0;
  shift_strobe = 1'b0;
  load_address = 1'b1;
  
  case(state)
    IDLE:
      begin
        rx_enable = 1'b0;
        shift_strobe = 1'b0;
        load_address = 1'b0;
      end
    LISTEN:
      begin
        rx_enable = 1'b1;
        shift_strobe = 1'b0;
        load_address = 1'b0;
      end
    ADDRCHK:
      begin
        rx_enable = 1'b0;
        shift_strobe = 1'b0;
        load_address = 1'b0;
      end
    ADDRCHKDONE:
      begin
        rx_enable = 1'b0;
        shift_strobe = 1'b0;
        load_address = 1'b0;
      end
    ADDRACK:
      begin
        rx_enable = 1'b0;
        shift_strobe = 1'b0;
        load_address = 1'b0;
      end
    ACKDONE:
      begin
        rx_enable = 1'b0;
        shift_strobe = 1'b0;
        load_address = 1'b1;
      end
    READ:
      begin
        rx_enable = 1'b1;
        shift_strobe = 1'b0;
        load_address = 1'b0;
      end
    READDONE:
      begin
        rx_enable = 1'b0;
        shift_strobe = 1'b0;
        load_address = 1'b0;
      end
    ACKPREP:
      begin
        rx_enable = 1'b0;
        shift_strobe = 1'b0;
        load_address = 1'b0;
      end
    READACKCHK:
      begin
        rx_enable = 1'b0;
        shift_strobe = 1'b0;
        load_address = 1'b0;
      end
    READWAITDONE:
      begin
        rx_enable = 1'b0;
        shift_strobe = 1'b0;
        load_address = 1'b0;
      end
    SHIFTING:
      begin
        rx_enable = 1'b0;
        shift_strobe = 1'b1;
        load_address = 1'b0;
      end
  endcase
end

endmodule