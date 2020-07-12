`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: mul_general_tb
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


`define CLK_PERIOD       40.00ns      // 25 MHz

module mul_general_tb;
//    parameter PARAM_M = 4;
//    parameter PARAM_ALPHA = 1;
    parameter PARAM_M = 9;
    parameter PARAM_ALPHA = 4;
    logic clk;
    logic rst;   
    logic enable; 
    logic [PARAM_M-1:0] in_1;
    logic [PARAM_M-1:0] in_2;
    logic [PARAM_M-1:0] out_1;
    logic ready;


    mul_general #(.PARAM_M(PARAM_M), .PARAM_ALPHA(PARAM_ALPHA)) mul_general_dut
    (
        .clk(clk),
        .rst(rst),
        .enable(enable),   
        .in_1(in_1),
        .in_2(in_2),
        .out_1(out_1),
        .ready(ready)
    );
    
    initial
    begin
//       in_1 = 4'b1111;
//       in_2 = 4'b0100;
//       in_1 = 9'b100000000;
//       in_2 = 9'b000000100;
       enable = 0;
       in_1 = 9'b000000001;
       in_2 = 9'b000000001;
       rst = 0;
       #(`CLK_PERIOD);
       rst = 1;
       #(`CLK_PERIOD*2);
       rst = 0;
       enable = 1;
       #(`CLK_PERIOD*8);
       enable = 0;      
       
    end
    
    initial
    begin
      clk = 1'b0;
      #(`CLK_PERIOD/2);
      clk = 1'b1;
      forever clk = #(`CLK_PERIOD/2) ~clk;
    end
       

endmodule
