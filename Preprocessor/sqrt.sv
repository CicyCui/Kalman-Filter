// $Id: $
// File name:   sqrt.sv
// Created:     4/1/2014
// Author:      Yuchen Cui
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: square root module
module sqrt(
  input wire clk,
  input wire [31:0] num_in,
  output wire [15:0] num_out,
  output wire dataready_out
  );
  
  reg next_state,curr_state;
  reg [31:0] y_square;
  reg [31:0] prev_num,curr_num;
  reg [15:0] y_curr,y_next;
  reg [4:0] pos_curr,pos_next;
  reg n_start,data_ready;
  
  //output port map
  assign num_out = y_curr;
  assign dataready_out = data_ready;
  
  //change detector
  always_ff @(posedge clk) begin
    curr_num <= num_in;
    prev_num <= curr_num;
  end //flip-flop for change detection
  
  always_comb begin
    if(prev_num != curr_num) n_start = 1'b0;
    else n_start = 1'b1;
  end //set n_start to 0 when change detected
  
  //predict
  assign y_square = y_next * y_next;
  
  always_ff @(posedge clk, negedge n_start) begin
    if(n_start == 0) begin
      curr_state <= 1'b1;
      y_curr <= 16'b100000000000;
      pos_curr <= 5'b10010;
    end else begin
      curr_state <= next_state;
      y_curr <= y_next;
      pos_curr <= pos_next;
    end
  end
  
  always_comb begin
    next_state = curr_state;
    y_next = y_curr;
    pos_next = pos_curr;
    data_ready = 1'b0;
    
    if( num_in < y_square) begin
      next_state = 1'b0;
    end else begin
      next_state = 1'b1;
    end
    
    case(pos_curr)
      5'b10001:
      begin
        pos_next = 5'b10001;
        //y_next = 16'b1000000000000000;
      end
      5'b10010: //set initial value and go to predict states
      begin
        pos_next = 5'b10000;
        y_next = 16'b1000000000000000;
      end
      5'b10000:
      begin
        pos_next = 5'b01111;
        //y_next = 16'b1000000000000000;
      end
      5'b01111: // update MSB
      begin
        pos_next = 5'b01110;
        y_next = {curr_state,15'b100000000000000};
      end
      5'b01110:
      begin
        pos_next = 5'b01101;
        y_next = {y_curr[15],curr_state,14'b10000000000000};
      end
      5'b01101:
      begin
        pos_next = 5'b01100;
        y_next = {y_curr[15:14],curr_state,13'b1000000000000};
      end
      5'b01100:
      begin
        pos_next = 5'b01011;
        y_next = {y_curr[15:13],curr_state,12'b100000000000};
      end
      5'b01011:
      begin
        pos_next = 5'b01010;
        y_next = {y_curr[15:12],curr_state,11'b10000000000};
      end
      5'b01010:
      begin
        pos_next = 5'b01001;
        y_next = {y_curr[15:11],curr_state,10'b1000000000};
      end
      5'b01001:
      begin
        pos_next = 5'b01000;
        y_next = {y_curr[15:10],curr_state,9'b100000000};
      end
      5'b01000:
      begin
        pos_next = 5'b00111;
        y_next = {y_curr[15:9],curr_state,8'b10000000};
      end
      5'b00111:
      begin
        pos_next = 5'b00110;
        y_next = {y_curr[15:8],curr_state,7'b1000000};
      end
      5'b00110:
      begin
        pos_next = 5'b00101;
        y_next = {y_curr[15:7],curr_state,6'b100000};
      end
      5'b00101:
      begin
        pos_next = 5'b00100;
        y_next = {y_curr[15:6],curr_state,5'b10000};
      end
      5'b00100:
      begin
        pos_next = 5'b00011;
        y_next = {y_curr[15:5],curr_state,4'b1000};
      end
      5'b00011:
      begin
        pos_next = 5'b00010;
        y_next = {y_curr[15:4],curr_state,3'b100};
      end
      5'b00010:
      begin
        pos_next = 5'b00001;
        y_next = {y_curr[15:3],curr_state,2'b10};
      end
      5'b00001:
      begin
        pos_next = 5'b00000;
        y_next = {y_curr[15:2],curr_state,1'b1};
      end
      5'b00000:
      begin
        pos_next = 5'b10001;
        y_next = {y_curr[15:1],curr_state};
        data_ready = 1'b1;
      end
    endcase
  end
  
  
  
endmodule