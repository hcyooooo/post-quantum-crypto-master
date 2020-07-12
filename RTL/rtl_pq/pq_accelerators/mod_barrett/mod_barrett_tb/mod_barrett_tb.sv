`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: mod_barrett_tb
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module mod_barrett_tb(

    );
    logic [31:0] in_1, in_2, out_1;
    
    mod_barrett mod_barrett_i
    (
        .in_1(in_1),
        .in_2(in_2),
        .out_1(out_1)
    );
    
    initial
    begin
        in_1 <= 59099;
        in_2 <= 400;
    end
    
endmodule
