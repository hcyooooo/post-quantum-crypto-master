//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: pq_accelerators_ex
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


`include "accelerator_config.sv"

import riscv_defines::*;


module pq_accelerators_ex
(
  input  logic        clk,
  input  logic        rst_n,

  input  logic        enable_i,
  input  logic [PQ_OP_WIDTH-1:0] operator_i,
  input  logic [31:0] op_a_i ,
  input  logic [31:0] op_b_i ,
  input  logic [31:0] op_c_i,
  
  output logic [31:0] result_o,

  output logic        multicycle_o,
  output logic        ready_o,
  input  logic        ex_ready_i
);

    logic [8:0] enable;
    
    `ifdef HW_ACCEL_EX_MULTER
      logic [31:0] result_o_mul_ternary;
      logic ready_mul_ternary;
    `endif

    `ifdef HW_ACCEL_EX_MODBARRETT
      logic [31:0] result_o_mod_barrett;
    `endif

    `ifdef HW_ACCEL_EX_SHA256
      logic [31:0] result_o_sha256;
      logic ready_sha256;
    `endif

    `ifdef HW_ACCEL_EX_GF
      logic [8:0] result_o_gf_mul;
      logic [31:0] result_o_gf_chien;
      logic ready_gf_mul;
      logic ready_gf_chien;
    `endif
    
    `ifdef HW_ACCEL_EX_BINOMSAMPLE
      logic [2:0] mode_binom_sample;
      logic [31:0] result_o_binom_sample;
    `endif
    
    `ifdef HW_ACCEL_EX_MODMULACC
      logic [31:0] result_o_mod_mul_acc;    
    `endif

    // Function selection
    always_comb
    begin
        enable = 0;
        `ifdef HW_ACCEL_EX_BINOMSAMPLE
          mode_binom_sample = 3'b000;
        `endif
        case (operator_i) 
            PQ_MULTER_READ: enable[0] = 1;
            PQ_MULTER_CALC: enable[1] = 1;
            PQ_MULTER_WRITE: enable[2] = 1;
            PQ_MOD_BARRETT: enable[3] = 1;
            PQ_GF_MUL: enable[4] = 1;
            PQ_GF_SYN: enable[5] = 1;
            PQ_SHA256: enable[6] = 1;
            PQ_BINOM_SAMPLE_0: begin
              enable[7] = 1;
              `ifdef HW_ACCEL_EX_BINOMSAMPLE
                mode_binom_sample = 3'b000;
              `endif
            end
            PQ_BINOM_SAMPLE_1: begin
              enable[7] = 1;
              `ifdef HW_ACCEL_EX_BINOMSAMPLE
                mode_binom_sample = 3'b001;
              `endif
            end
            PQ_BINOM_SAMPLE_2: begin
              enable[7] = 1;
              `ifdef HW_ACCEL_EX_BINOMSAMPLE
                mode_binom_sample = 3'b010;
              `endif
            end
            PQ_BINOM_SAMPLE_3: begin
              enable[7] = 1;
              `ifdef HW_ACCEL_EX_BINOMSAMPLE
                mode_binom_sample = 3'b011;
              `endif
            end
            PQ_BINOM_SAMPLE_4: begin
              enable[7] = 1;
              `ifdef HW_ACCEL_EX_BINOMSAMPLE
                mode_binom_sample = 3'b100;
              `endif
            end
            PQ_MOD_MULACC: begin
              enable[8] = 1;
            end                    
            default: begin
              enable = 0;
              `ifdef HW_ACCEL_EX_BINOMSAMPLE
                mode_binom_sample = 3'b000;
              `endif
            end
        endcase
    end
    
    `ifdef HW_ACCEL_EX_MULTER
      `ifdef HW_ACCEL_EX_SHA256
        `ifdef HW_ACCEL_EX_GF
          assign ready_o = ready_mul_ternary & ready_sha256 & ready_gf_mul & ready_gf_chien; // other instances are always ready
        `else
          assign ready_o = ready_mul_ternary & ready_sha256;
        `endif
      `else
         `ifdef HW_ACCEL_EX_GF
           assign ready_o = ready_mul_ternary & ready_gf_mul & ready_gf_chien;
         `else
           assign ready_o = ready_mul_ternary;
         `endif
      `endif
    `else
      `ifdef HW_ACCEL_EX_SHA256
        `ifdef HW_ACCEL_EX_GF
          assign ready_o = ready_sha256 & ready_gf_mul & ready_gf_chien; // other instances are always ready
        `else
          assign ready_o = ready_sha256;
        `endif
      `else
         `ifdef HW_ACCEL_EX_GF
           assign ready_o = ready_gf_mul & ready_gf_chien;
         `else
           assign ready_o = 1;
         `endif
      `endif
    `endif
    
    
    always_comb
    begin
      unique case (enable)
        `ifdef HW_ACCEL_EX_MULTER
          9'b000000010: begin
            result_o = result_o_mul_ternary;
          end
        `endif
        `ifdef HW_ACCEL_EX_MODBARRETT
          9'b000000100:  begin
            result_o = result_o_mod_barrett;
          end
        `endif
        `ifdef HW_ACCEL_EX_GF
          9'b000001000:  begin 
            result_o[31:9] = 0;   
            result_o[9-1:0] = result_o_gf_mul;
          end
          9'b000010000:  begin 
            result_o[31:0] = result_o_gf_chien;
          end
        `endif
        `ifdef HW_ACCEL_EX_SHA256
          9'b001000000:  begin 
            result_o = result_o_sha256;
          end
        `endif
        `ifdef HW_ACCEL_EX_BINOMSAMPLE
          9'b010000000:  begin 
            result_o = result_o_binom_sample;
          end
        `endif
        `ifdef HW_ACCEL_EX_MODMULACC
          9'b100000000:  begin 
            result_o = result_o_mod_mul_acc;
          end
        `endif
        default: begin
          result_o = 0;
        end
      endcase
    end
    
    //// Multiplication Unit GF ////
    `ifdef HW_ACCEL_EX_GF
      parameter PARAM_M = 9;
      parameter PARAM_APLPHA = 4;
      mul_general #(.PARAM_M(PARAM_M), .PARAM_ALPHA(PARAM_APLPHA)) mul_gf_general_i
      (
        .clk(clk),
        .rst(~rst_n),
        .enable(enable[4]),   
        .in_1(op_a_i[PARAM_M-1:0]),
        .in_2(op_b_i[PARAM_M-1:0]),
        .out_1(result_o_gf_mul[PARAM_M-1:0]),
        .ready(ready_gf_mul)
      );

      //// GF Multipliers for Chien Search ////
      chien #(.PARAM_M(PARAM_M), .PARAM_ALPHA(PARAM_APLPHA), .PARAM_MUL_INST(4)) chien_i
      (
        .clk(clk),
        .rst(~rst_n),
        .enable(enable[5]),  
        .in_1(op_a_i),
        .in_2(op_b_i),
        .out_1(result_o_gf_chien),
        .ready(ready_gf_chien)
      );
    `endif

 
    //// Poly Ternary Multiplier ////
    `ifdef HW_ACCEL_EX_MULTER
      mul_ternary_top #(.PARAM_N(512), .PARAM_LOG_N(9), .PARAM_Q(251), .PARAM_LOG_Q(8)) mul_ternary_top_i
      (
        .clk(clk),
        .rst(~rst_n),
        .enable_write(enable[0]),
        .enable_calc(enable[1]),
        .enable_read(enable[2]),
        .in_1(op_a_i),
        .in_2(op_b_i),
        .out_1(result_o_mul_ternary),
        .ready(ready_mul_ternary)
      );
    `endif

    
    //// Modulo Barrett Reduction ////
    `ifdef HW_ACCEL_EX_MODBARRETT
      mod_barrett mod_barrett_i
      (
        .in_1(op_a_i),
        .in_2(op_b_i),
        .out_1(result_o_mod_barrett)
      );
    `endif
    
    //// SHA256 ////
    `ifdef HW_ACCEL_EX_SHA256
      sha256_top sha_top_i
      (
        .clk(clk),
        .rst(~rst_n),
        .enable(enable[6]),
        .in_1(op_a_i),
        .in_2(op_b_i),
        .out_1(result_o_sha256),
        .ready(ready_sha256)
      );
    `endif
    
    //// Binom Sampler ////
    `ifdef HW_ACCEL_EX_BINOMSAMPLE
      binom_sample binom_sample_i
      (
        .in_1(op_a_i),
        .in_2(op_b_i),
        .mode(mode_binom_sample),
        .result(result_o_binom_sample)
      );
    `endif
    
    //// Modulo Multiply Accumulate ////
    `ifdef HW_ACCEL_EX_MODMULACC
      mod_mul_acc mod_mul_acc_i
      (
        .in_1(op_a_i),
        .in_2(op_b_i),
        .in_3(op_c_i),
        .result(result_o_mod_mul_acc)
      );
    `endif
    
       
    assign multicycle_o = ~ready_o;
    
endmodule
