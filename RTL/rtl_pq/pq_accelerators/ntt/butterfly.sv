//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: butterfly
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module butterfly
#(
  parameter DATA_WIDTH    = 32
)
(
  // Clock and Reset
  input  logic clk,
  input  logic rst_n,
  input  logic ntt_start,

  // Data input
  input logic [DATA_WIDTH-1:0] data1_i,
  input logic [DATA_WIDTH-1:0] data2_i,
  input logic [10:0] param_n,
  input logic [DATA_WIDTH/2-1:0] omega,
  input logic [DATA_WIDTH/2-1:0] omega_prev,
  input logic [DATA_WIDTH/2-1:0] modulus,
  input logic [17:0] param_MinQinvModR,
  input logic ntt_first_rounds,
  input logic fwd_ntt,
  
  input logic mul_psi1,
  input logic mul_psi2,
  input logic update_psi,
  
  input logic mod_mul,
  input logic mod_add,
  input logic mod_sub,
  
  input logic single_bfdif,
  
  // Data output
  output logic [DATA_WIDTH-1:0] data1_o,
  output logic [DATA_WIDTH-1:0] data2_o
);

  logic [DATA_WIDTH/2-1:0] omega_res;
  logic [DATA_WIDTH/2-1:0] res_mul1;
  logic [DATA_WIDTH/2-1:0] res_mul2;
  logic [DATA_WIDTH/2-1:0] res_add1;
  logic [DATA_WIDTH/2-1:0] res_add2;
  logic [DATA_WIDTH/2-1:0] res_sub1;
  logic [DATA_WIDTH/2-1:0] res_sub2;
  logic [DATA_WIDTH/2-1:0] res_sub3;
  logic [DATA_WIDTH/2-1:0] res_sub4;
  
  logic [1:0] sel;
  logic [DATA_WIDTH/2-1:0] mux1_o;
  logic [DATA_WIDTH/2-1:0] mux2_o;
  logic [DATA_WIDTH/2-1:0] mux3_o;
  logic [DATA_WIDTH/2-1:0] mux4_o;
  
  logic [DATA_WIDTH/2-1:0] mux_sub11_o;
  logic [DATA_WIDTH/2-1:0] mux_add11_o;
  logic [DATA_WIDTH/2-1:0] mux_sub21_o;
  logic [DATA_WIDTH/2-1:0] mux_sub22_o;
  logic [DATA_WIDTH/2-1:0] mux_add21_o;
  logic [DATA_WIDTH/2-1:0] mux_add22_o;
  
  logic [DATA_WIDTH/2-1:0] L1;
  logic [DATA_WIDTH/2-1:0] H1;
  logic [DATA_WIDTH/2-1:0] L2;
  logic [DATA_WIDTH/2-1:0] H2;
  
  logic [DATA_WIDTH/2-1:0] L3;
  logic [DATA_WIDTH/2-1:0] H3;
  logic [DATA_WIDTH/2-1:0] L1_2;
  logic [DATA_WIDTH/2-1:0] H1_2;  
  
  logic [DATA_WIDTH/2-1:0] y1;
  logic [DATA_WIDTH/2-1:0] y2;
  
  logic [DATA_WIDTH/2-1:0] PARAM_INV_GAMMA_MONTGOMERY;
  logic [DATA_WIDTH/2-1:0] PARAM_SCALED_INVERSE_GAMMA_MONTGOMERY;
  logic [DATA_WIDTH/2-1:0] PARAM_SCALED_INVERSE_GAMMA_M_MONTGOMERY;
  
  // n=256
  localparam [15:0] PARAM_INV_GAMMA_MONTGOMERY_256 = 5467;
  localparam [15:0] PARAM_SCALED_INVERSE_GAMMA_MONTGOMERY_256 = 1024;  // N^-1 * 2^18 mod q
  localparam [15:0] PARAM_SCALED_INVERSE_GAMMA_M_MONTGOMERY_256 = 61;  // N^-1 * 3383 * 2^18 mod q
  
  // n=512
  localparam [15:0] PARAM_INV_GAMMA_MONTGOMERY_512 = 3932;
  localparam [15:0] PARAM_SCALED_INVERSE_GAMMA_MONTGOMERY_512 = 512;  // N^-1 * 2^18 mod q
  localparam [15:0] PARAM_SCALED_INVERSE_GAMMA_M_MONTGOMERY_512 = 4670;  // N^-1 * 10810 * 2^18 mod q
  
  // n=1024
  localparam [15:0] PARAM_INV_GAMMA_MONTGOMERY_1024 = 9360;
  localparam [15:0] PARAM_SCALED_INVERSE_GAMMA_MONTGOMERY_1024 = 256;  // N^-1 * 2^18 mod q
  localparam [15:0] PARAM_SCALED_INVERSE_GAMMA_M_MONTGOMERY_1024 = 9954;  // N^-1 * 1479 * 2^18 mod q
  
  assign PARAM_INV_GAMMA_MONTGOMERY = (param_n == 11'h400) ? PARAM_INV_GAMMA_MONTGOMERY_1024 : (param_n == 11'h200) ? PARAM_INV_GAMMA_MONTGOMERY_512 : PARAM_INV_GAMMA_MONTGOMERY_256;
  assign PARAM_SCALED_INVERSE_GAMMA_MONTGOMERY = (param_n == 11'h400) ? PARAM_SCALED_INVERSE_GAMMA_MONTGOMERY_1024 : (param_n == 11'h200) ? PARAM_SCALED_INVERSE_GAMMA_MONTGOMERY_512 : PARAM_SCALED_INVERSE_GAMMA_MONTGOMERY_256;
  assign PARAM_SCALED_INVERSE_GAMMA_M_MONTGOMERY = (param_n == 11'h400) ? PARAM_SCALED_INVERSE_GAMMA_M_MONTGOMERY_1024 : (param_n == 11'h200) ? PARAM_SCALED_INVERSE_GAMMA_M_MONTGOMERY_512 : PARAM_SCALED_INVERSE_GAMMA_M_MONTGOMERY_256;
  
  assign L1 = data1_i[DATA_WIDTH/2-1:0];
  assign H1 = data1_i[DATA_WIDTH-1:DATA_WIDTH/2];
  assign L2 = data2_i[DATA_WIDTH/2-1:0];
  assign H2 = data2_i[DATA_WIDTH-1:DATA_WIDTH/2];
  
  assign omega_res = (ntt_first_rounds == 1'b0) ? omega_prev : omega;
  assign L1_2 = (mul_psi1 == 1'b1) ? L1 : L2;
  assign H1_2 = (mul_psi1 == 1'b1) ? H1 : H2;
  
  // 00: normal bf operation
  // 01: multiply with psi1 or psi2
  // 10: update psi
  // 11: mod_mul
  assign sel = ((mul_psi1 | mul_psi2) == 1'b1) ? 2'b01 : (update_psi == 1'b1) ? 2'b10 : (mod_mul == 1'b1) ? 2'b11 : 2'b00;
  
  assign mux1_o = (single_bfdif == 1'b1) ? res_sub3 : (sel == 2'b00) ? H1 : (sel == 2'b10) ? y1 : L1_2;
  assign mux2_o = (single_bfdif == 1'b1) ? omega : (sel == 2'b00) ? omega_res : (sel == 2'b01) ? y1 : (sel == 2'b10) ? PARAM_INV_GAMMA_MONTGOMERY : L1;
  assign mux3_o = (single_bfdif == 1'b1) ? res_sub4 : (sel == 2'b00) ? H2 : (sel == 2'b10) ? y2 : H1_2;
  assign mux4_o = (single_bfdif == 1'b1) ? omega : (sel == 2'b00) ? omega : (sel == 2'b01) ? y2 : (sel == 2'b10) ? PARAM_INV_GAMMA_MONTGOMERY: H1;
  
  always_ff @(posedge clk, negedge rst_n)
  begin
    if (rst_n == 1'b0) begin
      y1 <= '0;
      y2 <= '0;
    end else if (ntt_start == 1'b1) begin
      y1 <= PARAM_SCALED_INVERSE_GAMMA_MONTGOMERY;
      y2 <= PARAM_SCALED_INVERSE_GAMMA_M_MONTGOMERY;
    end else if(update_psi == 1'b1) begin
      y1 <= res_mul1;
      y2 <= res_mul2;
    end
  end


  multiplier multiplier_inst1
  (
    .modulus(modulus),
    .param_MinQinvModR(param_MinQinvModR),
    .in1(mux1_o),
    .in2(mux2_o),
    .result(res_mul1)
  );
  
  multiplier multiplier_inst2
  (
    .modulus(modulus),
    .param_MinQinvModR(param_MinQinvModR),
    .in1(mux3_o),
    .in2(mux4_o),
    .result(res_mul2)
  );
  
  assign mux_sub11_o = (mod_sub == 1'b1) ? L2 : res_mul1;
  assign mux_add11_o = (single_bfdif == 1'b1) ? H1 : (mod_add == 1'b1) ? L2 : res_mul1;
  assign mux_sub21_o = (mod_sub == 1'b1) ? H1 : L2;
  assign mux_sub22_o = (mod_sub == 1'b1) ? H2 : res_mul2;
  assign mux_add21_o = (single_bfdif == 1'b1) ? L2 : (mod_add == 1'b1) ? H1 : res_mul2;
  assign mux_add22_o = (single_bfdif == 1'b1) ? H2 : (mod_add == 1'b1) ? H2 : L2;
  
  adder adder_inst1
  (
    .modulus(modulus),
    .in1(mux_add11_o),
    .in2(L1),
    .result(res_add1)
  );
  
  adder adder_inst2
  (
    .modulus(modulus),
    .in1(mux_add21_o),
    .in2(mux_add22_o),
    .result(res_add2)
  );
  
  subtractor subtractor_inst1
  (
    .modulus(modulus),
    .in1(L1),
    .in2(mux_sub11_o),
    .result(res_sub1)
  );

  subtractor subtractor_inst2
  (
    .modulus(modulus),
    .in1(mux_sub21_o),
    .in2(mux_sub22_o),
    .result(res_sub2)
  );
  
  subtractor subtractor_inst3
  (
    .modulus(modulus),
    .in1(L1),
    .in2(H1),
    .result(res_sub3)
  );

  subtractor subtractor_inst4
  (
    .modulus(modulus),
    .in1(L2),
    .in2(H2),
    .result(res_sub4)
  );
  
  always_ff @(posedge clk, negedge rst_n)
  begin
    if (rst_n == 1'b0) begin
      L3 <= '0;
      H3 <= '0;
    end else if((mul_psi1 | mul_psi2) == 1) begin
      L3 <= res_mul1;
      H3 <= res_mul2;
    end
  end
  
  assign data1_o = (single_bfdif == 1'b1) ? {res_add2,res_add1} : (mod_mul == 1'b1) ? {res_mul2,res_mul1} : (mod_add == 1'b1) ? {res_add2,res_add1} : (mod_sub == 1'b1) ? {res_sub2,res_sub1} : (mul_psi2 == 1'b1) ? {res_mul1,L3} : ((fwd_ntt == 1'b0) && (ntt_first_rounds == 1'b0)) ? {res_sub1,res_add1} : {res_add2,res_add1};
  assign data2_o = (single_bfdif == 1'b1) ? {res_mul2,res_mul1} : (mul_psi2 == 1'b1) ? {res_mul2,H3} : ((fwd_ntt == 1'b0) && (ntt_first_rounds == 1'b0)) ? {res_sub2,res_add2} : {res_sub2,res_sub1};

endmodule
