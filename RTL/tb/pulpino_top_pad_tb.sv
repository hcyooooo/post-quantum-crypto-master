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

`timescale 10ps/1ps

`include "tb_jtag_pkg.sv"

`define REF_CLK_PERIOD   (2*15.25us)  // 32.786 kHz --> FLL reset value --> 50 MHz
`define CLK_PERIOD       100.00ns      // 25 MHz (scaled by 2.5)

`define EXIT_SUCCESS  0
`define EXIT_FAIL     1
`define EXIT_ERROR   -1

module pulpino_top_pad_tb;

  parameter  USE_ZERO_RISCY = 0;
  parameter  RISCY_RV32F    = 0;
  parameter  ZERO_RV32M     = 1;
  parameter  ZERO_RV32E     = 0;


  logic         s_clk   = 1'b0;
  logic         s_rst_n = 1'b0;

  logic         fetch_enable = 1'b0;

  logic [1:0]   padmode_spi_master;
  logic         spi_sck   = 1'b0;
  logic         spi_csn   = 1'b1;
  logic [1:0]   spi_mode;
  logic         spi_sdo0;
  logic         spi_sdo1;
  logic         spi_sdo2;
  logic         spi_sdo3;
  logic         spi_sdi0;
  logic         spi_sdi1;
  logic         spi_sdi2;
  logic         spi_sdi3;

  logic [31:0]  recv_data;
  logic use_qspi;


  logic [31:0]  gpio_in = '0;
  logic [31:0]  gpio_dir;
  logic [31:0]  gpio_out;

  jtag_i jtag_if();

  adv_dbg_if_t adv_dbg_if = new(jtag_if);

  // Wires because inout no registers are allowed
  wire s_clk_w;
  wire s_rst_n_w;
  wire fetch_enable_w;

  wire spi_sck_w;
  wire spi_csn_w;
  wire [1:0] spi_mode_w;
  wire spi_sdi0_w;
  wire spi_sdi1_w;
  wire spi_sdi2_w;
  wire spi_sdi3_w;
  wire spi_sdo0_w;
  wire spi_sdo1_w;
  wire spi_sdo2_w;
  wire spi_sdo3_w;

  wire [31:0] gpio_in_w;
  wire [31:0] gpio_out_w;
  wire [31:0] gpio_dir_w;

  wire tck_w;
  wire trstn_w;
  wire tms_w;
  wire tdi_w;
  wire tdo_w;

  assign s_clk_w = s_clk;
  assign s_rst_n_w = s_rst_n;
  assign fetch_enable_w = fetch_enable;
  assign spi_sck_w = spi_sck;
  assign spi_csn_w = spi_csn;
  assign spi_mode_w = spi_mode;
  assign spi_sdi0_w = spi_sdi0;
  assign spi_sdi1_w = spi_sdi1;
  assign spi_sdi2_w = spi_sdi2;
  assign spi_sdi3_w = spi_sdi3;
  assign spi_sdo0_w = spi_sdo0;
  assign spi_sdo1_w = spi_sdo1;
  assign spi_sdo2_w = spi_sdo2;
  assign spi_sdo3_w = spi_sdo3;

  assign gpio_in_w = gpio_in;
  assign gpio_out_w = gpio_out;
  assign gpio_dir_w = gpio_dir;

  assign tck_w = jtag_if.tck;
  assign trstn_w = jtag_if.trstn;
  assign tms_w = jtag_if.tms;
  assign tdi_w = jtag_if.tdi;
  assign tdo_w = jtag_if.tdo;

pulpino_top_pad
  top_pad_i
  (
    // Clock and Reset
    .clk_pad(s_clk_w),
    .rst_n_pad(s_rst_n_w),

    .fetch_enable_i_pad(fetch_enable_w),

    //SPI Slave
    .spi_clk_i_pad(spi_sck_w),
    .spi_cs_i_pad(spi_csn_w),
    .spi_mode_o_pad_0(spi_mode_w[0]),
    .spi_mode_o_pad_1(spi_mode_w[1]),
    .spi_sdo0_o_pad(spi_sdi0_w),
    .spi_sdo1_o_pad(spi_sdi1_w),
    .spi_sdo2_o_pad(spi_sdi2_w),
    .spi_sdo3_o_pad(spi_sdi3_w),
    .spi_sdi0_i_pad(spi_sdo0_w),
    .spi_sdi1_i_pad(spi_sdo1_w),
    .spi_sdi2_i_pad(spi_sdo2_w),
    .spi_sdi3_i_pad(spi_sdo3_w),

    // SPI Master
    .spi_master_clk_o_pad(),
    .spi_master_csn0_o_pad(),
    .spi_master_csn1_o_pad(),
    .spi_master_csn2_o_pad(),
    .spi_master_csn3_o_pad(),
    .spi_master_mode_o_pad_0(),
    .spi_master_mode_o_pad_1(),
    .spi_master_sdo0_o_pad(),
    .spi_master_sdo1_o_pad(),
    .spi_master_sdo2_o_pad(),
    .spi_master_sdo3_o_pad(),
    .spi_master_sdi0_i_pad(),
    .spi_master_sdi1_i_pad(),
    .spi_master_sdi2_i_pad(),
    .spi_master_sdi3_i_pad(),    

    // I2C
    .scl_pad_i_o_pad(),
    .sda_pad_i_o_pad(),

    // UART / RS-232
    .uart_tx_pad(),
    .uart_rx_pad(),
    .uart_rts_pad(),
    .uart_dtr_pad(),
    .uart_cts_pad(),
    .uart_dsr_pad(),

    // GPIO
    .gpio_in_out_pad_0(),
    .gpio_in_out_pad_1(),
    .gpio_in_out_pad_2(),
    .gpio_in_out_pad_3(),
    .gpio_in_out_pad_4(),
    .gpio_in_out_pad_5(),
    .gpio_in_out_pad_6(),
    .gpio_in_out_pad_7(),

    // JTAG signals
    .tck_i_pad(tck_w),
    .trstn_i_pad(trstn_w),
    .tms_i_pad(tms_w),
    .tdi_i_pad(tdi_w),
    .tdo_o_pad(tdo_w)
  );

  initial
  begin
    #(`CLK_PERIOD/2);
    s_clk = 1'b1;
    forever s_clk = #(`CLK_PERIOD/2) ~s_clk;
  end

  initial
  begin
    s_rst_n      = 1'b0;
    fetch_enable = 1'b0;

    #500ns;

    s_rst_n = 1'b1;

    #500ns;
    
    /* Enable QSPI */
    use_qspi = 1'b1;
    spi_enable_qpi();

    /* Configure JTAG and set boot address */
    adv_dbg_if.jtag_reset();
    adv_dbg_if.jtag_softreset();
    adv_dbg_if.init();
    adv_dbg_if.axi4_write32(32'h1A10_7008, 1, 32'h0000_0000);

    /* Write content to memory */
    spi_load(use_qspi);
    spi_check(use_qspi);

    #200ns;
    fetch_enable = 1'b1;

  end

  // TODO: this is a hack, do it properly!
  `include "tb_spi_pkg.sv"
endmodule

