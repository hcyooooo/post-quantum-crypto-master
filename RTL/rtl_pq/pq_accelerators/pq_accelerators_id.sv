//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: pq_accelerators_id
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////

`include "accelerator_config.sv"

module pq_accelerators_id
  #(
    parameter ADDR_WIDTH    = 6,
    parameter DATA_WIDTH    = 32
  )
  (
    // Clock and Reset
    input logic clk,
    input logic rst_n,
    
    `ifdef HW_ACCEL_ID_NTT
      // NTT configuration
      input logic set_n_256,
      input logic set_n_512,
      input logic set_n_1024,
      input logic set_fwd_ntt,
      input logic set_inv_ntt,
      input logic set_ntt_first_rounds,
      input logic set_ntt_last_round,
    
      // NTT operations
      input logic ntt_multiple_bf,
      input logic ntt_single_bf,
      input logic update_m_single_bf,
      input logic [3:0] index_single_bf,
      input logic update_omega_single_bf,
      input logic mul_psi1,
      input logic mul_psi2,
      input logic update_psi,
      input logic mod_mul,
      input logic mod_add,
      input logic mod_sub,
      
      // Modular Arithmetic Unit register operations
      input logic pq_en_id,
      input logic [4:0] pq_operator_id,
      input logic [31:0] alu_operand_a,
      input logic [31:0] alu_operand_b,
      input logic [31:0] alu_operand_c, 
      output logic [31:0] pq_id_alu_res1,
      output logic [31:0] pq_id_alu_res2,
      output logic pq_id_alu_we1,
      output logic pq_id_alu_we2,
    `endif
    
    `ifdef HW_ACCEL_ID_KECCAK
      // Keccak operations
      input logic keccak_f_start,
      input logic [4:0] keccak_round,
      input logic keccak_rst,
    `endif
        
    // PQ register file 
    output logic [DATA_WIDTH-1:0] wdata_pq_o [31:0],
    output logic [2**(ADDR_WIDTH-1)-1:0] we_pq_o,
    input logic [DATA_WIDTH-1:0] rdata_pq_i [31:0],

    output logic [DATA_WIDTH-1:0] wdata_pq_gp_o [17:0],
    output logic [17:0] we_pq_gp_o,
    input logic [DATA_WIDTH-1:0] rdata_pq_gp_i [17:0]   
  );

  `ifdef HW_ACCEL_ID_NTT
    // NTT signals
    logic [10:0] param_n;
    logic [DATA_WIDTH/2-1:0] modulus;
    logic [17:0] param_MinQinvModR;  
    logic fwd_ntt_reg;
    logic ntt_first_rounds_reg;
    logic [DATA_WIDTH-1:0] wdata_pq_ntt [31:0];
    logic [2**(ADDR_WIDTH-1)-1:0] we_pq_ntt;
  `endif
  
  `ifdef HW_ACCEL_ID_KECCAK
    // Keccak signals
    logic [DATA_WIDTH-1:0] input_state [49:0];
    logic [DATA_WIDTH-1:0] output_state [49:0];
  `endif

  `ifdef HW_ACCEL_ID_NTT
    ////////////////////////////////////////
    ////             NTT               /////
    ////////////////////////////////////////
  
    // Set NTT signals
    always_ff @(posedge clk, negedge rst_n)
    begin
      if (rst_n == 1'b0) begin
        ntt_first_rounds_reg <= 1'b1;
      end else if (set_ntt_first_rounds == 1'b1) begin
        ntt_first_rounds_reg <= 1'b1;
      end else if (set_ntt_last_round == 1'b1) begin
        ntt_first_rounds_reg <= 1'b0;
      end
    end
  
    always_ff @(posedge clk, negedge rst_n)
    begin
      if (rst_n == 1'b0) begin
        fwd_ntt_reg <= 1'b1;
      end else if (set_fwd_ntt == 1'b1) begin
        fwd_ntt_reg <= 1'b1;
      end else if (set_inv_ntt == 1'b1) begin
        fwd_ntt_reg <= 1'b0;
      end
    end
  
    always_ff @(posedge clk, negedge rst_n)
    begin
      if (rst_n == 1'b0) begin
        param_n <= 11'h100;
        modulus <= 16'h1e01;
        param_MinQinvModR <= 18'h1dff;
      end else if (set_n_256 == 1'b1) begin
        param_n <= 11'h100;
        modulus <= 16'h0d01;
        param_MinQinvModR <= 18'h30CFF;
      end else if (set_n_512 == 1'b1) begin
        param_n <= 11'h200;
        modulus <= 16'h3001;
        param_MinQinvModR <= 18'h2fff;
      end else if (set_n_1024 == 1'b1) begin
        param_n <= 11'h400;
        modulus <= 16'h3001;
        param_MinQinvModR <= 18'h2fff;
      end
    end
  
    // NTT Module instantiation
    ntt_closely_top ntt_closely_top_i
    ( 
      // Clock and Reset
      .clk(clk),
      .rst_n(rst_n),

      // NTT configuration
      .param_n(param_n),
      .modulus(modulus),
      .param_MinQinvModR(param_MinQinvModR),
      .fwd_ntt(fwd_ntt_reg),
      .ntt_first_rounds(ntt_first_rounds_reg),
  
      // NTT operations
      .ntt_start(ntt_multiple_bf),
      .single_bf(ntt_single_bf),
      .update_m_single_bf(update_m_single_bf),
      .index_single_bf(index_single_bf),
      .update_omega_single_bf(update_omega_single_bf),
      .mul_psi1(mul_psi1),
      .mul_psi2(mul_psi2),
      .update_psi(update_psi),
      .mod_mul(mod_mul),
      .mod_add(mod_add),
      .mod_sub(mod_sub),

      // Modular Arithmetic Unit register operations
      .pq_en_id(pq_en_id),
      .pq_operator_id(pq_operator_id),
      .alu_operand_a(alu_operand_a),
      .alu_operand_b(alu_operand_b),
      .alu_operand_c(alu_operand_c),
      .pq_id_alu_res1(pq_id_alu_res1),
      .pq_id_alu_res2(pq_id_alu_res2),
      .pq_id_alu_we1(pq_id_alu_we1),
      .pq_id_alu_we2(pq_id_alu_we2),

      // PQ register file 
      .wdata_pq_o(wdata_pq_ntt),
      .we_pq_o(we_pq_ntt),
      .rdata_pq_i(rdata_pq_i)
    );
  `endif
  
  `ifdef HW_ACCEL_ID_KECCAK
    ////////////////////////////////////////
    ////           Keccak              /////
    ////////////////////////////////////////
  
    assign input_state = {rdata_pq_gp_i,rdata_pq_i};
  
    keccak_top keccak_top_i 
    (
      .input_state(input_state),
      .round(keccak_round),
      .rst(keccak_rst),
      .output_state(output_state)
    );
  `endif

  
  // Output logic
  `ifdef HW_ACCEL_ID_KECCAK
    `ifdef HW_ACCEL_ID_NTT
      assign wdata_pq_o = (keccak_f_start == 1'b1) ? output_state[31:0] : wdata_pq_ntt;
      assign we_pq_o = (keccak_f_start == 1'b1) ? 32'hffffffff : we_pq_ntt;
    `else
      assign wdata_pq_o = output_state[31:0];
      assign we_pq_o = (keccak_f_start == 1'b1) ? 32'hffffffff : 32'h00000000;    
    `endif  
    assign wdata_pq_gp_o = output_state[49:32];
    assign we_pq_gp_o = (keccak_f_start == 1'b1) ? 18'h3ffff : 18'h00000;
  `elsif HW_ACCEL_ID_NTT
    assign wdata_pq_o = wdata_pq_ntt;
    assign we_pq_o = we_pq_ntt; 
    assign wdata_pq_gp_o = {32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0};
    assign we_pq_gp_o = 18'h00000;
  `endif
endmodule
