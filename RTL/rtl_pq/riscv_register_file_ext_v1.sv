// Modifications of original source by Tim Fritzmann (Technical University of Munich, tim.fritzmann@tum.de)

// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Engineer:       Francesco Conti - f.conti@unibo.it                         //
//                                                                            //
// Additional contributions by:                                               //
//                 Michael Gautschi - gautschi@iis.ee.ethz.ch                 //
//                                                                            //
// Design Name:    RISC-V register file                                       //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Register file with 31x 32 bit wide registers. Register 0   //
//                 is fixed to 0. This register file is based on flip-flops.  //
//                 Also supports the fp-register file now if FPU=1            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "accelerator_config.sv"

module riscv_register_file
#(
    parameter ADDR_WIDTH    = 5,
    parameter DATA_WIDTH    = 32,
    parameter FPU           = 0
)
(
    // Clock and Reset
    input  logic         clk,
    input  logic         rst_n,

    input  logic                   test_en_i,

    //Read port R1
    input  logic [ADDR_WIDTH-1:0]  raddr_a_i,
    output logic [DATA_WIDTH-1:0]  rdata_a_o,

    //Read port R2
    input  logic [ADDR_WIDTH-1:0]  raddr_b_i,
    output logic [DATA_WIDTH-1:0]  rdata_b_o,

    //Read port R3
    input  logic [ADDR_WIDTH-1:0]  raddr_c_i,
    output logic [DATA_WIDTH-1:0]  rdata_c_o,

    // Write port W1
    input logic [ADDR_WIDTH-1:0]   waddr_a_i,
    input logic [DATA_WIDTH-1:0]   wdata_a_i,
    input logic                    we_a_i,

    // Write port W2
    input logic [ADDR_WIDTH-1:0]   waddr_b_i,
    input logic [DATA_WIDTH-1:0]   wdata_b_i,
    `ifdef HW_ACCEL_ID
      input logic                    we_b_i,
    `else
      input logic                    we_b_i
    `endif
    
    // PQ ports
    `ifdef HW_ACCEL_ID
      input logic [DATA_WIDTH-1:0]   wdata_pq_i [31:0],
      input logic [31:0] we_pq_i,
      output logic [DATA_WIDTH-1:0] rdata_pq_o [31:0],
    
      input logic [DATA_WIDTH-1:0]   wdata_pq_gp_i [17:0],
      input logic [17:0] we_pq_gp_i,
      output logic [DATA_WIDTH-1:0] rdata_pq_gp_o [17:0]
    `endif
);

  // number of integer registers
  localparam    NUM_WORDS     = 2**(ADDR_WIDTH-1);
  // number of floating point registers
  localparam    NUM_FP_WORDS  = 2**(ADDR_WIDTH-1);
  localparam    NUM_TOT_WORDS = FPU ? NUM_WORDS + NUM_FP_WORDS : NUM_WORDS;

  // integer register file
  logic [NUM_WORDS-1:0][DATA_WIDTH-1:0]     mem;

  // fp register file
  logic [NUM_FP_WORDS-1:0][DATA_WIDTH-1:0]  mem_fp;

  // write enable signals for all registers
  logic [NUM_TOT_WORDS-1:0]                 we_a_dec;
  logic [NUM_TOT_WORDS-1:0]                 we_b_dec;
  
  `ifdef HW_ACCEL_ID
    logic [DATA_WIDTH-1:0]   wdata_pq_gp [31:0];
    logic [31:0] we_pq_gp;
  
    assign wdata_pq_gp[0] = '0;
    assign wdata_pq_gp[1] = '0;
    assign wdata_pq_gp[2] = '0;
    assign wdata_pq_gp[3] = '0;
    assign wdata_pq_gp[4] = '0;
    assign wdata_pq_gp[5] = wdata_pq_gp_i[0];
    assign wdata_pq_gp[6] = wdata_pq_gp_i[1];
    assign wdata_pq_gp[7] = wdata_pq_gp_i[2];
    assign wdata_pq_gp[8] = '0;
    assign wdata_pq_gp[9] = wdata_pq_gp_i[3];
    assign wdata_pq_gp[10] = '0;
    assign wdata_pq_gp[11] = '0;
    assign wdata_pq_gp[12] = '0;
    assign wdata_pq_gp[13] = '0;
    assign wdata_pq_gp[14] = '0;
    assign wdata_pq_gp[15] = '0;
    assign wdata_pq_gp[16] = '0;
    assign wdata_pq_gp[17] = '0;
    assign wdata_pq_gp[18] = wdata_pq_gp_i[4];
    assign wdata_pq_gp[19] = wdata_pq_gp_i[5];
    assign wdata_pq_gp[20] = wdata_pq_gp_i[6];
    assign wdata_pq_gp[21] = wdata_pq_gp_i[7];
    assign wdata_pq_gp[22] = wdata_pq_gp_i[8];
    assign wdata_pq_gp[23] = wdata_pq_gp_i[9];
    assign wdata_pq_gp[24] = wdata_pq_gp_i[10];
    assign wdata_pq_gp[25] = wdata_pq_gp_i[11];
    assign wdata_pq_gp[26] = wdata_pq_gp_i[12];
    assign wdata_pq_gp[27] = wdata_pq_gp_i[13];
    assign wdata_pq_gp[28] = wdata_pq_gp_i[14];
    assign wdata_pq_gp[29] = wdata_pq_gp_i[15];
    assign wdata_pq_gp[30] = wdata_pq_gp_i[16];
    assign wdata_pq_gp[31] = wdata_pq_gp_i[17];

    assign we_pq_gp[0] = '0;
    assign we_pq_gp[1] = '0;
    assign we_pq_gp[2] = '0;
    assign we_pq_gp[3] = '0;
    assign we_pq_gp[4] = '0;
    assign we_pq_gp[5] = we_pq_gp_i[0];
    assign we_pq_gp[6] = we_pq_gp_i[1];
    assign we_pq_gp[7] = we_pq_gp_i[2];
    assign we_pq_gp[8] = '0;
    assign we_pq_gp[9] = we_pq_gp_i[3];
    assign we_pq_gp[10] = '0;
    assign we_pq_gp[11] = '0;
    assign we_pq_gp[12] = '0;
    assign we_pq_gp[13] = '0;
    assign we_pq_gp[14] = '0;
    assign we_pq_gp[15] = '0;
    assign we_pq_gp[16] = '0;
    assign we_pq_gp[17] = '0;
    assign we_pq_gp[18] = we_pq_gp_i[4];
    assign we_pq_gp[19] = we_pq_gp_i[5];
    assign we_pq_gp[20] = we_pq_gp_i[6];
    assign we_pq_gp[21] = we_pq_gp_i[7];
    assign we_pq_gp[22] = we_pq_gp_i[8];
    assign we_pq_gp[23] = we_pq_gp_i[9];
    assign we_pq_gp[24] = we_pq_gp_i[10];
    assign we_pq_gp[25] = we_pq_gp_i[11];
    assign we_pq_gp[26] = we_pq_gp_i[12];
    assign we_pq_gp[27] = we_pq_gp_i[13];
    assign we_pq_gp[28] = we_pq_gp_i[14];
    assign we_pq_gp[29] = we_pq_gp_i[15];
    assign we_pq_gp[30] = we_pq_gp_i[16];
    assign we_pq_gp[31] = we_pq_gp_i[17];
  `endif
  
   //-----------------------------------------------------------------------------
   //-- READ : Read address decoder RAD
   //-----------------------------------------------------------------------------
   if (FPU == 1) begin
      assign rdata_a_o = raddr_a_i[5] ? mem_fp[raddr_a_i[4:0]] : mem[raddr_a_i[4:0]];
      assign rdata_b_o = raddr_b_i[5] ? mem_fp[raddr_b_i[4:0]] : mem[raddr_b_i[4:0]];
      assign rdata_c_o = raddr_c_i[5] ? mem_fp[raddr_c_i[4:0]] : mem[raddr_c_i[4:0]];
   end else begin
      assign rdata_a_o = mem[raddr_a_i[4:0]];
      assign rdata_b_o = mem[raddr_b_i[4:0]];
      assign rdata_c_o = mem[raddr_c_i[4:0]];
   end
   
  //-----------------------------------------------------------------------------
  //-- WRITE : Write Address Decoder (WAD), combinatorial process
  //-----------------------------------------------------------------------------
  always_comb
  begin : we_a_decoder
    for (int i = 0; i < NUM_TOT_WORDS; i++) begin
      if (waddr_a_i == i)
        we_a_dec[i] = we_a_i;
      else
        we_a_dec[i] = 1'b0;
    end
  end

  always_comb
  begin : we_b_decoder
    for (int i=0; i<NUM_TOT_WORDS; i++) begin
      if (waddr_b_i == i)
        we_b_dec[i] = we_b_i;
      else
        we_b_dec[i] = 1'b0;
    end
  end

  genvar i,l;
  generate

   //-----------------------------------------------------------------------------
   //-- WRITE : Write operation
   //-----------------------------------------------------------------------------
   
   
    always_ff @(posedge clk or negedge rst_n) begin
      if(~rst_n) begin
        // R0 is nil
        mem[0] <= 32'b0;
      end else begin
        // R0 is nil
        mem[0] <= 32'b0;
      end
    end

    // R0 is nil
    // loop from 1 to NUM_WORDS-1 as R0 is nil
    for (i = 1; i < NUM_WORDS; i++)
    begin : rf_gen

      always_ff @(posedge clk, negedge rst_n)
      begin : register_write_behavioral
        if (rst_n==1'b0) begin
          mem[i] <= 32'b0;
        end else begin
          if(we_b_dec[i] == 1'b1)
            mem[i] <= wdata_b_i;
          else if(we_a_dec[i] == 1'b1)
            mem[i] <= wdata_a_i;
          `ifdef HW_ACCEL_ID
            else if(we_pq_gp[i] == 1'b1)
              mem[i] <= wdata_pq_gp[i];
          `endif  
        end
      end

    end
    
     if (FPU == 1) begin
        // Floating point registers 
        for(l = 0; l < NUM_FP_WORDS; l++) begin
           always_ff @(posedge clk, negedge rst_n)
             begin : fp_regs
                if (rst_n==1'b0)
                  mem_fp[l] <= '0;
                else if(we_b_dec[l+NUM_WORDS] == 1'b1)
                  mem_fp[l] <= wdata_b_i;
                else if(we_a_dec[l+NUM_WORDS] == 1'b1)
                  mem_fp[l] <= wdata_a_i;
                `ifdef HW_ACCEL_ID
                  else if(we_pq_i[l] == 1'b1)
                    mem_fp[l] <= wdata_pq_i[l];
                `endif
             end
        end
     end
  endgenerate
  
  // PQ Read
  `ifdef HW_ACCEL_ID
    genvar j;
    generate
      for (j = 0; j < NUM_WORDS; j++)
      begin
        assign rdata_pq_o[j] = mem_fp[j];
      end
    endgenerate
  
    assign rdata_pq_gp_o[0] = mem[5];
    assign rdata_pq_gp_o[1] = mem[6];
    assign rdata_pq_gp_o[2] = mem[7];
    assign rdata_pq_gp_o[3] = mem[9];
    assign rdata_pq_gp_o[4] = mem[18];
    assign rdata_pq_gp_o[5] = mem[19];
    assign rdata_pq_gp_o[6] = mem[20];
    assign rdata_pq_gp_o[7] = mem[21];
    assign rdata_pq_gp_o[8] = mem[22];
    assign rdata_pq_gp_o[9] = mem[23];
    assign rdata_pq_gp_o[10] = mem[24];
    assign rdata_pq_gp_o[11] = mem[25];
    assign rdata_pq_gp_o[12] = mem[26];
    assign rdata_pq_gp_o[13] = mem[27];
    assign rdata_pq_gp_o[14] = mem[28];
    assign rdata_pq_gp_o[15] = mem[29];
    assign rdata_pq_gp_o[16] = mem[30];
    assign rdata_pq_gp_o[17] = mem[31];
  `endif

endmodule
