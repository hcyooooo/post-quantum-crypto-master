`timescale 10ps/1ps

`include "tb_jtag_pkg.sv"

`define REF_CLK_PERIOD   (2*15.25us)  // 32.786 kHz --> FLL reset value --> 50 MHz
`define CLK_PERIOD       40.00ns      // 25 MHz

`define EXIT_SUCCESS  0
`define EXIT_FAIL     1
`define EXIT_ERROR   -1

module pulpino_top_tb;

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


pulpino_top
  top_i
  (
    .clk               ( s_clk        ),
    .rst_n             ( s_rst_n      ),

    .clk_sel_i         ( 1'b0         ),
    .clk_standalone_i  ( s_clk        ),
    .testmode_i        ( 1'b0         ),
    .fetch_enable_i    ( fetch_enable ),
    .scan_enable_i     ( 1'b0         ),

    .spi_clk_i         ( spi_sck      ),
    .spi_cs_i          ( spi_csn      ),
    .spi_mode_o        ( spi_mode     ),
    .spi_sdo0_o        ( spi_sdi0     ),
    .spi_sdo1_o        ( spi_sdi1     ),
    .spi_sdo2_o        ( spi_sdi2     ),
    .spi_sdo3_o        ( spi_sdi3     ),
    .spi_sdi0_i        ( spi_sdo0     ),
    .spi_sdi1_i        ( spi_sdo1     ),
    .spi_sdi2_i        ( spi_sdo2     ),
    .spi_sdi3_i        ( spi_sdo3     ),

    .spi_master_clk_o  ( ),
    .spi_master_csn0_o ( ),
    .spi_master_csn1_o ( ),
    .spi_master_csn2_o ( ),
    .spi_master_csn3_o ( ),
    .spi_master_mode_o ( ),
    .spi_master_sdo0_o ( ),
    .spi_master_sdo1_o ( ),
    .spi_master_sdo2_o ( ),
    .spi_master_sdo3_o ( ),
    .spi_master_sdi0_i ( ),
    .spi_master_sdi1_i ( ),
    .spi_master_sdi2_i ( ),
    .spi_master_sdi3_i ( ),

    .scl_pad_i         ( ),
    .scl_pad_o         ( ),
    .scl_padoen_o      ( ),
    .sda_pad_i         ( ),
    .sda_pad_o         ( ),
    .sda_padoen_o      ( ),


    .uart_tx           ( ),
    .uart_rx           ( ),
    .uart_rts          ( ),
    .uart_dtr          ( ),
    .uart_cts          ( 1'b0         ),
    .uart_dsr          ( 1'b0         ),

    .gpio_in           ( gpio_in      ),
    .gpio_out          ( gpio_out     ),
    .gpio_dir          ( gpio_dir     ),
//    .gpio_padcfg       (              ),

    .tck_i             ( jtag_if.tck     ),
    .trstn_i           ( jtag_if.trstn   ),
    .tms_i             ( jtag_if.tms     ),
    .tdi_i             ( jtag_if.tdi     ),
    .tdo_o             ( jtag_if.tdo     )
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
