//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: binom_sample
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module binom_sample
  (
    input logic [31:0] in_1,
    input logic [31:0] in_2,
    input logic [2:0] mode, // 000 (q=3329,k=2), 001 (q=8192,k=3), 010(q=8192,k=4), 011 (q=8192,k=5), 100 (q=12289,k=8)
    output logic [31:0] result
  );

  logic [13:0] modulus;
  logic [1:0] cnt1_2, cnt2_2, cnt3_2, cnt4_2;
  logic [1:0] cnt1_3, cnt2_3, cnt3_3, cnt4_3;
  logic [2:0] cnt1_4, cnt2_4, cnt3_4, cnt4_4;
  logic [2:0] cnt1_5, cnt2_5, cnt3_5, cnt4_5;
  logic [3:0] cnt1_8, cnt2_8, cnt3_8, cnt4_8;
  
  logic [3:0] cnt1, cnt2, cnt3, cnt4;
  logic [15:0] tmp1, tmp2, tmp3, tmp4;
  logic [15:0] result_1, result_2;

  always_comb
  begin
    unique case (mode)
     2'b000: begin
       modulus = 3329;
       cnt1 = cnt1_2;
       cnt2 = cnt2_2;
       cnt3 = cnt3_2;
       cnt4 = cnt4_2;
     end
     2'b001: begin
       modulus = 8192;
       cnt1 = cnt1_3;
       cnt2 = cnt2_3;
       cnt3 = cnt3_3;
       cnt4 = cnt4_3;
     end
     2'b010: begin
       modulus = 8192;
       cnt1 = cnt1_4;
       cnt2 = cnt2_4;
       cnt3 = cnt3_4;
       cnt4 = cnt4_4;
     end
     2'b011: begin
       modulus = 8192;
       cnt1 = cnt1_5;
       cnt2 = cnt2_5;
       cnt3 = cnt3_5;
       cnt4 = cnt4_5;
     end
     default: begin
       modulus = 12289;
       cnt1 = cnt1_8;
       cnt2 = cnt2_8;
       cnt3 = cnt3_8;
       cnt4 = cnt4_8;
     end    
    endcase
  end

  assign cnt1_2 = in_1[0] + in_1[1];
  assign cnt2_2 = in_2[0] + in_2[1];
  assign cnt1_3 = cnt1_2 + in_1[2];
  assign cnt2_3 = cnt2_2 + in_2[2];
  assign cnt1_4 = cnt1_3 + in_1[3];
  assign cnt2_4 = cnt2_3 + in_2[3];
  assign cnt1_5 = cnt1_4 + in_1[4];
  assign cnt2_5 = cnt2_4 + in_2[4];
  assign cnt1_8 = cnt1_5 + in_1[5] + in_1[6] + in_1[7];
  assign cnt2_8 = cnt2_5 + in_2[5] + in_2[6] + in_2[7];
  
  assign tmp1 = (cnt1 + modulus) - cnt2;
  assign tmp2 = tmp1-modulus;
  assign result_1 = (tmp1 < modulus) ? tmp1 : tmp2;

  assign cnt3_2 = in_1[16] + in_1[17];
  assign cnt4_2 = in_2[16] + in_2[17];
  assign cnt3_3 = cnt3_2 + in_1[18];
  assign cnt4_3 = cnt4_2 + in_2[18];
  assign cnt3_4 = cnt3_3 + in_1[19];
  assign cnt4_4 = cnt4_3 + in_2[19];
  assign cnt3_5 = cnt3_4 + in_1[20];
  assign cnt4_5 = cnt4_4 + in_2[20];
  assign cnt3_8 = cnt3_5 + in_1[21] + in_1[22] + in_1[23];
  assign cnt4_8 = cnt4_5 + in_2[21] + in_2[22] + in_2[23];
  assign tmp3 = (cnt3 + modulus) - cnt4;
  assign tmp4 = tmp3-modulus;
  assign result_2 = (tmp3 < modulus) ? tmp3 : tmp4;

  assign result = {result_2,result_1};
endmodule
