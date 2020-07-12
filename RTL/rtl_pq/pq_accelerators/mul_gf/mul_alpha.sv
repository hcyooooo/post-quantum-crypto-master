//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: mul_alpha
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module mul_alpha
    #(PARAM_M = 4, PARAM_ALPHA = 1)
    (
        input logic clk,
        input logic rst,    
        input logic [PARAM_M-1:0] in_1,
        output logic [PARAM_M-1:0] out_1
    );
    
    logic [PARAM_M-1:0] b;
    logic res_xor;
    
    assign res_xor = b[PARAM_M-1] ^ b[PARAM_ALPHA-1];
    assign out_1 = b;
    
    genvar i;
    generate
        for (i=0; i<=PARAM_M-1; i=i+1) begin : generate_dff
            if (i==0) begin
                d_ff d_ff_inst (
                    .clk(clk),
                    .rst(rst),
                    .init(in_1[i]),
                    .d(b[PARAM_M-1]),
                    .q(b[i])
                 );
             end else if (i==PARAM_ALPHA) begin
                 d_ff d_ff_inst (
                     .clk(clk),
                     .rst(rst),
                     .init(in_1[i]),
                     .d(res_xor),
                     .q(b[i])
                  );
            end else begin
                d_ff d_ff_inst (
                    .clk(clk),
                      .rst(rst),
                      .init(in_1[i]),
                      .d(b[i-1]),
                      .q(b[i])
                   );             
              end                  
        end
    endgenerate    
endmodule
