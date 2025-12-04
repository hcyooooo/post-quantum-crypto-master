//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich (original NTT core)
// Engineer: GitHub Copilot (bus wrapper)
//
// Create Date: 12/01/2025
// Module Name: apb_ntt_if
// Project Name: Post-Quantum Cryptography
// Description: APB3 slave that exposes a loosely-coupled interface to the
//              ntt_closely_top accelerator. The block provides a small
//              register map for configuration/commands plus a 32-word data
//              window that mirrors the internal PQ register file expected by
//              the NTT core.
//////////////////////////////////////////////////////////////////////////////////

`define REG_CMD        12'h000
`define REG_CONFIG     12'h004
`define REG_PARAM_N    12'h008
`define REG_MODULUS    12'h00C
`define REG_MIN_QINV   12'h010
`define REG_SINGLE_IDX 12'h014
`define REG_PQ_OP      12'h018
`define REG_ALU_CTRL   12'h01C
`define REG_OP_A       12'h020
`define REG_OP_B       12'h024
`define REG_OP_C       12'h028
`define REG_RESULT1    12'h02C
`define REG_RESULT2    12'h030
`define REG_STATUS     12'h034
`define REG_IRQ_MASK   12'h038
`define REG_RF_BASE    12'h100
`define REG_RF_LAST    (`REG_RF_BASE + (1 << ADDR_WIDTH) * 4)

module apb_ntt_if
  #(
    parameter int unsigned APB_ADDR_WIDTH = 12,
    parameter int unsigned ADDR_WIDTH     = 5,
    parameter int unsigned DATA_WIDTH     = 32
  )
  (
    // APB3 slave interface
    input  logic                      CLK,
    input  logic                      RSTN,
    input  logic [APB_ADDR_WIDTH-1:0] PADDR,
    input  logic               [31:0] PWDATA,
    input  logic                      PWRITE,
    input  logic                      PSEL,
    input  logic                      PENABLE,
    output logic               [31:0] PRDATA,
    output logic                      PREADY,
    output logic                      PSLVERR,

    // Optional interrupt when results become available
    output logic                      IRQ
  );

  localparam int unsigned RF_DEPTH = 2 ** ADDR_WIDTH;

  // APB decoding
  logic apb_access;
  logic apb_write;
  logic apb_read;
  logic [APB_ADDR_WIDTH-1:0] addr_aligned;
  logic cmd_sel, cfg_sel, param_sel, modulus_sel, min_sel;
  logic idx_sel, pq_op_sel, alu_ctrl_sel, opa_sel, opb_sel, opc_sel;
  logic res1_sel, res2_sel, status_sel, irq_mask_sel;
  logic rf_sel;
  logic [ADDR_WIDTH-1:0] rf_index;

  assign apb_access = PSEL & PENABLE;
  assign apb_write  = apb_access & PWRITE;
  assign apb_read   = apb_access & (~PWRITE);
  assign addr_aligned = {PADDR[APB_ADDR_WIDTH-1:2], 2'b00};

  assign cmd_sel      = (addr_aligned == `REG_CMD);
  assign cfg_sel      = (addr_aligned == `REG_CONFIG);
  assign param_sel    = (addr_aligned == `REG_PARAM_N);
  assign modulus_sel  = (addr_aligned == `REG_MODULUS);
  assign min_sel      = (addr_aligned == `REG_MIN_QINV);
  assign idx_sel      = (addr_aligned == `REG_SINGLE_IDX);
  assign pq_op_sel    = (addr_aligned == `REG_PQ_OP);
  assign alu_ctrl_sel = (addr_aligned == `REG_ALU_CTRL);
  assign opa_sel      = (addr_aligned == `REG_OP_A);
  assign opb_sel      = (addr_aligned == `REG_OP_B);
  assign opc_sel      = (addr_aligned == `REG_OP_C);
  assign res1_sel     = (addr_aligned == `REG_RESULT1);
  assign res2_sel     = (addr_aligned == `REG_RESULT2);
  assign status_sel   = (addr_aligned == `REG_STATUS);
  assign irq_mask_sel = (addr_aligned == `REG_IRQ_MASK);

  assign rf_sel = (addr_aligned >= `REG_RF_BASE) && (addr_aligned < `REG_RF_LAST);
  assign rf_index = (addr_aligned - `REG_RF_BASE) >> 2;

  // Register storage
  logic [10:0] param_n_reg;
  logic [DATA_WIDTH/2-1:0] modulus_reg;
  logic [17:0] min_qinv_reg;
  logic fwd_ntt_reg;
  logic ntt_first_rounds_reg;
  logic [3:0] single_idx_reg;
  logic [4:0] pq_operator_reg;
  logic [31:0] operand_a_reg;
  logic [31:0] operand_b_reg;
  logic [31:0] operand_c_reg;
  logic [31:0] result1_reg;
  logic [31:0] result2_reg;
  logic result1_valid;
  logic result2_valid;
  logic busy_flag;
  logic rf_conflict_flag;
  logic [1:0] irq_mask_reg;
  logic [31:0] pq_id_alu_res1;
  logic [31:0] pq_id_alu_res2;
  logic        pq_id_alu_we1;
  logic        pq_id_alu_we2;

  // PQ register file mirrored memory
  logic [DATA_WIDTH-1:0] pq_mem   [RF_DEPTH-1:0];
  logic [DATA_WIDTH-1:0] pq_wdata [RF_DEPTH-1:0];
  logic [RF_DEPTH-1:0]   pq_we;

  // Command pulses
  typedef struct packed {
    logic start_multi;
    logic single_bf;
    logic update_m_single;
    logic update_omega_single;
    logic mul_psi1;
    logic mul_psi2;
    logic update_psi;
    logic mod_mul;
    logic mod_add;
    logic mod_sub;
  } cmd_bus_t;

  cmd_bus_t cmd_pulse;
  logic     pq_en_id_pulse;

  // Status helpers
  logic ntt_rf_write_active;
  assign ntt_rf_write_active = |pq_we;

  // IRQ output: bit0 -> result1 valid, bit1 -> result2 valid
  assign IRQ = (irq_mask_reg[0] & result1_valid) |
               (irq_mask_reg[1] & result2_valid);

  /////////////////
  // APB ready
  /////////////////
  logic stall_rf_write;
  assign stall_rf_write = rf_sel & apb_write & ntt_rf_write_active;
  assign PREADY  = ~stall_rf_write;
  assign PSLVERR = 1'b0;

  /////////////////
  // Register writes
  /////////////////
  logic cmd_write      = apb_write & cmd_sel      & PREADY;
  logic cfg_write      = apb_write & cfg_sel      & PREADY;
  logic param_write    = apb_write & param_sel    & PREADY;
  logic modulus_write  = apb_write & modulus_sel  & PREADY;
  logic min_write      = apb_write & min_sel      & PREADY;
  logic idx_write      = apb_write & idx_sel      & PREADY;
  logic pq_op_write    = apb_write & pq_op_sel    & PREADY;
  logic alu_ctrl_write = apb_write & alu_ctrl_sel & PREADY;
  logic opa_write      = apb_write & opa_sel      & PREADY;
  logic opb_write      = apb_write & opb_sel      & PREADY;
  logic opc_write      = apb_write & opc_sel      & PREADY;
  logic status_write   = apb_write & status_sel   & PREADY;
  logic irq_mask_write = apb_write & irq_mask_sel & PREADY;
  logic rf_write       = apb_write & rf_sel       & PREADY;

  // Default register resets
  always_ff @(posedge CLK, negedge RSTN)
  begin
    if (!RSTN) begin
      param_n_reg          <= 11'h100;
      modulus_reg          <= 16'h0d01;
      min_qinv_reg         <= 18'h30cff;
      fwd_ntt_reg          <= 1'b1;
      ntt_first_rounds_reg <= 1'b1;
      single_idx_reg       <= 4'b0;
      pq_operator_reg      <= 5'b0;
      operand_a_reg        <= '0;
      operand_b_reg        <= '0;
      operand_c_reg        <= '0;
      busy_flag            <= 1'b0;
      result1_reg          <= '0;
      result2_reg          <= '0;
      result1_valid        <= 1'b0;
      result2_valid        <= 1'b0;
      rf_conflict_flag     <= 1'b0;
      irq_mask_reg         <= 2'b00;
    end else begin
      if (param_write)   param_n_reg          <= PWDATA[10:0];
      if (modulus_write) modulus_reg          <= PWDATA[15:0];
      if (min_write)     min_qinv_reg         <= PWDATA[17:0];
      if (cfg_write) begin
        fwd_ntt_reg          <= PWDATA[0];
        ntt_first_rounds_reg <= PWDATA[1];
      end
      if (idx_write)   single_idx_reg  <= PWDATA[3:0];
      if (pq_op_write) pq_operator_reg <= PWDATA[4:0];
      if (opa_write)   operand_a_reg   <= PWDATA;
      if (opb_write)   operand_b_reg   <= PWDATA;
      if (opc_write)   operand_c_reg   <= PWDATA;
      if (irq_mask_write) irq_mask_reg <= PWDATA[1:0];

      // Busy flag is set when multi or single butterfly kicks off, cleared by SW
      if (cmd_write && (PWDATA[0] | PWDATA[1])) begin
        busy_flag <= 1'b1;
      end else if (status_write && PWDATA[0]) begin
        busy_flag <= 1'b0;
      end

      // Result valid strobes
      if (pq_id_alu_we1) begin
        result1_reg   <= pq_id_alu_res1;
        result1_valid <= 1'b1;
      end else if (status_write && PWDATA[1]) begin
        result1_valid <= 1'b0;
      end

      if (pq_id_alu_we2) begin
        result2_reg   <= pq_id_alu_res2;
        result2_valid <= 1'b1;
      end else if (status_write && PWDATA[2]) begin
        result2_valid <= 1'b0;
      end

      // Sticky RF conflict flag clears when SW writes bit3
      if (apb_write && rf_sel && ntt_rf_write_active) begin
        rf_conflict_flag <= 1'b1;
      end else if (status_write && PWDATA[3]) begin
        rf_conflict_flag <= 1'b0;
      end
    end
  end

  // Command pulse generator (one-cycle pulses on write)
  always_ff @(posedge CLK, negedge RSTN)
  begin
    if (!RSTN) begin
      cmd_pulse <= '0;
      pq_en_id_pulse <= 1'b0;
    end else begin
      cmd_pulse       <= '0;
      pq_en_id_pulse  <= 1'b0;

      if (cmd_write) begin
        cmd_pulse.start_multi        <= PWDATA[0];
        cmd_pulse.single_bf          <= PWDATA[1];
        cmd_pulse.update_m_single    <= PWDATA[2];
        cmd_pulse.update_omega_single<= PWDATA[3];
        cmd_pulse.mul_psi1           <= PWDATA[4];
        cmd_pulse.mul_psi2           <= PWDATA[5];
        cmd_pulse.update_psi         <= PWDATA[6];
        cmd_pulse.mod_mul            <= PWDATA[7];
        cmd_pulse.mod_add            <= PWDATA[8];
        cmd_pulse.mod_sub            <= PWDATA[9];
      end

      if (alu_ctrl_write) begin
        pq_en_id_pulse <= PWDATA[0];
      end
    end
  end

  //////////////////////////////
  // PQ register file mirroring
  //////////////////////////////
  logic rf_write_pending;
  assign rf_write_pending = rf_write;

  always_ff @(posedge CLK, negedge RSTN)
  begin
    if (!RSTN) begin
      for (int unsigned i = 0; i < RF_DEPTH; i++) begin
        pq_mem[i] <= '0;
      end
    end else begin
      for (int unsigned i = 0; i < RF_DEPTH; i++) begin
        if (pq_we[i]) begin
          pq_mem[i] <= pq_wdata[i];
        end
      end

      if (rf_write_pending) begin
        pq_mem[rf_index] <= PWDATA;
      end
    end
  end

  //////////////////////////////
  // PRDATA multiplexing
  //////////////////////////////
  always_comb begin
    PRDATA = 32'h0000_0000;

    if (apb_read) begin
      unique case (1'b1)
        cmd_sel:      PRDATA = 32'h0; // write-only
        cfg_sel:      PRDATA = {30'b0, ntt_first_rounds_reg, fwd_ntt_reg};
        param_sel:    PRDATA = {21'b0, param_n_reg};
        modulus_sel:  PRDATA = {16'b0, modulus_reg};
        min_sel:      PRDATA = {14'b0, min_qinv_reg};
        idx_sel:      PRDATA = {28'b0, single_idx_reg};
        pq_op_sel:    PRDATA = {27'b0, pq_operator_reg};
        opa_sel:      PRDATA = operand_a_reg;
        opb_sel:      PRDATA = operand_b_reg;
        opc_sel:      PRDATA = operand_c_reg;
        res1_sel:     PRDATA = result1_reg;
        res2_sel:     PRDATA = result2_reg;
        status_sel: begin
          PRDATA[0] = busy_flag;
          PRDATA[1] = result1_valid;
          PRDATA[2] = result2_valid;
          PRDATA[3] = rf_conflict_flag;
          PRDATA[4] = ntt_rf_write_active;
        end
        irq_mask_sel: PRDATA = {30'b0, irq_mask_reg};
        default: begin
          if (rf_sel) begin
            PRDATA = pq_mem[rf_index];
          end
        end
      endcase
    end
  end

  //////////////////////////////
  // NTT instance
  //////////////////////////////
  logic [DATA_WIDTH-1:0] wdata_from_ntt [RF_DEPTH-1:0];
  logic [RF_DEPTH-1:0]   we_from_ntt;
  logic [DATA_WIDTH-1:0] rdata_to_ntt   [RF_DEPTH-1:0];

  assign rdata_to_ntt = pq_mem;
  assign pq_wdata     = wdata_from_ntt;
  assign pq_we        = we_from_ntt;

  ntt_closely_top #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) ntt_closely_top_i (
    .clk                     (CLK),
    .rst_n                   (RSTN),
    .param_n                 (param_n_reg),
    .modulus                 (modulus_reg),
    .param_MinQinvModR       (min_qinv_reg),
    .fwd_ntt                 (fwd_ntt_reg),
    .ntt_first_rounds        (ntt_first_rounds_reg),
    .ntt_start               (cmd_pulse.start_multi),
    .single_bf               (cmd_pulse.single_bf),
    .update_m_single_bf      (cmd_pulse.update_m_single),
    .index_single_bf         (single_idx_reg),
    .update_omega_single_bf  (cmd_pulse.update_omega_single),
    .mul_psi1                (cmd_pulse.mul_psi1),
    .mul_psi2                (cmd_pulse.mul_psi2),
    .update_psi              (cmd_pulse.update_psi),
    .mod_mul                 (cmd_pulse.mod_mul),
    .mod_add                 (cmd_pulse.mod_add),
    .mod_sub                 (cmd_pulse.mod_sub),
    .pq_en_id                (pq_en_id_pulse),
    .pq_operator_id          (pq_operator_reg),
    .alu_operand_a           (operand_a_reg),
    .alu_operand_b           (operand_b_reg),
    .alu_operand_c           (operand_c_reg),
    .pq_id_alu_res1          (pq_id_alu_res1),
    .pq_id_alu_res2          (pq_id_alu_res2),
    .pq_id_alu_we1           (pq_id_alu_we1),
    .pq_id_alu_we2           (pq_id_alu_we2),
    .wdata_pq_o              (wdata_from_ntt),
    .we_pq_o                 (we_from_ntt),
    .rdata_pq_i              (rdata_to_ntt)
  );

endmodule
