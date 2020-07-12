`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: chien_tb
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


`define CLK_PERIOD       40.00ns      // 25 MHz

module chien_tb;
    parameter PARAM_M = 9;
    parameter PARAM_ALPHA = 4;
    logic clk;
    logic rst;   
    logic enable; 
    logic [31:0] in_1;
    logic [31:0] in_2;
    logic [31:0] out_1;
    logic ready;


    chien #(.PARAM_M(PARAM_M), .PARAM_ALPHA(PARAM_ALPHA)) mul_general_dut
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
       enable = 0;
       in_1 = {16'b0000000101010011, 8'b000000000, 8'b000000001};    // 0x153* 0x153 = 149
       in_2 = {16'b1100000101010011, 8'b000000000, 8'b000000001};
       rst = 0;
       #(`CLK_PERIOD);
       rst = 1;
       #(`CLK_PERIOD*2);
       rst = 0;
       enable = 1;
       #(`CLK_PERIOD*6);
       enable = 0;   
       #(`CLK_PERIOD*20);
       enable = 1;
       #(`CLK_PERIOD*6);
       enable = 0;  
       #(`CLK_PERIOD*20);
       in_1 = {16'b0000000101010011, 8'b000000000, 8'b000000001};    // 0x153* 0x153 = 149
       in_2 = {16'b0100000101010011, 8'b000000000, 8'b000000001};
       enable = 1;
       #(`CLK_PERIOD*6);
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
