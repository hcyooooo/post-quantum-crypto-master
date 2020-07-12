//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: mau
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module mau #(parameter PARAM_LOG_Q = 8, parameter PARAM_Q = 251) (
    input logic [PARAM_LOG_Q-1:0] in_1,
    input logic [PARAM_LOG_Q-1:0] in_2,
    input logic [1:0] in_sel,
    output logic [PARAM_LOG_Q-1:0]  out_1
);
    logic [PARAM_LOG_Q:0] tmp;
    always_comb
    begin
        tmp = 0;
        if (in_sel == 2'b00) begin
            tmp = in_2;
        end else if (in_sel == 2'b01) begin
            tmp = (in_1 + in_2);
            if (tmp >= PARAM_Q) begin
                tmp = tmp - PARAM_Q;
            end
        end else if (in_sel == 2'b11) begin
            tmp = ((in_2 + PARAM_Q) - in_1);
            if (tmp >= PARAM_Q) begin
                tmp = tmp - PARAM_Q;
            end          
        end
        out_1 = tmp;  
    end
endmodule
