//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: address_unit_register
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module address_unit_register
#(
  parameter ADDR_WIDTH = 6,
  parameter DATA_WIDTH = 32
)
(
  // Clock and Reset
  input logic clk,
  input logic rst_n,
  input logic ntt_start,
  input logic single_bf,
  output logic [3:0] index,
  output logic update_m,
  output logic update_omega,
  output logic run_loop_o,
  output logic [ADDR_WIDTH-1:0] raddr1_o,
  output logic [ADDR_WIDTH-1:0] raddr2_o,
  output logic [ADDR_WIDTH-1:0] waddr1_o,
  output logic [ADDR_WIDTH-1:0] waddr2_o,
  output logic [2**(ADDR_WIDTH-1)-1:0] we_o
);

localparam PARAM_LOG_MAX_N_HALF = 10;

logic [3:0] index_int;
logic [PARAM_LOG_MAX_N_HALF - 1:0] j;
logic [PARAM_LOG_MAX_N_HALF - 1:0] k;
logic [PARAM_LOG_MAX_N_HALF:0] m;
logic [PARAM_LOG_MAX_N_HALF - 1:0] j_reg;
logic [PARAM_LOG_MAX_N_HALF - 1:0] k_reg;
logic [PARAM_LOG_MAX_N_HALF:0] m_reg;

logic run_loop;

assign run_loop_o = run_loop;

//// Finite State Machine ////
enum logic [1:0] {IDLE, CONF, RND} state, next_state;

// Next state logic
always_comb
begin
  case(state)
    IDLE: 
      if (ntt_start == 1'b1)
        next_state = CONF;
      else 
        next_state = IDLE;
    CONF:
      next_state = RND;
    RND:
      if ((m == 32) &&  (j == 15))
        next_state = IDLE;
      else
        next_state = RND;        
    default : next_state = IDLE;
   endcase
end

always_ff @(posedge clk, negedge rst_n)
begin
  if (rst_n == 1'b0)
    state <= IDLE;
  else
    state <=  next_state;
end

always_ff @(posedge clk, negedge rst_n)
begin
  if (rst_n == 1'b0)
    run_loop <= 1'b0;
  else if ((state == RND))
      run_loop <= 1'b1;
  else
    run_loop <= 1'b0;
end


//// Address access counter ////
always_ff @(posedge clk, negedge rst_n)
begin
  if (rst_n == 1'b0) begin
    m <= 2;
    j <= 0;  
    k <= 0;
    index_int <= 0;
    update_omega <= 0;
    update_m <= 0;
  end else if (state == IDLE) begin
    m <= 2;
    j <= 0;  
    k <= 0;
    index_int <= 0;
    update_omega <= 0;
    update_m <= 0;
  end else if (state == CONF) begin
      m <= 2;
      j <= 0;  
      k <= 0;
      index_int <= 0;
      update_omega <= 0;
      update_m <= 1;
  end else begin
    update_m <= 0;
    if (k < 32 - m) begin
      k <= k + m;
      update_omega <= 0;
    end else begin
      k <= 0;
      if (j < (m>>1) - 1) begin
        j <= j + 1;
        update_omega <= 1'b1;
      end else begin
        j <= 0;
        update_omega <= 0;
        if (m < 32) begin
          m <= m << 1;
          update_m <= 1;
          index_int <= index_int + 1;
          update_omega <= 1;
        end
      end
    end
  end
end

// Registers to delay signals one cycle because update omega requires one cycle to update
always_ff @(posedge clk, negedge rst_n)
begin
  if (rst_n == 1'b0) begin
    m_reg <= 2;
    j_reg <= 0;  
    k_reg <= 0;
  end else begin   
    m_reg <= m;
    j_reg <= j;
    k_reg <= k;
  end
end


//// Output logic ////
assign raddr1_o = k_reg + j_reg;
assign raddr2_o = k_reg + j_reg + (m_reg >> 1);
assign index = index_int;

always_comb
begin
  if (rst_n == 1'b0) begin
    waddr1_o = 0;
    waddr2_o = 0;
    we_o = 0;
  end else if (run_loop == 1'b1 || single_bf == 1'b1) begin
    waddr1_o = k_reg + j_reg;
    waddr2_o = k_reg + j_reg + (m_reg >> 1);
    we_o = 0;
    we_o[k_reg + j_reg] = 1'b1;
    we_o[k_reg + j_reg + (m_reg >> 1)] = 1'b1;       
  end else begin
    waddr1_o = 0;
    waddr2_o = 1;
    we_o = 0;     
  end
end

endmodule
