//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: chien_mul_general
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module chien_mul_general #(PARAM_M = 9, PARAM_ALPHA = 4)
(
    input logic clk,
    input logic clk_ff,
    input logic rst,
    input logic rst_ff,
    input logic [PARAM_M-1:0] cntr,
    input logic [PARAM_M-1:0] in_1,
    input logic [PARAM_M-1:0] in_2,
    output logic [PARAM_M-1:0] out_1
);

    logic [PARAM_M-1:0] a;
    logic [PARAM_M-1:0] b;
    
    logic [PARAM_M-1:0] res_xor;
    logic [PARAM_M-1:0] res_and;
    logic in1_and;
    
    assign b = in_1;
    

    genvar i;
    generate
        for (i=0; i<=PARAM_M-1; i=i+1) begin : generate_dff
            d_ff d_ff_inst (
                .clk(clk_ff),
                .rst(rst_ff),
                .init(1'b0),
                .d(res_xor[i]),
                .q(a[i])
            );                
        end
    endgenerate
    
    generate
        for (i=0; i<=PARAM_M-1; i=i+1) begin : generate_xor
            if (i == 0) begin
                assign res_xor[i] = a[PARAM_M-1] ^ res_and[i];
            end else if (i == PARAM_ALPHA) begin
                assign res_xor[i] = a[i-1] ^ res_and[i] ^ a[PARAM_M-1];
            end else begin
                assign res_xor[i] = a[i-1] ^ res_and[i];
            end          
        end
    endgenerate
    
    generate
        for (i=0; i<=PARAM_M-1; i=i+1) begin : generate_and
            assign res_and[i] = b[i] & in1_and;        
        end
    endgenerate
    
    always_comb
    begin
        if (cntr < PARAM_M+2 && cntr > 1) begin
            in1_and <= in_2[cntr-2];
        end else begin
            in1_and <= 0;
        end
    end
    
    // Output logic
    always @(posedge clk or posedge rst)
    begin
        if (rst) begin
            out_1 <= 0;
        end else begin
            if (cntr  == 1) begin
                out_1 <= a;
            end
        end
    end
endmodule
