`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: mod_mul_acc_tb
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module mod_mul_acc_tb();

  localparam DATA_WIDTH = 32;
  logic [DATA_WIDTH-1:0] in1, in2, in3;
  logic [DATA_WIDTH-1:0] result;
    
  mod_mul_acc mod_mul_acc_i
  (
    .in1(in1),
    .in2(in2),
    .in3(in3),
    .result(result)
  );
    
  initial
  begin
    in1 <= 32'h19990301;
    in2 <= 32'h04010201;
    in3 <= 32'h10040005;
  end
    
endmodule
