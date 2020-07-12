`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: binom_sample_tb
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module binom_sample_tb();

  localparam DATA_WIDTH = 16;
  logic [DATA_WIDTH-1:0] in_1, in_2;
  logic [2*DATA_WIDTH-1:0] result;
  logic [2*DATA_WIDTH-1:0] PARAM_Q = 12289;
    
  binom_sample binom_sample_i
  (
    .in_1(in_1),
    .in_2(in_2),
    .mode(2'b11),
    .result(result)
  );
    
  initial
  begin
    in_1 <= 16'b0000000001111010;
    in_2 <= 16'b0000100010001000;
  end
    
endmodule
