//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: sp_ram_bank
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////

module sp_ram_bank(clk_i, rstn_i, en_i, addr_i, wdata_i, rdata_o, we_i, be_i);
    parameter NUM_BANKS = 1;
    parameter BANK_SIZE = 1;
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 16;

    input  logic clk_i;
    input  logic rstn_i;
    input  logic en_i;
    input  logic [ADDR_WIDTH-1:0] addr_i;
    input  logic [DATA_WIDTH-1:0] wdata_i;
    output  logic [DATA_WIDTH-1:0] rdata_o;
    input  logic we_i;
    input  logic [3:0] be_i;

    logic [DATA_WIDTH-1:0] rdata_o_int;
    logic [ADDR_WIDTH-1:0] addr_i_int;

    assign rdata_o = rdata_o_int;
    assign addr_i_int = addr_i >> 2;

    SHKA65_16384X8X4CM16 bank0(
        .A0(addr_i_int[0]),
        .A1(addr_i_int[1]),
        .A2(addr_i_int[2]),
        .A3(addr_i_int[3]),
        .A4(addr_i_int[4]),
        .A5(addr_i_int[5]),
        .A6(addr_i_int[6]),
        .A7(addr_i_int[7]),
        .A8(addr_i_int[8]),
        .A9(addr_i_int[9]),
        .A10(addr_i_int[10]),
        .A11(addr_i_int[11]),
        .A12(addr_i_int[12]),
        .A13(addr_i_int[13]),
        .DO0(rdata_o_int[0]),
        .DO1(rdata_o_int[1]),
        .DO2(rdata_o_int[2]),
        .DO3(rdata_o_int[3]),
        .DO4(rdata_o_int[4]),
        .DO5(rdata_o_int[5]),
        .DO6(rdata_o_int[6]),
        .DO7(rdata_o_int[7]),
        .DO8(rdata_o_int[8]),
        .DO9(rdata_o_int[9]),
        .DO10(rdata_o_int[10]),
        .DO11(rdata_o_int[11]),
        .DO12(rdata_o_int[12]),
        .DO13(rdata_o_int[13]),
        .DO14(rdata_o_int[14]),
        .DO15(rdata_o_int[15]),
        .DO16(rdata_o_int[16]),
        .DO17(rdata_o_int[17]),
        .DO18(rdata_o_int[18]),
        .DO19(rdata_o_int[19]),
        .DO20(rdata_o_int[20]),
        .DO21(rdata_o_int[21]),
        .DO22(rdata_o_int[22]),
        .DO23(rdata_o_int[23]),
        .DO24(rdata_o_int[24]),
        .DO25(rdata_o_int[25]),
        .DO26(rdata_o_int[26]),
        .DO27(rdata_o_int[27]),
        .DO28(rdata_o_int[28]),
        .DO29(rdata_o_int[29]),
        .DO30(rdata_o_int[30]),
        .DO31(rdata_o_int[31]),
        .DI0(wdata_i[0]),
        .DI1(wdata_i[1]),
        .DI2(wdata_i[2]),
        .DI3(wdata_i[3]),
        .DI4(wdata_i[4]),
        .DI5(wdata_i[5]),
        .DI6(wdata_i[6]),
        .DI7(wdata_i[7]),
        .DI8(wdata_i[8]),
        .DI9(wdata_i[9]),
        .DI10(wdata_i[10]),
        .DI11(wdata_i[11]),
        .DI12(wdata_i[12]),
        .DI13(wdata_i[13]),
        .DI14(wdata_i[14]),
        .DI15(wdata_i[15]),
        .DI16(wdata_i[16]),
        .DI17(wdata_i[17]),
        .DI18(wdata_i[18]),
        .DI19(wdata_i[19]),
        .DI20(wdata_i[20]),
        .DI21(wdata_i[21]),
        .DI22(wdata_i[22]),
        .DI23(wdata_i[23]),
        .DI24(wdata_i[24]),
        .DI25(wdata_i[25]),
        .DI26(wdata_i[26]),
        .DI27(wdata_i[27]),
        .DI28(wdata_i[28]),
        .DI29(wdata_i[29]),
        .DI30(wdata_i[30]),
        .DI31(wdata_i[31]),
        .WEB0(~(be_i[0] & we_i)),
        .WEB1(~(be_i[1] & we_i)),
        .WEB2(~(be_i[2] & we_i)),
        .WEB3(~(be_i[3] & we_i)),
        .DVSE(1'b0),
        .DVS0(1'b0),
        .DVS1(1'b0),
        .DVS2(1'b0),
        .CK(clk_i),
        .CSB(~en_i)
    );

endmodule
