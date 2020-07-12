//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: omega_update_unit
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module omega_update_unit
  #(
    parameter DATA_WIDTH = 16
  )
  (
    input logic clk,
    input logic rst_n,
    input logic [10:0] param_n,
    input logic [DATA_WIDTH-1:0] modulus,
    input logic [17:0] param_MinQinvModR,
    input logic update_m,
    input logic [3:0] index,
    input logic update_omega,
    input logic fwd_ntt,
    output logic [DATA_WIDTH-1:0] omega_o,
    output logic [DATA_WIDTH-1:0] omega_prev_o
  );

  logic [DATA_WIDTH-1:0] omega_m_table_montgomery [10:0];
  logic [DATA_WIDTH-1:0] inv_omega_m_table_montgomery [10:0];

  // n = 256
  localparam [15:0] omega_m_table_montgomery_256 [10:0] = {0, 0, 7613, 3465, 606, 3583, 484, 578, 2634, 7427, 6691};
  localparam [15:0] inv_omega_m_table_montgomery_256 [10:0] = {0, 0, 5467, 4672, 5724, 7678, 2025, 6586, 862, 254, 6691};

  // n = 512
  localparam [15:0] omega_m_table_montgomery_512 [10:0] = {0, 11796, 12225, 12097, 10561, 7500, 2344, 522, 7965, 5315, 8214}; 
  localparam [15:0] inv_omega_m_table_montgomery_512 [10:0] = {0, 3932, 9551, 7280, 10367, 1190, 3514, 7210, 4916, 6974, 8214};

  // n = 1024
  localparam [15:0] omega_m_table_montgomery_1024 [10:0] = {3947, 3051, 2031, 9987, 11973, 4536, 6364, 3262, 7373, 6974, 8214};
  localparam [15:0] inv_omega_m_table_montgomery_1024 [10:0] = {9360, 10115, 1962, 52, 9090, 147, 10316, 10120, 4324, 5315, 8214};

  logic [DATA_WIDTH-1:0] omega_m;
  logic [15:0] mul_in1;
  logic [15:0] mul_in2;
  logic [15:0] mul_out;
  logic [DATA_WIDTH-1:0] omega;
  localparam [15:0] PARAM_R_MOD_Q_256 = 990;
  localparam [15:0] PARAM_R_MOD_Q_512_1024 = 4075;
  logic [15:0] PARAM_R_MOD_Q;

  assign omega_m_table_montgomery = (param_n == 11'h400) ? omega_m_table_montgomery_1024 : (param_n == 11'h200) ? omega_m_table_montgomery_512 : omega_m_table_montgomery_256;
  assign inv_omega_m_table_montgomery = (param_n == 11'h400) ? inv_omega_m_table_montgomery_1024 : (param_n == 11'h200) ? inv_omega_m_table_montgomery_512 : inv_omega_m_table_montgomery_256;
  assign PARAM_R_MOD_Q = (param_n == 11'h100) ? PARAM_R_MOD_Q_256 : PARAM_R_MOD_Q_512_1024;

  assign omega_m = (fwd_ntt == 1'b1) ? omega_m_table_montgomery[index] : inv_omega_m_table_montgomery[index];
  assign omega_o = omega;
  assign mul_in1 = omega_m;
  assign mul_in2 = omega;

  always_ff @(posedge clk, negedge rst_n)
  begin
    if (rst_n == 1'b0) begin
      omega <= '0;
      omega_prev_o <= '0;
    end else begin
      if (update_m == 1'b1) begin
        if(fwd_ntt == 1'b1)
          omega <= omega_m_table_montgomery[index+1];
        else
          omega <= PARAM_R_MOD_Q;
      end else if (update_omega == 1'b1) begin
        omega <= mul_out;
        omega_prev_o <= omega;
      end
    end
  end


  multiplier multiplier_inst1
  (
    .modulus(modulus),
    .param_MinQinvModR(param_MinQinvModR),
    .in1(mul_in1),
    .in2(mul_in2),
    .result(mul_out)
  );

endmodule
