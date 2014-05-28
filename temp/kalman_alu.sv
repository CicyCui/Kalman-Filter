// $Id: $
// File name:   kalman_alu_modified.sv
// Created:     4/18/2014
// Author:      Haichao Xu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: .

module kalman_alu
  (
    input wire clk,
    input wire n_rst,
    input reg [47:0] gyro_data,//from gyro 48 bits, gyro[15:0] is roll, gyro[31:16] is pitch, gyro[47:32] is yaw
    input reg [7:0] dt_in, //from counter can we set the delta time to constant
    input reg [15:0] yaw_data, // yaw from acc
    input reg [15:0] roll_data, // roll from acc
    input reg [15:0] new_angle_in, //from the accelermeter pitch
    input wire load_gyro, // also play the role as enable of the mux
    input wire pitch_en,
    input wire yaw_en,
    input wire roll_en,
    output wire [15:0] yaw_out,
    output wire [15:0] pitch_out, // pitch angle output
    output wire [15:0] roll_out


    //output wire kalman_alu_done  // if the calculations are completed, turn this flag on

    );
    reg [15:0] angle_out_out_yaw;
    reg [15:0] angle_out_out; // pitch angle output
    reg [15:0] angle_out_out_roll;
    wire [15:0] Q_gyrobias_in;//constant 0.003
    wire [15:0] Q_angle_in;//constant 0.001
    wire [15:0] R_angle_in;//constant 0.03 
    //check these constants   actually I am using these constant as degree, but not precise enough
    //assign Q_gyrobias_in = 16'h00C5;//constant 0.003
    //assign Q_angle_in = 16'h0042;//constant 0.001
    //assign R_angle_in = 197;
    reg [15:0] bias_out;
    reg [15:0] angle_out;
    
    reg [15:0] bias_out_yaw;
    reg [15:0] angle_out_yaw;
    
    reg [15:0] bias_out_roll;
    reg [15:0] angle_out_roll;
    
    
    
    wire [22:0] P00_out;  // will feed to step 4 and step 5
    wire [22:0] P01_out;
    wire [22:0] P10_out;
    wire [22:0] P11_out;
    
    wire [22:0] P00_out_yaw;  // will feed to step 4 and step 5
    wire [22:0] P01_out_yaw;
    wire [22:0] P10_out_yaw;
    wire [22:0] P11_out_yaw;
    
    wire [22:0] P00_out_roll;  // will feed to step 4 and step 5
    wire [22:0] P01_out_roll;
    wire [22:0] P10_out_roll;
    wire [22:0] P11_out_roll;
    
    
    reg [22:0] P00_out_out;
    reg [22:0] P01_out_out;
    reg [22:0] P10_out_out;
    reg [22:0] P11_out_out;
    
    reg [22:0] P00_out_out_yaw;
    reg [22:0] P01_out_out_yaw;
    reg [22:0] P10_out_out_yaw;
    reg [22:0] P11_out_out_yaw;
        
    reg [22:0] P00_out_out_roll;
    reg [22:0] P01_out_out_roll;
    reg [22:0] P10_out_out_roll;
    reg [22:0] P11_out_out_roll;
    
    wire [15:0] y_out;   
    wire [22:0] S_out; //innovation  will feed to step5
    wire [12:0] K0_out; // kalman gain K[0], assume kalman gain is 16bits
    wire [12:0] K1_out; //kalman gain K[1]
    
    wire [15:0] y_out_yaw;   
    wire [22:0] S_out_yaw; //innovation  will feed to step5
    wire [12:0] K0_out_yaw; // kalman gain K[0], assume kalman gain is 16bits
    wire [12:0] K1_out_yaw; //kalman gain K[1]
    
    wire [15:0] y_out_roll;   
    wire [22:0] S_out_roll; //innovation  will feed to step5
    wire [12:0] K0_out_roll; // kalman gain K[0], assume kalman gain is 16bits
    wire [12:0] K1_out_roll; //kalman gain K[1]
    
    
    reg [15:0] angle_in;
    
    reg [15:0] angle_in_yaw;
    
    reg [15:0] angle_in_roll;
    
    reg [22:0] P00_in;
    reg [22:0] P01_in;
    reg [22:0] P10_in;
    reg [22:0] P11_in;
    
    reg [22:0] P00_in_yaw;
    reg [22:0] P01_in_yaw;
    reg [22:0] P10_in_yaw;
    reg [22:0] P11_in_yaw;
    
    reg [22:0] P00_in_roll;
    reg [22:0] P01_in_roll;
    reg [22:0] P10_in_roll;
    reg [22:0] P11_in_roll;
    
    reg [15:0] bias_in; // from last bias
    
    reg [15:0] bias_in_yaw;
    
    reg [15:0] bias_in_roll;
    
    reg [15:0] gyro_data_reg;
    reg [15:0] gyro_data_reg_yaw;
    reg [15:0] gyro_data_reg_roll;
    always_ff @(posedge clk, negedge n_rst)
    begin
      if (n_rst == 0)
        begin
          //We have three set of reg for our three angle rate
          //check the reset values
          angle_in <= 0;
          P00_in <= 23'b00000000001111111111111;
          P01_in <= 0;
          P10_in <= 0;
          P11_in <= 23'b00000000001111111111111;
          bias_in <= 0;
          gyro_data_reg <= 0;
          //Yaw angle reg
          angle_in_yaw <= 0;
          P00_in_yaw <= 23'b00000000001111111111111;
          P01_in_yaw <= 0;
          P10_in_yaw <= 0;
          P11_in_yaw <= 23'b00000000001111111111111;
          bias_in_yaw <= 0;
          gyro_data_reg_yaw <= 0;
          //ROll angle reg
          angle_in_roll <= 0;
          P00_in_roll <= 23'b00000000001111111111111;
          P01_in_roll <= 0;
          P10_in_roll <= 0;
          P11_in_roll <= 23'b00000000001111111111111;
          bias_in_roll <= 0;
          gyro_data_reg_roll <= 0;
        end
        else
           begin
              if (load_gyro == 1)
                begin
                  gyro_data_reg <= {gyro_data[31],13'b0000000000000,gyro_data[30:29]};
                  gyro_data_reg_yaw <= {gyro_data[47],13'b0000000000000,gyro_data[46:45]};
                  gyro_data_reg_roll <= {gyro_data[15],13'b0000000000000,gyro_data[14:13]};
                end
              else
                begin
                  gyro_data_reg <= gyro_data_reg;
                  gyro_data_reg_yaw <= gyro_data_reg_yaw;
                  gyro_data_reg_roll <= gyro_data_reg_roll;
                end
              if (pitch_en == 1)
                begin
                  angle_in <= angle_out_out;
                  P00_in <= P00_out_out;
                  P01_in <= P01_out_out;
                  P10_in <= P10_out_out;
                  P11_in <= P11_out_out;
                  bias_in <= bias_out;
                end
              else
                begin
                  angle_in <= angle_in;
                  P00_in <= P00_in;
                  P01_in <= P01_in;
                  P10_in <= P10_in;
                  P11_in <= P11_in;
                  bias_in <= bias_in;
                end
              if (yaw_en == 1)
                begin
                 angle_in_yaw <= angle_out_out_yaw;
                 P00_in_yaw <= P00_out_out_yaw;
                 P01_in_yaw <= P01_out_out_yaw;
                 P10_in_yaw <= P10_out_out_yaw;
                 P11_in_yaw <= P11_out_out_yaw;
                 bias_in_yaw <= bias_out_yaw;
               end
             else
               begin
                 angle_in_yaw <= angle_in_yaw;
                 P00_in_yaw <= P00_in_yaw;
                 P01_in_yaw <= P01_in_yaw;
                 P10_in_yaw <= P10_in_yaw;
                 P11_in_yaw <= P11_in_yaw;
                 bias_in_yaw <= bias_in_yaw;
               end
              if (roll_en == 1)
                begin
                 angle_in_roll <= angle_out_out_roll;
                 P00_in_roll <= P00_out_out_roll;
                 P01_in_roll <= P01_out_out_roll;
                 P10_in_roll <= P10_out_out_roll;
                 P11_in_roll <= P11_out_out_roll;
                 bias_in_roll <= bias_out_roll;
               end
             else
               begin
                 angle_in_roll <= angle_in_roll;
                 P00_in_roll <= P00_in_roll;
                 P01_in_roll <= P01_in_roll;
                 P10_in_roll <= P10_in_roll;
                 P11_in_roll <= P11_in_roll;
                 bias_in_roll <= bias_in_roll;
               end
        end
    end
    assign pitch_out = angle_in;
    assign yaw_out = angle_in_yaw;
    assign roll_out = angle_in_roll;
    //First kalman alu for pitch angle
    //inputs are anlge_in bias_in dt_in gyro_data_reg Pmatrix, outputs are bias_out(reg) angle_out_out(real output and feed to reg angle_in) Pmatrix(reg)
    kalman_alu1 dut1(.angle_in(angle_in), .bias_in(bias_in), .new_rate_in(gyro_data_reg), .dt_in(dt_in), .angle_out(angle_out));
    kalman_alu2 dut2(.P00_in(P00_in),.P01_in(P01_in),.P10_in(P10_in),.P11_in(P11_in),.dt_in(dt_in),.Q_gyrobias_in(Q_gyrobias_in),.Q_angle_in(Q_angle_in),.P00_out(P00_out),.P01_out(P01_out),.P10_out(P10_out),.P11_out(P11_out));
    kalman_alu3 dut3(.new_angle_in(new_angle_in),.angle_out(angle_out),.y_out(y_out));
    kalman_alu4 dut4(.P00_out(P00_out),.R_angle_in(R_angle_in),.S_out(S_out)); // S_out is 16bits integer and 16bits floating points
    kalman_alu5 dut5(.S_out(S_out),.P00_out(P00_out),.P10_out(P10_out),.K0_out(K0_out),.K1_out(K1_out));
    kalman_alu6 dut6(.K0_out(K0_out),.K1_out(K1_out),.y_out(y_out),.bias_in(bias_in),.angle_out(angle_out),.angle_out_out(angle_out_out),.bias_out(bias_out));
    kalman_alu7 dut7(.P00_out(P00_out),.P01_out(P01_out),.P10_out(P10_out),.P11_out(P11_out),.K0_out(K0_out),.K1_out(K1_out),.P00_out_out(P00_out_out),.P01_out_out(P01_out_out),.P10_out_out(P10_out_out),.P11_out_out(P11_out_out));
    
    
    //Second kalman alu for yaw angle
    kalman_alu1 dut8(.angle_in(angle_in_yaw), .bias_in(bias_in_yaw), .new_rate_in(gyro_data_reg_yaw), .dt_in(dt_in), .angle_out(angle_out_yaw));
    kalman_alu2 dut9(.P00_in(P00_in_yaw),.P01_in(P01_in_yaw),.P10_in(P10_in_yaw),.P11_in(P11_in_yaw),.dt_in(dt_in),.Q_gyrobias_in(Q_gyrobias_in),.Q_angle_in(Q_angle_in),.P00_out(P00_out_yaw),.P01_out(P01_out_yaw),.P10_out(P10_out_yaw),.P11_out(P11_out_yaw));
    kalman_alu3 dut10(.new_angle_in(yaw_data),.angle_out(angle_out_yaw),.y_out(y_out_yaw));
    kalman_alu4 dut11(.P00_out(P00_out_yaw),.R_angle_in(R_angle_in),.S_out(S_out_yaw)); // S_out is 16bits integer and 16bits floating points
    kalman_alu5 dut12(.S_out(S_out_yaw),.P00_out(P00_out_yaw),.P10_out(P10_out_yaw),.K0_out(K0_out_yaw),.K1_out(K1_out_yaw));
    kalman_alu6 dut13(.K0_out(K0_out_yaw),.K1_out(K1_out_yaw),.y_out(y_out_yaw),.bias_in(bias_in_yaw),.angle_out(angle_out_yaw),.angle_out_out(angle_out_out_yaw),.bias_out(bias_out_yaw));
    kalman_alu7 dut14(.P00_out(P00_out_yaw),.P01_out(P01_out_yaw),.P10_out(P10_out_yaw),.P11_out(P11_out_yaw),.K0_out(K0_out_yaw),.K1_out(K1_out_yaw),.P00_out_out(P00_out_out_yaw),.P01_out_out(P01_out_out_yaw),.P10_out_out(P10_out_out_yaw),.P11_out_out(P11_out_out_yaw));

    
    //Third kalman alu for roll angle
    kalman_alu1 dut15(.angle_in(angle_in_roll), .bias_in(bias_in_roll), .new_rate_in(gyro_data_reg_roll), .dt_in(dt_in), .angle_out(angle_out_roll));
    kalman_alu2 dut16(.P00_in(P00_in_roll),.P01_in(P01_in_roll),.P10_in(P10_in_roll),.P11_in(P11_in_roll),.dt_in(dt_in),.Q_gyrobias_in(Q_gyrobias_in),.Q_angle_in(Q_angle_in),.P00_out(P00_out_roll),.P01_out(P01_out_roll),.P10_out(P10_out_roll),.P11_out(P11_out_roll));
    kalman_alu3 dut17(.new_angle_in(roll_data),.angle_out(angle_out_roll),.y_out(y_out_roll));
    kalman_alu4 dut18(.P00_out(P00_out_roll),.R_angle_in(R_angle_in),.S_out(S_out_roll)); // S_out is 16bits integer and 16bits floating points
    kalman_alu5 dut19(.S_out(S_out_roll),.P00_out(P00_out_roll),.P10_out(P10_out_roll),.K0_out(K0_out_roll),.K1_out(K1_out_roll));
    kalman_alu6 dut20(.K0_out(K0_out_roll),.K1_out(K1_out_roll),.y_out(y_out_roll),.bias_in(bias_in_roll),.angle_out(angle_out_roll),.angle_out_out(angle_out_out_roll),.bias_out(bias_out_roll));
    kalman_alu7 dut21(.P00_out(P00_out_roll),.P01_out(P01_out_roll),.P10_out(P10_out_roll),.P11_out(P11_out_roll),.K0_out(K0_out_roll),.K1_out(K1_out_roll),.P00_out_out(P00_out_out_roll),.P01_out_out(P01_out_out_roll),.P10_out_out(P10_out_out_roll),.P11_out_out(P11_out_out_roll));

  endmodule
  
  
  
  /*
       
           //pitch angle
          angle_in <= angle_out_out;
          P00_in <= P00_out_out;
          P01_in <= P01_out_out;
          P10_in <= P10_out_out;
          P11_in <= P11_out_out;
          bias_in <= bias_out;
          gyro_data_reg <= {gyro_data[31],13'b0000000000000,gyro_data[30:29]};
          //yaw angle
          angle_in_yaw <= angle_out_out_yaw;
          P00_in_yaw <= P00_out_out_yaw;
          P01_in_yaw <= P01_out_out_yaw;
          P10_in_yaw <= P10_out_out_yaw;
          P11_in_yaw <= P11_out_out_yaw;
          bias_in_yaw <= bias_out_yaw;
          gyro_data_reg_yaw <= {gyro_data[47],13'b0000000000000,gyro_data[46:45]};
          //roll angle
          angle_in_roll <= angle_out_out_roll;
          P00_in_roll <= P00_out_out_roll;
          P01_in_roll <= P01_out_out_roll;
          P10_in_roll <= P10_out_out_roll;
          P11_in_roll <= P11_out_out_roll;
          bias_in_roll <= bias_out_roll;
          gyro_data_reg_roll <= {gyro_data[15],13'b0000000000000,gyro_data[14:13]};
        end
      else
        begin
          angle_in <= angle_in;
          P00_in <= P00_in;
          P01_in <= P01_in;
          P10_in <= P10_in;
          P11_in <= P11_in;
          bias_in <= bias_in;
          gyro_data_reg <= gyro_data_reg;
          //yaw angle
          angle_in_yaw <= angle_in_yaw;
          P00_in_yaw <= P00_in_yaw;
          P01_in_yaw <= P01_in_yaw;
          P10_in_yaw <= P10_in_yaw;
          P11_in_yaw <= P11_in_yaw;
          bias_in_yaw <= bias_in_yaw;
          gyro_data_reg_yaw <= gyro_data_reg_yaw;
          //roll angle
          angle_in_roll <= angle_in_roll;
          P00_in_roll <= P00_in_roll;
          P01_in_roll <= P01_in_roll;
          P10_in_roll <= P10_in_roll;
          P11_in_roll <= P11_in_roll;
          bias_in_roll <= bias_in_roll;
          gyro_data_reg_roll <= gyro_data_reg_roll;
        end
        */
