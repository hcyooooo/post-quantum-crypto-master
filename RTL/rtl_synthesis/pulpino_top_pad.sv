module pulpino_top_pad(
    // Clock and Reset
    inout logic clk_pad,
    inout logic rst_n_pad,
    inout logic fetch_enable_i_pad,

    // SPI Slave
    inout logic spi_clk_i_pad,
    inout logic spi_cs_i_pad,
    inout logic spi_mode_o_pad_0,
    inout logic spi_mode_o_pad_1,
    inout logic spi_sdo0_o_pad,
    inout logic spi_sdo1_o_pad,
    inout logic spi_sdo2_o_pad,
    inout logic spi_sdo3_o_pad,
    inout logic spi_sdi0_i_pad,
    inout logic spi_sdi1_i_pad,
    inout logic spi_sdi2_i_pad,
    inout logic spi_sdi3_i_pad,

    // SPI Master
    inout logic spi_master_clk_o_pad,
    inout logic spi_master_csn0_o_pad,
    inout logic spi_master_csn1_o_pad,
    inout logic spi_master_csn2_o_pad,
    inout logic spi_master_csn3_o_pad,
    inout logic spi_master_mode_o_pad_0,
    inout logic spi_master_mode_o_pad_1,
    inout logic spi_master_sdo0_o_pad,
    inout logic spi_master_sdo1_o_pad,
    inout logic spi_master_sdo2_o_pad,
    inout logic spi_master_sdo3_o_pad,
    inout logic spi_master_sdi0_i_pad,
    inout logic spi_master_sdi1_i_pad,
    inout logic spi_master_sdi2_i_pad,
    inout logic spi_master_sdi3_i_pad,

    // I2C
    inout logic scl_pad_i_o_pad,
    inout logic sda_pad_i_o_pad,

    // UART / RS-232
    inout logic uart_tx_pad,
    inout logic uart_rx_pad,
    inout logic uart_rts_pad,
    inout logic uart_dtr_pad,
    inout logic uart_cts_pad,
    inout logic uart_dsr_pad,

    // GPIO
    inout logic gpio_in_out_pad_0,
    inout logic gpio_in_out_pad_1,
    inout logic gpio_in_out_pad_2,
    inout logic gpio_in_out_pad_3,
    inout logic gpio_in_out_pad_4,
    inout logic gpio_in_out_pad_5,
    inout logic gpio_in_out_pad_6,
    inout logic gpio_in_out_pad_7,

    // JTAG signals
    inout logic tck_i_pad,
    inout logic trstn_i_pad,
    inout logic tms_i_pad,
    inout logic tdi_i_pad,
    inout logic tdo_o_pad
);
    // Clock and Reset
    logic clk_int;
    logic rst_n_int;
    logic fetch_enable_i_int;

    // SPI Slave
    logic spi_clk_i_int;
    logic spi_cs_i_int;
    logic [1:0] spi_mode_o_int;
    logic spi_sdo0_o_int;
    logic spi_sdo1_o_int;
    logic spi_sdo2_o_int;
    logic spi_sdo3_o_int;
    logic spi_sdi0_i_int;
    logic spi_sdi1_i_int;
    logic spi_sdi2_i_int;
    logic spi_sdi3_i_int;

    // SPI Master
    logic spi_master_clk_o_int;
    logic spi_master_csn0_o_int;
    logic spi_master_csn1_o_int;
    logic spi_master_csn2_o_int;
    logic spi_master_csn3_o_int;
    logic [1:0] spi_master_mode_o_int;
    logic spi_master_sdo0_o_int;
    logic spi_master_sdo1_o_int;
    logic spi_master_sdo2_o_int;
    logic spi_master_sdo3_o_int;
    logic spi_master_sdi0_i_int;
    logic spi_master_sdi1_i_int;
    logic spi_master_sdi2_i_int;
    logic spi_master_sdi3_i_int;

    // I2C
    logic scl_pad_i_int;
    logic scl_pad_o_int;
    logic scl_padoen_o_int;
    logic sda_pad_i_int;
    logic sda_pad_o_int;
    logic sda_padoen_o_int;

    // UART
    logic uart_tx_int;
    logic uart_rx_int;
    logic uart_rts_int;
    logic uart_dtr_int;
    logic uart_cts_int;
    logic uart_dsr_int;

    // GPIO
    logic [31:0] gpio_in_int;
    logic [31:0] gpio_out_int;
    logic [31:0] gpio_dir_int;

    assign gpio_in_int[8] = 1'b0;
    assign gpio_in_int[9] = 1'b0;
    assign gpio_in_int[10] = 1'b0;
    assign gpio_in_int[11] = 1'b0;
    assign gpio_in_int[12] = 1'b0;
    assign gpio_in_int[13] = 1'b0;
    assign gpio_in_int[14] = 1'b0;
    assign gpio_in_int[15] = 1'b0;
    assign gpio_in_int[16] = 1'b0;
    assign gpio_in_int[17] = 1'b0;
    assign gpio_in_int[18] = 1'b0;
    assign gpio_in_int[19] = 1'b0;
    assign gpio_in_int[20] = 1'b0;
    assign gpio_in_int[21] = 1'b0;
    assign gpio_in_int[22] = 1'b0;
    assign gpio_in_int[23] = 1'b0;
    assign gpio_in_int[24] = 1'b0;
    assign gpio_in_int[25] = 1'b0;
    assign gpio_in_int[26] = 1'b0;
    assign gpio_in_int[27] = 1'b0;
    assign gpio_in_int[28] = 1'b0;
    assign gpio_in_int[29] = 1'b0;
    assign gpio_in_int[30] = 1'b0;
    assign gpio_in_int[31] = 1'b0;

    // PAD Configuration 
    logic [31:0] [5:0] gpio_padcfg_int;

    // JTAG signals
    logic tck_i_int;
    logic trstn_i_int;
    logic tms_i_int;
    logic tdi_i_int;
    logic tdo_o_int;


    pulpino_top
    pulpino_top_inst
    (
        // Clock and Reset
        .clk(clk_int),
        .rst_n(rst_n_int),

        .clk_sel_i(1'b0),
        .clk_standalone_i(clk_int),
        .testmode_i(1'b0),
        .fetch_enable_i(fetch_enable_i_int),
        .scan_enable_i(1'b0),

        //SPI Slave
        .spi_clk_i(spi_clk_i_int),
        .spi_cs_i(spi_cs_i_int),
        .spi_mode_o(spi_mode_o_int),
        .spi_sdo0_o(spi_sdo0_o_int),
        .spi_sdo1_o(spi_sdo1_o_int),
        .spi_sdo2_o(spi_sdo2_o_int),
        .spi_sdo3_o(spi_sdo3_o_int),
        .spi_sdi0_i(spi_sdi0_i_int),
        .spi_sdi1_i(spi_sdi1_i_int),
        .spi_sdi2_i(spi_sdi2_i_int),
        .spi_sdi3_i(spi_sdi3_i_int),

        //SPI Master
        .spi_master_clk_o  (spi_master_clk_o_int),
        .spi_master_csn0_o (spi_master_csn0_o_int),
        .spi_master_csn1_o (spi_master_csn1_o_int),
        .spi_master_csn2_o (spi_master_csn2_o_int),
        .spi_master_csn3_o (spi_master_csn3_o_int),
        .spi_master_mode_o (spi_master_mode_o_int),
        .spi_master_sdo0_o (spi_master_sdo0_o_int),
        .spi_master_sdo1_o (spi_master_sdo1_o_int),
        .spi_master_sdo2_o (spi_master_sdo2_o_int),
        .spi_master_sdo3_o (spi_master_sdo3_o_int),
        .spi_master_sdi0_i (spi_master_sdi0_i_int),
        .spi_master_sdi1_i (spi_master_sdi1_i_int),
        .spi_master_sdi2_i (spi_master_sdi2_i_int),
        .spi_master_sdi3_i (spi_master_sdi3_i_int),

        .scl_pad_i         (scl_pad_i_int),
        .scl_pad_o         (scl_pad_o_int),
        .scl_padoen_o      (scl_padoen_o_int),
        .sda_pad_i         (sda_pad_i_int),
        .sda_pad_o         (sda_pad_o_int),
        .sda_padoen_o      (sda_padoen_o_int),

        .uart_tx           (uart_tx_int),
        .uart_rx           (uart_rx_int),
        .uart_rts          (uart_rts_int),
        .uart_dtr          (uart_dtr_int),
        .uart_cts          (uart_cts_int),
        .uart_dsr          (uart_dsr_int),

        .gpio_in           (gpio_in_int),
        .gpio_out          (gpio_out_int),
        .gpio_dir          (gpio_dir_int),

        .gpio_padcfg       (gpio_padcfg_int),

        // JTAG signals
        .tck_i             (tck_i_int),
        .trstn_i           (trstn_i_int),
        .tms_i             (tms_i_int),
        .tdi_i             (tdi_i_int),
        .tdo_o             (tdo_o_int)
    );


////////////////////////////// IO Cells //////////////////////////////
//////////////////////////////
//// Clock and Reset pads ////
//////////////////////////////
// Inputs
IUMB PAD_clk (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(1'b1), .SR(1'b0), .PD(1'b0), .PU(1'b0), .DI(clk_int), .PAD(clk_pad));

IUMB PAD_rst_n (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(1'b1), .SR(1'b0), .PD(1'b0), .PU(1'b1), .DI(rst_n_int), .PAD(rst_n_pad));

IUMB PAD_fetch_enable_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(1'b1), .SR(1'b0), .PD(1'b0), .PU(1'b1), .DI(fetch_enable_i_int), .PAD(fetch_enable_i_pad));


//////////////////////////////
//// SPI Slave            ////
//////////////////////////////
// Inputs
IUMB PAD_spi_clk_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(1'b1), .SR(1'b0), .PD(1'b0), .PU(1'b0), .DI(spi_clk_i_int), .PAD(spi_clk_i_pad));

IUMB PAD_spi_cs_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(1'b0), .SR(1'b0), .PD(1'b0), .PU(1'b0), .DI(spi_cs_i_int), .PAD(spi_cs_i_pad));

// Outputs
IUMB PAD_spi_mode_o_0 (.OE(1'b1), .IDDQ(1'b0), .DO(spi_mode_o_int[0]), .PIN1(1'b1), .PIN2(1'b1), .SMT(1'b0), .SR(1'b0), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_mode_o_pad_0));

IUMB PAD_spi_mode_o_1 (.OE(1'b1), .IDDQ(1'b0), .DO(spi_mode_o_int[1]), .PIN1(1'b1), .PIN2(1'b1), .SMT(1'b0), .SR(1'b0), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_mode_o_pad_1));

// Outputs
IUMB PAD_spi_sdo0_o (.OE(1'b1), .IDDQ(1'b0), .DO(spi_sdo0_o_int), .PIN1(1'b1), .PIN2(1'b1), .SMT(1'b0), .SR(1'b0), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_sdo0_o_pad));

IUMB PAD_spi_sdo1_o (.OE(1'b1), .IDDQ(1'b0), .DO(spi_sdo1_o_int), .PIN1(1'b1), .PIN2(1'b1), .SMT(1'b0), .SR(1'b0), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_sdo1_o_pad));

IUMB PAD_spi_sdo2_o (.OE(1'b1), .IDDQ(1'b0), .DO(spi_sdo2_o_int), .PIN1(1'b1), .PIN2(1'b1), .SMT(1'b0), .SR(1'b0), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_sdo2_o_pad));

IUMB PAD_spi_sdo3_o (.OE(1'b1), .IDDQ(1'b0), .DO(spi_sdo3_o_int), .PIN1(1'b1), .PIN2(1'b1), .SMT(1'b0), .SR(1'b0), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_sdo3_o_pad));

// Inputs
IUMB PAD_spi_sdi0_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(1'b0), .SR(1'b0), .PD(1'b1), .PU(1'b0), .DI(spi_sdi0_i_int), .PAD(spi_sdi0_i_pad));

IUMB PAD_spi_sdi1_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(1'b0), .SR(1'b0), .PD(1'b1), .PU(1'b0), .DI(spi_sdi1_i_int), .PAD(spi_sdi1_i_pad));

IUMB PAD_spi_sdi2_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(1'b0), .SR(1'b0), .PD(1'b1), .PU(1'b0), .DI(spi_sdi2_i_int), .PAD(spi_sdi2_i_pad));

IUMB PAD_spi_sdi3_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(1'b0), .SR(1'b0), .PD(1'b1), .PU(1'b0), .DI(spi_sdi3_i_int), .PAD(spi_sdi3_i_pad));


//////////////////////////////
//// SPI MASTER           ////
//////////////////////////////
// Outputs
IUMB PAD_spi_master_clk_o (.OE(1'b1), .IDDQ(1'b0), .DO(spi_master_clk_o_int), .PIN1(gpio_padcfg_int[0][4]), .PIN2(gpio_padcfg_int[0][5]), .SMT(1'b0), .SR(gpio_padcfg_int[0][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_master_clk_o_pad));

IUMB PAD_spi_master_csn0_o (.OE(1'b1), .IDDQ(1'b0), .DO(spi_master_csn0_o_int), .PIN1(gpio_padcfg_int[1][4]), .PIN2(gpio_padcfg_int[1][5]), .SMT(1'b0), .SR(gpio_padcfg_int[1][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_master_csn0_o_pad));

IUMB PAD_spi_master_csn1_o (.OE(1'b1), .IDDQ(1'b0), .DO(spi_master_csn1_o_int), .PIN1(gpio_padcfg_int[2][4]), .PIN2(gpio_padcfg_int[2][5]), .SMT(1'b0), .SR(gpio_padcfg_int[2][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_master_csn1_o_pad));

IUMB PAD_spi_master_csn2_o (.OE(1'b1), .IDDQ(1'b0), .DO(spi_master_csn2_o_int), .PIN1(gpio_padcfg_int[3][4]), .PIN2(gpio_padcfg_int[3][5]), .SMT(1'b0), .SR(gpio_padcfg_int[3][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_master_csn2_o_pad));

IUMB PAD_spi_master_csn3_o (.OE(1'b1), .IDDQ(1'b0), .DO(spi_master_csn3_o_int), .PIN1(gpio_padcfg_int[4][4]), .PIN2(gpio_padcfg_int[4][5]), .SMT(1'b0), .SR(gpio_padcfg_int[4][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_master_csn3_o_pad));

IUMB PAD_spi_master_mode_o_0 (.OE(1'b1), .IDDQ(1'b0), .DO(spi_master_mode_o_int[0]), .PIN1(gpio_padcfg_int[5][4]), .PIN2(gpio_padcfg_int[5][5]), .SMT(1'b0), .SR(gpio_padcfg_int[5][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_master_mode_o_pad_0));

IUMB PAD_spi_master_mode_o_1 (.OE(1'b1), .IDDQ(1'b0), .DO(spi_master_mode_o_int[1]), .PIN1(gpio_padcfg_int[6][4]), .PIN2(gpio_padcfg_int[6][5]), .SMT(1'b0), .SR(gpio_padcfg_int[6][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_master_mode_o_pad_1));

IUMB PAD_spi_master_sdo0_o (.OE(1'b1), .IDDQ(1'b0), .DO(spi_master_sdo0_o_int), .PIN1(gpio_padcfg_int[7][4]), .PIN2(gpio_padcfg_int[7][5]), .SMT(1'b0), .SR(gpio_padcfg_int[7][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_master_sdo0_o_pad));

IUMB PAD_spi_master_sdo1_o (.OE(1'b1), .IDDQ(1'b0), .DO(spi_master_sdo1_o_int), .PIN1(gpio_padcfg_int[8][4]), .PIN2(gpio_padcfg_int[8][5]), .SMT(1'b0), .SR(gpio_padcfg_int[8][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_master_sdo1_o_pad));

IUMB PAD_spi_master_sdo2_o (.OE(1'b1), .IDDQ(1'b0), .DO(spi_master_sdo2_o_int), .PIN1(gpio_padcfg_int[9][4]), .PIN2(gpio_padcfg_int[9][5]), .SMT(1'b0), .SR(gpio_padcfg_int[9][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_master_sdo2_o_pad));

IUMB PAD_spi_master_sdo3_o (.OE(1'b1), .IDDQ(1'b0), .DO(spi_master_sdo3_o_int), .PIN1(gpio_padcfg_int[10][4]), .PIN2(gpio_padcfg_int[10][5]), .SMT(1'b0), .SR(gpio_padcfg_int[10][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(spi_master_sdo3_o_pad));

// Inputs
IUMB PAD_spi_master_sdi0_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(gpio_padcfg_int[0][2]), .SR(1'b1), .PD(gpio_padcfg_int[0][1]), .PU(gpio_padcfg_int[0][0]), .DI(spi_master_sdi0_i_int), .PAD(spi_master_sdi0_i_pad));

IUMB PAD_spi_master_sdi1_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(gpio_padcfg_int[1][2]), .SR(1'b1), .PD(gpio_padcfg_int[1][1]), .PU(gpio_padcfg_int[1][0]), .DI(spi_master_sdi1_i_int), .PAD(spi_master_sdi1_i_pad));

IUMB PAD_spi_master_sdi2_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(gpio_padcfg_int[2][2]), .SR(1'b1), .PD(gpio_padcfg_int[2][1]), .PU(gpio_padcfg_int[2][0]), .DI(spi_master_sdi2_i_int), .PAD(spi_master_sdi2_i_pad));

IUMB PAD_spi_master_sdi3_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(gpio_padcfg_int[3][2]), .SR(1'b1), .PD(gpio_padcfg_int[3][1]), .PU(gpio_padcfg_int[3][0]), .DI(spi_master_sdi3_i_int), .PAD(spi_master_sdi3_i_pad));


//////////////////////////////
//// I2C                  ////
//////////////////////////////
// Inouts
IUMB PAD_scl_pad_i_o (.OE(scl_padoen_o_int), .IDDQ(1'b0), .DO(scl_pad_o_int), .PIN1(gpio_padcfg_int[11][4]), .PIN2(gpio_padcfg_int[11][5]), .SMT(gpio_padcfg_int[4][2]), .SR(gpio_padcfg_int[11][3]), .PD(gpio_padcfg_int[4][1]), .PU(gpio_padcfg_int[4][0]), .DI(scl_pad_i_int), .PAD(scl_pad_i_o_pad));

IUMB PAD_sda_pad_i_o (.OE(sda_padoen_o_int), .IDDQ(1'b0), .DO(sda_pad_o_int), .PIN1(gpio_padcfg_int[12][4]), .PIN2(gpio_padcfg_int[12][5]), .SMT(gpio_padcfg_int[5][2]), .SR(gpio_padcfg_int[12][3]), .PD(gpio_padcfg_int[5][1]), .PU(gpio_padcfg_int[5][0]), .DI(sda_pad_i_int), .PAD(sda_pad_i_o_pad));


//////////////////////////////
//// UART                 ////
//////////////////////////////
// Outputs
IUMB PAD_uart_tx (.OE(1'b1), .IDDQ(1'b0), .DO(uart_tx_int), .PIN1(gpio_padcfg_int[13][4]), .PIN2(gpio_padcfg_int[13][5]), .SMT(1'b0), .SR(gpio_padcfg_int[13][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(uart_tx_pad));

// Inputs
IUMB PAD_uart_rx (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(gpio_padcfg_int[6][2]), .SR(1'b1), .PD(gpio_padcfg_int[6][1]), .PU(gpio_padcfg_int[6][0]), .DI(uart_rx_int), .PAD(uart_rx_pad));

// Outputs
IUMB PAD_uart_rts (.OE(1'b1), .IDDQ(1'b0), .DO(uart_rts_int), .PIN1(gpio_padcfg_int[14][4]), .PIN2(gpio_padcfg_int[14][5]), .SMT(1'b0), .SR(gpio_padcfg_int[14][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(uart_rts_pad));

IUMB PAD_uart_dtr (.OE(1'b1), .IDDQ(1'b0), .DO(uart_dtr_int), .PIN1(gpio_padcfg_int[15][4]), .PIN2(gpio_padcfg_int[15][5]), .SMT(1'b0), .SR(gpio_padcfg_int[15][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(uart_dtr_pad));

// Inputs
IUMB PAD_uart_cts (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(gpio_padcfg_int[7][2]), .SR(1'b1), .PD(gpio_padcfg_int[7][1]), .PU(gpio_padcfg_int[7][0]), .DI(uart_cts_int), .PAD(uart_cts_pad));

IUMB PAD_uart_dsr (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(gpio_padcfg_int[8][2]), .SR(1'b1), .PD(gpio_padcfg_int[8][1]), .PU(gpio_padcfg_int[8][0]), .DI(uart_dsr_int), .PAD(uart_dsr_pad));


//////////////////////////////
//// JTAG pads            ////
//////////////////////////////
// Inputs
IUMB PAD_tck_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(gpio_padcfg_int[9][2]), .SR(1'b1), .PD(gpio_padcfg_int[9][1]), .PU(gpio_padcfg_int[9][0]), .DI(tck_i_int), .PAD(tck_i_pad));

IUMB PAD_trstn_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(gpio_padcfg_int[10][2]), .SR(1'b1), .PD(gpio_padcfg_int[10][1]), .PU(gpio_padcfg_int[10][0]), .DI(trstn_i_int), .PAD(trstn_i_pad));

IUMB PAD_tms_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(gpio_padcfg_int[11][2]), .SR(1'b1), .PD(gpio_padcfg_int[11][1]), .PU(gpio_padcfg_int[11][0]), .DI(tms_i_int), .PAD(tms_i_pad));

IUMB PAD_tdi_i (.OE(1'b0), .IDDQ(1'b0), .DO(1'b0), .PIN1(1'b0), .PIN2(1'b0), .SMT(gpio_padcfg_int[12][2]), .SR(1'b1), .PD(gpio_padcfg_int[12][1]), .PU(gpio_padcfg_int[12][0]), .DI(tdi_i_int), .PAD(tdi_i_pad));

// Output
IUMB PAD_tdo_o (.OE(1'b1), .IDDQ(1'b0), .DO(tdo_o_int), .PIN1(gpio_padcfg_int[16][4]), .PIN2(gpio_padcfg_int[16][5]), .SMT(1'b0), .SR(gpio_padcfg_int[16][3]), .PD(1'b0), .PU(1'b0), .DI(), .PAD(tdo_o_pad));


//////////////////////////////
//// GPIO Interface       ////
//////////////////////////////
// Inouts
IUMB PAD_gpio_in_out_0 (.OE(gpio_dir_int[0]), .IDDQ(1'b0), .DO(gpio_out_int[0]), .PIN1(gpio_padcfg_int[17][4]), .PIN2(gpio_padcfg_int[17][5]), .SMT(gpio_padcfg_int[13][2]), .SR(gpio_padcfg_int[17][3]), .PD(gpio_padcfg_int[13][1]), .PU(gpio_padcfg_int[13][0]), .DI(gpio_in_int[0]), .PAD(gpio_in_out_pad_0));

IUMB PAD_gpio_in_out_1 (.OE(gpio_dir_int[1]), .IDDQ(1'b0), .DO(gpio_out_int[1]), .PIN1(gpio_padcfg_int[18][4]), .PIN2(gpio_padcfg_int[18][5]), .SMT(gpio_padcfg_int[14][2]), .SR(gpio_padcfg_int[18][3]), .PD(gpio_padcfg_int[14][1]), .PU(gpio_padcfg_int[14][0]), .DI(gpio_in_int[1]), .PAD(gpio_in_out_pad_1));

IUMB PAD_gpio_in_out_2 (.OE(gpio_dir_int[2]), .IDDQ(1'b0), .DO(gpio_out_int[2]), .PIN1(gpio_padcfg_int[19][4]), .PIN2(gpio_padcfg_int[19][5]), .SMT(gpio_padcfg_int[15][2]), .SR(gpio_padcfg_int[19][3]), .PD(gpio_padcfg_int[15][1]), .PU(gpio_padcfg_int[15][0]), .DI(gpio_in_int[2]), .PAD(gpio_in_out_pad_2));

IUMB PAD_gpio_in_out_3 (.OE(gpio_dir_int[3]), .IDDQ(1'b0), .DO(gpio_out_int[3]), .PIN1(gpio_padcfg_int[20][4]), .PIN2(gpio_padcfg_int[20][5]), .SMT(gpio_padcfg_int[16][2]), .SR(gpio_padcfg_int[20][3]), .PD(gpio_padcfg_int[16][1]), .PU(gpio_padcfg_int[16][0]), .DI(gpio_in_int[3]), .PAD(gpio_in_out_pad_3));

IUMB PAD_gpio_in_out_4 (.OE(gpio_dir_int[4]), .IDDQ(1'b0), .DO(gpio_out_int[4]), .PIN1(gpio_padcfg_int[21][4]), .PIN2(gpio_padcfg_int[21][5]), .SMT(gpio_padcfg_int[17][2]), .SR(gpio_padcfg_int[21][3]), .PD(gpio_padcfg_int[17][1]), .PU(gpio_padcfg_int[17][0]), .DI(gpio_in_int[4]), .PAD(gpio_in_out_pad_4));

IUMB PAD_gpio_in_out_5 (.OE(gpio_dir_int[5]), .IDDQ(1'b0), .DO(gpio_out_int[5]), .PIN1(gpio_padcfg_int[22][4]), .PIN2(gpio_padcfg_int[22][5]), .SMT(gpio_padcfg_int[18][2]), .SR(gpio_padcfg_int[22][3]), .PD(gpio_padcfg_int[18][1]), .PU(gpio_padcfg_int[18][0]), .DI(gpio_in_int[5]), .PAD(gpio_in_out_pad_5));

IUMB PAD_gpio_in_out_6 (.OE(gpio_dir_int[6]), .IDDQ(1'b0), .DO(gpio_out_int[6]), .PIN1(gpio_padcfg_int[23][4]), .PIN2(gpio_padcfg_int[23][5]), .SMT(gpio_padcfg_int[19][2]), .SR(gpio_padcfg_int[23][3]), .PD(gpio_padcfg_int[19][1]), .PU(gpio_padcfg_int[19][0]), .DI(gpio_in_int[6]), .PAD(gpio_in_out_pad_6));

IUMB PAD_gpio_in_out_7 (.OE(gpio_dir_int[7]), .IDDQ(1'b0), .DO(gpio_out_int[7]), .PIN1(gpio_padcfg_int[24][4]), .PIN2(gpio_padcfg_int[24][5]), .SMT(gpio_padcfg_int[20][2]), .SR(gpio_padcfg_int[24][3]), .PD(gpio_padcfg_int[20][1]), .PU(gpio_padcfg_int[20][0]), .DI(gpio_in_int[7]), .PAD(gpio_in_out_pad_7));

endmodule
