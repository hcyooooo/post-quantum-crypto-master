`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: ntt_closely_top_tb
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


`define REF_CLK_PERIOD   (2*15.25us)  // 32.786 kHz --> FLL reset value --> 50 MHz
`define CLK_PERIOD       40.00ns      // 25 MHz

module ntt_closely_top_tb;
  logic clk;
  logic rst;
  logic ntt_start;
  logic param_n = 256;
  
  localparam ADDR_WIDTH = 6;
  localparam DATA_WIDTH = 32;
  
  logic [DATA_WIDTH-1:0]   wdata_pq [2**(ADDR_WIDTH-1)-1:0];
  logic [2**(ADDR_WIDTH-1)-1:0] we_pq;
  logic [DATA_WIDTH-1:0] mem_fp [2**(ADDR_WIDTH-1)-1:0];
  
  // Clock and Reset
  ntt_closely_top ntt_closely_top_inst
  (
    .clk(clk),
    .rst_n(~rst),

    .ntt_start(ntt_start),
    .param_n(param_n),
    
    // Signals - PQ Register File 
    .wdata_pq_o(wdata_pq),
    .we_pq_o(we_pq),
    .rdata_pq_i(mem_fp)
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
    rst = 1;
    #80;
    rst = 0;
    ntt_start = 1;   
    #800;
  end
  

  // Floating point registers 
  genvar l;
  generate
    for(l = 0; l < 32; l++) begin
      always_ff @(posedge clk, posedge rst)
        begin : fp_regs
          if (rst==1'b1) begin
            mem_fp[l][15:0] <= 2*l;
            mem_fp[l][31:16] <= 2*l+1;
          end else if(we_pq[l] == 1'b1)
            mem_fp[l] <= wdata_pq[l];
          else if(we_pq[l] == 1'b1)
            mem_fp[l] <= wdata_pq[l];
          else if(we_pq[l] == 1'b1)
            mem_fp[l] <= wdata_pq[l];
          end
      end
  endgenerate
endmodule
