// $Id: $
// File name:   controllerUnit.sv
// Created:     4/15/2014
// Author:      Yuhao Chen
// Lab Section: 2
// Version:     1.0  Initial Design Entry
// Description: main controller
module controllerUnit
(
  input wire clk,
  input wire n_rst,
  input wire configured,
  input wire acc_ready,
  input wire gyro_ready,
  input wire mag_ready,
  input wire kalman_done,
  input wire output_done,
  output reg acc_read,
  output reg gyro_read,
  output reg mag_read,
  output reg load_preprocessor1,
  output reg load_preprocessor2,
  output reg load_gyro,
  output reg roll_clk,
  output reg pitch_clk,
  output reg yaw_clk,
  output reg yaw_enable,
  output reg roll_pitch_enable,
  output reg clear,
  output reg write_enable,
  output reg [1:0]output_sel
);

typedef enum bit [3:0] { IDLE, LOAD_ROLL_PITCH, CALCULATE_ROLL_PITCH , ROLL_PITCH_DONE, OUTPUT_ROLL, OUTPUT_PITCH, LOAD_YAW, CALCULATE_YAW, YAW_DONE, OUTPUT_YAW} stateType;


stateType state;
stateType next_state;

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
        if (acc_ready == 1'b1 && gyro_ready == 1'b1 && configured == 1'b1)
          begin
            next_state = LOAD_ROLL_PITCH;
          end
        if (mag_ready == 1'b1 && configured == 1'b1)
          begin
            next_state = LOAD_YAW;
          end
      end
    LOAD_ROLL_PITCH:
      begin
        next_state = CALCULATE_ROLL_PITCH;
      end
    CALCULATE_ROLL_PITCH:
      begin
        if (kalman_done == 1'b1)
          begin
            next_state = ROLL_PITCH_DONE;
          end
      end
    ROLL_PITCH_DONE:
      begin
        next_state = OUTPUT_ROLL;
      end
    OUTPUT_ROLL:
      begin
        if (output_done == 1'b1)
          begin
            next_state = OUTPUT_PITCH;
          end
      end
    OUTPUT_PITCH:
      begin
        if (output_done == 1'b1)
          begin
            next_state = IDLE;
          end
      end
    LOAD_YAW:
      begin
        next_state = CALCULATE_YAW;
      end
    CALCULATE_YAW:
      begin
        if (kalman_done == 1'b1)
          begin
            next_state = YAW_DONE;
          end
      end
    YAW_DONE:
      begin
        next_state = OUTPUT_YAW;
      end
    OUTPUT_YAW:
      begin
        if (output_done == 1'b1)
          begin
            next_state = IDLE;
          end
      end
  endcase 
end

//output logic
always_comb
begin
  acc_read = 0;
  gyro_read = 0;
  mag_read = 0;
  load_preprocessor1 = 0;
  load_preprocessor2 = 0;
  load_gyro = 0;
  roll_clk = 0;
  pitch_clk = 0;
  yaw_clk = 0;
  yaw_enable = 0;
  roll_pitch_enable = 0;
  clear = 1;
  write_enable = 0;
  output_sel = 0;
  
  case(state)
    IDLE:
      begin
        acc_read = 0;
        gyro_read = 0;
        mag_read = 0;
        load_preprocessor1 = 0;
        load_preprocessor2 = 0;
        load_gyro = 0;
        roll_clk = 0;
        pitch_clk = 0;
        yaw_clk = 0;
        yaw_enable = 0;
        roll_pitch_enable = 0;
        clear = 1;
        write_enable = 0;
        output_sel = 0;
      end
    LOAD_ROLL_PITCH:
      begin
        acc_read = 1;
        gyro_read = 1;
        mag_read = 0;
        load_preprocessor1 = 1;
        load_preprocessor2 = 0;
        load_gyro = 1;
        roll_clk = 0;
        pitch_clk = 0;
        yaw_clk = 0;
        yaw_enable = 0;
        roll_pitch_enable = 0;
        clear = 1;
        write_enable = 0;
        output_sel = 0;
      end
    CALCULATE_ROLL_PITCH:
      begin
        acc_read = 0;
        gyro_read = 0;
        mag_read = 0;
        load_preprocessor1 = 0;
        load_preprocessor2 = 0;
        load_gyro = 0;
        roll_clk = 0;
        pitch_clk = 0;
        yaw_clk = 0;
        yaw_enable = 0;
        roll_pitch_enable = 1;
        clear = 0;
        write_enable = 0;
        output_sel = 0;
      end
    ROLL_PITCH_DONE:
      begin
        acc_read = 0;
        gyro_read = 0;
        mag_read = 0;
        load_preprocessor1 = 0;
        load_preprocessor2 = 0;
        load_gyro = 0;
        roll_clk = 1;
        pitch_clk = 1;
        yaw_clk = 0;
        yaw_enable = 0;
        roll_pitch_enable = 0;
        clear = 1;
        write_enable = 0;
        output_sel = 0;
      end
    OUTPUT_ROLL:
      begin
        acc_read = 0;
        gyro_read = 0;
        mag_read = 0;
        load_preprocessor1 = 0;
        load_preprocessor2 = 0;
        load_gyro = 0;
        roll_clk = 0;
        pitch_clk = 0;
        yaw_clk = 0;
        yaw_enable = 0;
        roll_pitch_enable = 0;
        clear = 1;
        write_enable = 1;
        output_sel = 0;
      end
    OUTPUT_PITCH:
      begin
        acc_read = 0;
        gyro_read = 0;
        mag_read = 0;
        load_preprocessor1 = 0;
        load_preprocessor2 = 0;
        load_gyro = 0;
        roll_clk = 0;
        pitch_clk = 0;
        yaw_clk = 0;
        yaw_enable = 0;
        roll_pitch_enable = 0;
        clear = 1;
        write_enable = 1;
        output_sel = 1;
      end
    LOAD_YAW:
      begin
        acc_read = 0;
        gyro_read = 0;
        mag_read = 1;
        load_preprocessor1 = 0;
        load_preprocessor2 = 1;
        load_gyro = 0;
        roll_clk = 0;
        pitch_clk = 0;
        yaw_clk = 0;
        yaw_enable = 0;
        roll_pitch_enable = 0;
        clear = 1;
        write_enable = 0;
        output_sel = 0;
      end
    CALCULATE_YAW:
      begin
        acc_read = 0;
        gyro_read = 0;
        mag_read = 0;
        load_preprocessor1 = 0;
        load_preprocessor2 = 0;
        load_gyro = 0;
        roll_clk = 0;
        pitch_clk = 0;
        yaw_clk = 0;
        yaw_enable = 1;
        roll_pitch_enable = 0;
        clear = 0;
        write_enable = 0;
        output_sel = 0;
      end
    YAW_DONE:
      begin
        acc_read = 0;
        gyro_read = 0;
        mag_read = 0;
        load_preprocessor1 = 0;
        load_preprocessor2 = 0;
        load_gyro = 0;
        roll_clk = 0;
        pitch_clk = 0;
        yaw_clk = 1;
        yaw_enable = 0;
        roll_pitch_enable = 0;
        clear = 1;
        write_enable = 0;
        output_sel = 2;
      end
    OUTPUT_YAW:
      begin
        acc_read = 0;
        gyro_read = 0;
        mag_read = 0;
        load_preprocessor1 = 0;
        load_preprocessor2 = 0;
        load_gyro = 0;
        roll_clk = 0;
        pitch_clk = 0;
        yaw_clk = 0;
        yaw_enable = 0;
        roll_pitch_enable = 0;
        clear = 1;
        write_enable = 1;
        output_sel = 2;
      end
  endcase 
end

endmodule