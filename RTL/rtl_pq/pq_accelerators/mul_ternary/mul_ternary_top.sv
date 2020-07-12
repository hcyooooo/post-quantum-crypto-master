//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: mul_ternary_top
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module mul_ternary_top #(parameter PARAM_N=512, parameter PARAM_LOG_N = 9, parameter PARAM_Q=251, parameter PARAM_LOG_Q=8)
(
    input logic clk,
    input logic rst,
    input logic enable_write,
    input logic enable_calc,
    input logic enable_read,
    input logic [31:0] in_1,
    input logic [31:0] in_2,
    output logic [31:0] out_1,
    output logic ready
);

    logic [7:0] poly_gen [PARAM_N-1:0];
    logic [1:0] poly_ter [PARAM_N-1:0];
    logic [7:0] poly_out [PARAM_N-1:0];
    
    logic ready_write;
    logic ready_calc;
    logic ready_read;
    
    assign ready_write = 1;
    assign ready_read = 1;
    assign ready = ready_write & ready_calc & ready_read;
    
    logic rst_command;
    logic start_calc;
    logic negative_wrap;
    
    //// Mul Ternary ////
    mul_ternary #(.PARAM_N(PARAM_N), .PARAM_Q(PARAM_Q), .PARAM_LOG_Q(PARAM_LOG_Q)) mul_ternary_i (
        .clk(clk),
        .rst(rst),
        .enable(enable_calc),
        .rst_command(rst_command),
        .start_calc(start_calc),
        .negative_wrap(negative_wrap),   
        .poly_gen(poly_gen),
        .poly_ter(poly_ter),
        .poly_out(poly_out),
        .ready(ready_calc)
    );
    
    always @(posedge clk)
    begin
        if (enable_calc == 1) begin
            start_calc <= in_1[0];
            negative_wrap <= in_1[1];
            rst_command <= in_1[2];
        end else begin
            start_calc <= 0;
            negative_wrap <= 0;
            rst_command <= 0;
        end
    end
    
    
    //// Write Logic ////
    shortint address_w; // start address write
    //  _________________________________________________________________________________________________
    // |      addr       |  b_4  |  a_4  |  b_3  |  a_3  |  b_2  |  a_2  |  b_1  |  a_1  |  b_0  |  a_0  |
    // |_________________|_______|_______|_______|_______|_______|_______|_______|_______|_______|_______|
    // |      63:50      | 49:48 | 47:40 | 39:38 | 37:30 | 29:28 | 27:20 | 19:18 | 17:10 |  9:8  |  7:0  |
    // |_________________|_______|_______|_______|_______|_______|_______|_______|_______|_______|_______|
    // |                 |       |       |       |       | 29:28 | 27:20 | 19:18 | 17:10 |  9:8  |  7:0  |
    // |      31:20      | 19:18 | 17:10 |  9:8  |  7:0  |       |       |       |       |       |       |
    // |_________________|_______|_______|_______|_______|_______|_______|_______|_______|_______|_______|   
    
    always @(posedge clk, posedge rst)
    begin
        if (rst == 1) begin
            for (int i=0; i<PARAM_N; i=i+1) poly_gen[i] = 0;
            for (int i=0; i<PARAM_N; i=i+1) poly_ter[i] = 0;
        end else if (rst_command == 1) begin
            for (int i=0; i<PARAM_N; i=i+1) poly_gen[i] = 0;
            for (int i=0; i<PARAM_N; i=i+1) poly_ter[i] = 0;
        end else begin
            if (enable_write == 1) begin
                address_w = in_2[31:20];
                if (address_w >= 510) begin
                    poly_gen[address_w] = in_1[7:0];
                    poly_ter[address_w] = in_1[9:8];
                    poly_gen[address_w+1] = in_1[17:10];
                    poly_ter[address_w+1] = in_1[19:18];
                end else begin
                    poly_gen[address_w] = in_1[7:0];
                    poly_ter[address_w] = in_1[9:8];
                    poly_gen[address_w+1] = in_1[17:10];
                    poly_ter[address_w+1] = in_1[19:18]; 
                    poly_gen[address_w+2] = in_1[27:20];
                    poly_ter[address_w+2] = in_1[29:28]; 
                    poly_gen[address_w+3] = in_2[7:0];
                    poly_ter[address_w+3] = in_2[9:8]; 
                    poly_gen[address_w+4] = in_2[17:10];
                    poly_ter[address_w+4] = in_2[19:18]; 
                end
            end
        end
    end
    
    
    //// Read Logic ////
    shortint address_r; // start address read
    always @(posedge clk)
    begin
        if (enable_read == 1) begin
            address_r = in_1[PARAM_LOG_N-1:0];
            out_1 = {poly_out[address_r+3],poly_out[address_r+2],poly_out[address_r+1],poly_out[address_r]};
        end else begin
            address_r <= 0;
            out_1 <= 0;
        end
    end    
endmodule
