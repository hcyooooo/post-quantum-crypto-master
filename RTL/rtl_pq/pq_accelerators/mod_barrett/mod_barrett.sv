`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: mod_barrett
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


// Largest input value 59599

module mod_barrett #(parameter PARAM_K=14, parameter PARAM_M=65, parameter PARAM_Q=251)(
    input logic [31:0] in_1,
    input logic [31:0] in_2,
    output logic [31:0] out_1
    );
    
    logic [15:0] a;
    logic [21:0] u;

    // Barrett Reduction
    always_comb
    begin
        a = in_1[15:0] + in_2[15:0];
        u = a * PARAM_M;
        u = u >> PARAM_K;
        u = u * PARAM_Q;
        a = a - u;
        if (PARAM_Q <= a) begin
            a = a - PARAM_Q;
        end
        out_1 = a;
    end
    
endmodule
