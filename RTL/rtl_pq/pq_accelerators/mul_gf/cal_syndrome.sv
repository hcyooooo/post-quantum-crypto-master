//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: cal_syndrome
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module cal_syndrome
    #(PARAM_M = 4, PARAM_ALPHA = 1, PARAM_ECC_BITS = 171, PARAM_LOG_ECC_BITS = 8)
    (
        input logic clk,
        input logic rst,    
        input logic [PARAM_ECC_BITS-1:0] in_1,
        output logic [PARAM_M-1:0] out_1
    );

    logic [PARAM_M-1:0] b;
    logic [1:0] res_xor;
    logic [PARAM_LOG_ECC_BITS-1:0] cntr;
    
    logic in1_xor;

    always_comb
    begin
        if (cntr > 1) begin
            in1_xor <= in_1[cntr-2];
            res_xor[0] <= b[PARAM_M-1] ^ in_1[cntr-2];
        end else begin
            in1_xor <= 0;
            res_xor[0] <= 0;
        end
    end
    assign res_xor[1] = b[PARAM_M-1] ^ b[PARAM_ALPHA-1];

    genvar i;
    generate
        for (i=0; i<=PARAM_M-1; i=i+1) begin : generate_dff
            if (i==0) begin
                d_ff d_ff_inst (
                    .clk(clk),
                    .rst(rst),
                    .init(0),
                    .d(res_xor[0]),
                    .q(b[i])
                );
            end else if (i==PARAM_ALPHA) begin
                d_ff d_ff_inst (
                    .clk(clk),
                    .rst(rst),
                    .init(0),
                    .d(res_xor[1]),
                    .q(b[i])
                );
            end else begin
                d_ff d_ff_inst (
                    .clk(clk),
                    .rst(rst),
                    .init(0),
                    .d(b[i-1]),
                    .q(b[i])
                );             
            end                  
        end
    endgenerate

    always_ff @(posedge clk, posedge rst)
    begin
        if (rst) begin
            cntr <= PARAM_ECC_BITS+1;
        end else if (cntr > 0) begin
            cntr <= cntr-1;
        end
    end
    
    always_comb
    begin
        if (rst == 1) begin
            out_1 <= 0;
        end else if (cntr == 1) begin
            out_1 <= b;
        end 
    end  
        
endmodule
