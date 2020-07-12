`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: address_unit_register_tb
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


`define REF_CLK_PERIOD   (2*15.25us)  // 32.786 kHz --> FLL reset value --> 50 MHz
`define CLK_PERIOD       40.00ns      // 25 MHz

module address_unit_register_tb;
  localparam ADDR_WIDTH = 6;

  logic clk;
  logic rst;
  logic ntt_start;
  logic [16:0] param_n;
  
  logic [16:0] raddr1_o;
  logic [16:0] raddr2_o;
  logic [16:0] waddr1_o;
  logic [16:0] waddr2_o;
  logic [2**(ADDR_WIDTH-1)-1:0] we_o;
  
  address_unit_register 
  #(
    .ADDR_WIDTH(6),
    .DATA_WIDTH(32)
  )
  address_unit_register_inst
  (
    // Clock and Reset
    .clk(clk),
    .rst_n(~rst),
    .ntt_start(ntt_start),
    .param_n(param_n),
    .raddr1_o,
    .raddr2_o,
    .waddr1_o,
    .waddr2_o,
    .we_o
  );
  
  
  
  initial
  begin
    #(`CLK_PERIOD/2);
    clk = 1'b1;
    forever clk = #(`CLK_PERIOD/2) ~clk;
  end
  
  initial
  begin
    // Initialization
    rst = 0;
    #(`CLK_PERIOD/2);
    param_n = 256;
    rst = 1;
    #80;
    rst = 0;
    ntt_start = 1;   
    #800;
  end
endmodule
