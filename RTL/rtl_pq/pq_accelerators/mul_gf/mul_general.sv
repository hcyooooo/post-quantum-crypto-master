//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: mul_general
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module mul_general #(PARAM_M = 4, PARAM_ALPHA = 1)
(
    input logic clk,
    input logic rst,
    input logic enable,   
    input logic [PARAM_M-1:0] in_1,
    input logic [PARAM_M-1:0] in_2,
    output logic [PARAM_M-1:0] out_1,
    output logic ready
);

    logic [PARAM_M-1:0] a;
    logic [PARAM_M-1:0] b;
    
    logic [PARAM_M-1:0] res_xor;
    logic [PARAM_M-1:0] res_and;
    logic in1_and;
    
    logic [PARAM_M-1:0] cntr;
    logic rst_ff;
    logic ready_int;
    
    assign b = in_1;
    

    genvar i;
    generate
        for (i=0; i<=PARAM_M-1; i=i+1) begin : generate_dff
            d_ff d_ff_inst (
                .clk(clk),
                .rst(rst | rst_ff),
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
    
    // Counter   
 //   always_ff @(posedge clk, posedge rst)
 //   begin
 //       if (rst) begin
 //           cntr <= PARAM_M+1;
 //       end else if (cntr > 0 & enable == 1) begin
//            cntr <= cntr-1;
//        end
//    end
    
//    always_comb
//    begin
//        if (rst == 1 & enable == 0) begin
//            out_1 <= 0;
//            ready <= 1;
//        end else if (cntr == PARAM_M+1 & enable == 0) begin
//            out_1 <= 0;
//            ready <= 1;               
//        end else if (cntr == 1) begin
//            out_1 <= a;
//            ready <= 1;
//        end else if (cntr >= 1) begin
//            ready <= 0;
//        end
//    end
    
//// 
    
    //// FSM ////
    localparam [1:0] IDLE = 2'b00, DELAY = 2'b01, ACTIVE = 2'b10,  DONE = 2'b11;
    logic [3:0] curr_state, next_state;
    
    /// Sequential ///
    always @ (posedge clk)
    begin : FSM_SEQ
        if (rst == 1'b1) begin
            curr_state <=  IDLE;
        end else begin
            curr_state <=  next_state;
        end
    end
      
    /// Combinatorial Logic ///
    always_comb
    begin : FSM_COMBO
        next_state = 3'b000;
        case(curr_state)
            IDLE: 
                if (enable == 1'b1) begin
                    next_state = DELAY;
                end else begin
                    next_state = IDLE;
                end
            DELAY: next_state = ACTIVE;
            ACTIVE:
                if (cntr > 1) begin
                    next_state = ACTIVE;
                end else begin
                    next_state = DONE;
                end               
            DONE: 
                next_state = IDLE;
            default : next_state = IDLE;
        endcase
    end 
    
    
    /// Output Logic ///
    always @ (posedge clk)
    begin : OUTPUT_LOGIC
        if (rst == 1'b1) begin
            cntr <= PARAM_M+2;
            ready_int <= 1;
            out_1 <= 0;
            rst_ff <= 1;
        end else begin
            case(curr_state)
                IDLE: begin
                    cntr <= PARAM_M+2;
                    ready_int <= 1;
                    rst_ff <= 1;
                end
                DELAY: begin
                     cntr <= PARAM_M+2;
                     ready_int <= 0;
                     rst_ff <= 0;
                end
                ACTIVE: begin
                    cntr = cntr -1;
                    if (cntr == 0) begin
                        ready_int <= 1;
                        out_1 <= a;
                    end else begin
                        ready_int = 0;
                    end
                    rst_ff <= 0;
                end
                DONE: begin
                    ready_int <= 1;
                    rst_ff <= 1;
                end
                default: begin
                    cntr <= PARAM_M+2;
                    ready_int <= 1;
                    rst_ff <= 1;
                end
            endcase
        end
    end

    always_comb
    begin
        if (rst == 1) begin
            ready = 1;
        end else if ((enable == 1 && curr_state == IDLE) || (enable == 1 && curr_state == DELAY) || (ready_int == 0)) begin
            ready = 0;
        end else begin
            ready = 1;
        end            
    end
       
endmodule
