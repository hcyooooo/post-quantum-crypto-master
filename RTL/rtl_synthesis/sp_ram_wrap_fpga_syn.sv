//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: sp_ram_wrap (fpga_syn)
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


`include "config.sv"

module sp_ram_wrap
  #(
    parameter RAM_SIZE   = 32768,              // in bytes
    parameter ADDR_WIDTH = $clog2(RAM_SIZE),
    parameter DATA_WIDTH = 32
  )(
    // Clock and Reset
    input  logic                    clk,
    input  logic                    rstn_i,
    input  logic                    en_i,
    input  logic [ADDR_WIDTH-1:0]   addr_i,
    input  logic [DATA_WIDTH-1:0]   wdata_i,
    output logic [DATA_WIDTH-1:0]   rdata_o,
    input  logic                    we_i,
    input  logic [DATA_WIDTH/8-1:0] be_i,
    input  logic                    bypass_en_i
  );


  sp_ram
  sp_ram_i  (
    .addra(addr_i[ADDR_WIDTH-1:2]),  // Address bus, width determined from RAM_DEPTH
    .dina(wdata_i),         // RAM input data
    .clka(clk),             // Clock
    .wea(be_i & {4{we_i}}), // Write enable
    .ena(en_i),             // RAM Enable, for additional power savings, disable port when not in use
    .rsta(1'b0),            // Output reset (does not affect memory contents)
    .regcea(1'b0),          // Output register enable
    .douta(rdata_o)         // RAM output data
  );

endmodule
