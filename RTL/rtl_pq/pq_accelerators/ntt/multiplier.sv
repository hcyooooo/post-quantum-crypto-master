`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2020 09:09:00 PM
// Design Name: 
// Module Name: multiplier
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module multiplier
  # (PARAM_RLOG = 18)
  ( 
    input logic [15:0] modulus,
    input logic [17:0] param_MinQinvModR,
    input logic [15:0] in1,
    input logic [15:0] in2,
    output logic [15:0] result
  );
  
  logic [31:0] a;
  logic [50:0] ap;
  logic [49:0] u;
  
  logic [15:0] result_int;  
  
  always_comb
  begin
    a = in1 * in2;
    u = a * param_MinQinvModR;
    ap = a + (u[PARAM_RLOG-1:0] * modulus);
    result_int = ap[PARAM_RLOG+15:PARAM_RLOG];
    if (modulus <= result_int) begin
      result_int -= modulus;
    end
  end
  
  assign result = result_int;
  
  
endmodule
