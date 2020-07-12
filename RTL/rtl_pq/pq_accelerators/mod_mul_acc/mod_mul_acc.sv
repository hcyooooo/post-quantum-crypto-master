//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: mod_mul_acc
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////

module mod_mul_acc
  #( parameter LOG2_Q = 16)
  (
    input logic [31:0] in_1,
    input logic [31:0] in_2,
    input logic [31:0] in_3,
    output logic [31:0] result
  );
  

  logic [LOG2_Q-1:0] in1_l;
  logic [LOG2_Q-1:0] in1_h;
  logic [LOG2_Q-1:0] in2_l;
  logic [LOG2_Q-1:0] in2_h;
  logic [LOG2_Q-1:0] in3_l;
  logic [LOG2_Q-1:0] in3_h;
  
  logic [2*LOG2_Q-1:0] res_mul_l;
  logic [2*LOG2_Q-1:0] res_mul_h;
  
  logic [LOG2_Q:0] res_muladd_l;
  logic [LOG2_Q:0] res_muladd_h;
  
  // Split input
  assign in1_l = in_1[LOG2_Q-1:0];
  assign in2_l = in_2[LOG2_Q-1:0];
  assign in3_l = in_3[LOG2_Q-1:0];
  
  assign in1_h = in_1[LOG2_Q+15:16];
  assign in2_h = in_2[LOG2_Q+15:16];
  assign in3_h = in_3[LOG2_Q+15:16];
  
  // Calculate multiplications
  assign res_mul_l = in1_l * in2_l;
  assign res_mul_h = in1_h * in2_h;
  
  // Accumulate results
  assign res_muladd_l = res_mul_l[LOG2_Q-1:0] + in3_l;
  assign res_muladd_h = res_mul_h[LOG2_Q-1:0] + in3_h;
  
  assign result = {res_muladd_h[LOG2_Q-1:0],res_muladd_l[LOG2_Q-1:0]};
  
endmodule
