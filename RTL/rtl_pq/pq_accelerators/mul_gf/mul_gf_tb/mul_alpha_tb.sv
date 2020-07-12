`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: mul_alpha_tb
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////

`define CLK_PERIOD       40.00ns      // 25 MHz

module mul_alpha_tb;
    parameter PARAM_M = 4;
    parameter PARAM_ALPHA = 1;
    logic clk;
    logic rst;    
    logic [PARAM_M-1:0] in_1;
    logic [PARAM_M-1:0] out_1;


    mul_alpha #(.PARAM_M(PARAM_M), .PARAM_ALPHA(PARAM_ALPHA)) mul_alpha_dut
    (
        .clk(clk),
        .rst(rst),    
        .in_1(in_1),
        .out_1(out_1)
    );
    
    initial
    begin
       in_1 = 4'b0001;
       rst = 0;
       #(`CLK_PERIOD);
       rst = 1;
       #(`CLK_PERIOD*2);
       rst = 0;
       
       
    end
    
    initial
    begin
      clk = 1'b0;
      #(`CLK_PERIOD/2);
      clk = 1'b1;
      forever clk = #(`CLK_PERIOD/2) ~clk;
    end
       

endmodule
