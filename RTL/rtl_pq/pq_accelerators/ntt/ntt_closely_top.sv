//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: ntt_closely_top
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module ntt_closely_top
  #(
    parameter ADDR_WIDTH    = 5,
    parameter DATA_WIDTH    = 32
  )
  (
    // Clock and Reset
    input logic clk,
    input logic rst_n,

    // NTT ports
    input logic [10:0] param_n,
    input logic [DATA_WIDTH/2-1:0] modulus,
    input logic [17:0] param_MinQinvModR,
    input logic fwd_ntt,
    input logic ntt_first_rounds,
    
    input logic ntt_start,
    input logic single_bf,
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
    
    // Signals - PQ Register File 
    output logic [DATA_WIDTH-1:0]   wdata_pq_o [2**(ADDR_WIDTH)-1:0],
    output logic [2**(ADDR_WIDTH)-1:0] we_pq_o,
    input logic [DATA_WIDTH-1:0] rdata_pq_i [2**(ADDR_WIDTH)-1:0]
  );
  
  // Signals - Address Unit
  logic [ADDR_WIDTH-1:0]  raddr1;
  logic [ADDR_WIDTH-1:0]  raddr2;
  logic [ADDR_WIDTH-1:0]  waddr1;
  logic [ADDR_WIDTH-1:0]  waddr2;
  logic [2**(ADDR_WIDTH)-1:0] we;
  logic [2**(ADDR_WIDTH)-1:0] we_pq_reg;
  logic run_loop;
  
  // Signals - Omega Update
  logic update_m;
  logic [3:0] index;
  logic update_omega;
  
  logic update_m_address_unit;
  logic [3:0] index_address_unit;
  logic update_omega_address_unit;
  logic [3:0] index_single_bf_reg;
    
  // Signals - Butterfly
  logic [DATA_WIDTH-1:0] data1_i;
  logic [DATA_WIDTH-1:0] data2_i;
  logic [DATA_WIDTH-1:0] data3_i;  // For re-ordering in last round
  logic [DATA_WIDTH-1:0] data1_i_reg;
  logic [DATA_WIDTH-1:0] data2_i_reg;
  logic [DATA_WIDTH-1:0] data1_o;
  logic [DATA_WIDTH-1:0] data2_o;
  logic [DATA_WIDTH-1:0] data1_o_reg;
  logic [DATA_WIDTH-1:0] data2_o_reg;
  
  logic [DATA_WIDTH/2-1:0] omega;
  logic [DATA_WIDTH/2-1:0] omega_mux_o;
  logic [DATA_WIDTH/2-1:0] omega_prev;
 
  
  // Multiplexer 
  always_ff @(posedge clk, negedge rst_n)
  begin
    if (rst_n == 1'b0) begin
      index_single_bf_reg <= '0;
    end else if (update_m_single_bf == 1'b1) begin
      index_single_bf_reg <= index_single_bf;
    end
  end
  
  assign index = ( run_loop == 1 )? index_address_unit : index_single_bf_reg;
  assign update_m = update_m_address_unit | update_m_single_bf; 
  assign update_omega = update_omega_address_unit | update_omega_single_bf;


  //// ADDRESS UNIT ////
  address_unit_register #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) address_unit_register_inst
  (
    // Clock and Reset
    .clk(clk),
    .rst_n(rst_n),
    
    // NTT related signals
    .ntt_start(ntt_start),
    .single_bf(single_bf),
    .index(index_address_unit),
    .update_m(update_m_address_unit),
    .update_omega(update_omega_address_unit),
    .run_loop_o(run_loop),
    .raddr1_o(raddr1),
    .raddr2_o(raddr2),
    .waddr1_o(waddr1),
    .waddr2_o(waddr2),
    .we_o(we)
  );  

 
  //// OMEGA UPDATE UNIT ////
  omega_update_unit omega_update_unit_inst
  (
    .clk(clk),
    .rst_n(rst_n),
    .param_n(param_n),
    .modulus(modulus),
    .param_MinQinvModR(param_MinQinvModR),    
    .update_m(update_m),
    .index(index),
    .update_omega(update_omega),
    .fwd_ntt(fwd_ntt),
    .omega_o(omega),
    .omega_prev_o(omega_prev)
  );
 
 
  //// BUTTERFLY ////
  butterfly butterfly_inst
  (
    // Clock and Reset
    .clk(clk),
    .rst_n(rst_n),
    .ntt_start(ntt_start),
  
    // Data input
    .data1_i(data1_i),
    .data2_i(data2_i),
    .param_n(param_n),
    .omega(omega_mux_o),
    .omega_prev(omega_prev),
    .modulus(modulus),
    .param_MinQinvModR(param_MinQinvModR),
    .ntt_first_rounds(ntt_first_rounds),
    .fwd_ntt(fwd_ntt),
    
    .mul_psi1(mul_psi1),
    .mul_psi2(mul_psi2),
    .update_psi(update_psi),
    
    .mod_mul(mod_mul | pq_operator_id[0]),
    .mod_add(mod_add | pq_operator_id[1]),
    .mod_sub(mod_sub | pq_operator_id[2]),
    
    .single_bfdif(pq_operator_id[4]),
    
    // Data output
    .data1_o(data1_o),
    .data2_o(data2_o)
  );

  //// Input/Output logic ////
  assign data1_i = ((pq_operator_id[3]|pq_operator_id[4])== 1'b1) ? {alu_operand_b[15:0],alu_operand_a[15:0]} : (pq_en_id == 1'b1) ? alu_operand_a  : rdata_pq_i[raddr1];
  assign data2_i = ((pq_operator_id[3]|pq_operator_id[4])== 1'b1) ? {alu_operand_b[31:16],alu_operand_a[31:16]} : (pq_en_id == 1'b1) ? alu_operand_b : rdata_pq_i[raddr2];
  assign data3_i = rdata_pq_i[2];
  
  //assign we_pq_o = we;
  
  genvar i;
  always_comb
  begin
      wdata_pq_o[0][31:0] = '0;
      wdata_pq_o[1][31:0] = '0;
      wdata_pq_o[2][31:0] = '0;
      wdata_pq_o[3][31:0] = '0;
      wdata_pq_o[4][31:0] = '0;
      wdata_pq_o[5][31:0] = '0;
      wdata_pq_o[6][31:0] = '0;
      wdata_pq_o[7][31:0] = '0;
      wdata_pq_o[8][31:0] = '0;
      wdata_pq_o[9][31:0] = '0;
      wdata_pq_o[10][31:0] = '0;
      wdata_pq_o[11][31:0] = '0;
      wdata_pq_o[12][31:0] = '0;
      wdata_pq_o[13][31:0] = '0;
      wdata_pq_o[14][31:0] = '0;
      wdata_pq_o[15][31:0] = '0;
      wdata_pq_o[16][31:0] = '0;
      wdata_pq_o[17][31:0] = '0;
      wdata_pq_o[18][31:0] = '0;
      wdata_pq_o[19][31:0] = '0;
      wdata_pq_o[20][31:0] = '0;
      wdata_pq_o[21][31:0] = '0;
      wdata_pq_o[22][31:0] = '0;
      wdata_pq_o[23][31:0] = '0;
      wdata_pq_o[24][31:0] = '0;
      wdata_pq_o[25][31:0] = '0;
      wdata_pq_o[26][31:0] = '0;
      wdata_pq_o[27][31:0] = '0;
      wdata_pq_o[28][31:0] = '0;
      wdata_pq_o[29][31:0] = '0;
      wdata_pq_o[30][31:0] = '0;
      wdata_pq_o[31][31:0] = '0;                                           
      wdata_pq_o[waddr1][31:0] = data1_o;
      wdata_pq_o[waddr2][31:0] = data2_o;
      if ((mul_psi1 == 1'b1) || (update_psi == 1'b1)) begin
        we_pq_o = '0;
      end else begin
        we_pq_o = we;
      end
  end
  
  //// Modular Arithmetic Unit register operations ////
  assign pq_id_alu_we1 = (pq_en_id == 1'b1) ? 1'b1 : 1'b0;
  assign pq_id_alu_we2 = ((pq_en_id == 1'b1) && ((pq_operator_id[3] | pq_operator_id[4]) == 1'b1)) ? 1'b1 : 1'b0;
  assign omega_mux_o = (pq_en_id == 1'b1) ? alu_operand_c[DATA_WIDTH/2-1:0] : omega;
  assign pq_id_alu_res1 = data1_o;
  assign pq_id_alu_res2 = data2_o;
endmodule
