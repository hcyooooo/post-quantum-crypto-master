`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: sha256_tb
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


`define REF_CLK_PERIOD   (2*15.25us)  // 32.786 kHz --> FLL reset value --> 50 MHz
`define CLK_PERIOD       40.00ns      // 25 MHz



module sha256_tb();
    logic clk, rst, gen_hash, load_hash, block_ready;
    
    logic [255:0] hash_in;
    logic [255:0] hash_out;
    logic [511:0] msg;

    
    sha256 sha256_i
    (
        .clk(clk),
        .rst(rst),
        .gen_hash(gen_hash),
        .load_hash(load_hash),
        .hash_in(hash_in),
        .msg(msg),
        .block_ready(block_ready),
        .hash_out(hash_out)
    );
    
    initial
    begin
        #(`REF_CLK_PERIOD/2);
        clk = 1'b1;
        forever clk = #(`REF_CLK_PERIOD/2) ~clk;
    end
    
    initial
    begin
        rst = 0;
        load_hash = 0;
        gen_hash = 0;
        #(`REF_CLK_PERIOD);
        rst = 1;
        #(`REF_CLK_PERIOD*2);
        rst = 0;
        #(`REF_CLK_PERIOD);
        msg = 0;
        
        msg[64*8-1:63*8] = 0;
        msg[63*8-1:62*8] = 1;
        msg[62*8-1:61*8] = 2;
        msg[61*8-1:60*8] = 3;
        msg[60*8-1:59*8] = 4;
        msg[59*8-1:58*8] = 5;
        msg[58*8-1:57*8] = 6;
        msg[57*8-1:56*8] = 7;        
        msg[56*8-1:55*8] = 8;
        msg[55*8-1:54*8] = 9;
        msg[54*8-1:53*8] = 10;
        msg[53*8-1:52*8] = 11;
        msg[52*8-1:51*8] = 12;
        msg[51*8-1:50*8] = 13;
        msg[50*8-1:49*8] = 14;
        msg[49*8-1:48*8] = 15;
        msg[48*8-1:47*8] = 16;
        msg[47*8-1:46*8] = 17;
        msg[46*8-1:45*8] = 18;
        msg[45*8-1:44*8] = 19;
        msg[44*8-1:43*8] = 20;
        msg[43*8-1:42*8] = 21;
        msg[42*8-1:41*8] = 22;
        msg[41*8-1:40*8] = 23;
        msg[40*8-1:39*8] = 24;
        msg[39*8-1:38*8] = 25;
        msg[38*8-1:37*8] = 26;
        msg[37*8-1:36*8] = 27;
        msg[36*8-1:35*8] = 28;
        msg[35*8-1:34*8] = 29;
        msg[34*8-1:33*8] = 30;
        msg[33*8-1:32*8] = 31;
        msg[32*8-1:31*8] = 128;  // For padding
        
        msg[2*8-1:1*8] = 1;  // For padding

                                           
//        msg[7:0] = 3;
//        msg[15:8] = 4;
//        msg[64*8-32*8-1:31*8] = 128;
//        msg[62*8] = 1;
//        msg[33*8:32*8] = 8'h08;
        
        //hash_in = 256'h000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F;
        hash_in = 0;
 //       load_hash = 1;
        #(`REF_CLK_PERIOD*2);
        load_hash = 0;
        #(`REF_CLK_PERIOD*2);
        gen_hash = 1;
        #(`REF_CLK_PERIOD*2);
        gen_hash = 0;
        
    end  

endmodule
