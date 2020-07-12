//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: chien
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module chien #(PARAM_M = 9, PARAM_ALPHA = 4, PARAM_MUL_INST = 4)
(
    input logic clk,
    input logic rst,
    input logic enable,   
    input logic [31:0] in_1,
    input logic [31:0] in_2,
    output logic [31:0] out_1,
    output logic ready
);
 
    logic [PARAM_M-1:0] cntr;
    logic enable_ff;
    logic rst_ff;
    
    logic rst_enable;
    logic calc_enable;
    logic write_lower;
    logic write_higher;
    logic loop_enable;
    
    logic [PARAM_M-1:0] in_1_int [3:0];
    logic [PARAM_M-1:0] in_2_int [3:0];
    logic [PARAM_M-1:0] out_1_int [3:0];
    
    logic lock;
    
    assign rst_enable = 1;
    assign write_lower = in_2[31] & enable;
    assign write_higher = in_2[30] & enable;
    assign calc_enable = ((in_2[29] | in_2[28]) & enable);
    assign loop_enable = in_2[28] & enable;
    
    always @(posedge clk or posedge rst)
    begin
        if (rst == 1) begin
            in_1_int[0] <= 0;
            in_1_int[1] <= 0;
            in_1_int[2] <= 0;
            in_1_int[3] <= 0;
            in_2_int[0] <= 0;
            in_2_int[1] <= 0;
            in_2_int[2] <= 0;
            in_2_int[3] <= 0;
        end else begin
            if (write_lower == 1) begin
                in_1_int[0] <= in_1[PARAM_M-1:0];
                in_1_int[1] <= in_1[16+PARAM_M-1:16];  
                in_2_int[0] <= in_2[PARAM_M-1:0];
                in_2_int[1] <= in_2[16+PARAM_M-1:16];
            end else if (write_higher == 1) begin
                in_1_int[2] <= in_1[PARAM_M-1:0];
                in_1_int[3] <= in_1[16+PARAM_M-1:16];  
                in_2_int[2] <= in_2[PARAM_M-1:0];
                in_2_int[3] <= in_2[16+PARAM_M-1:16]; 
            end else if (loop_enable == 1) begin
                in_1_int[0] <= out_1_int[0];
                in_1_int[1] <= out_1_int[1];
                in_1_int[2] <= out_1_int[2];
                in_1_int[3] <= out_1_int[3];                
            end
        end   
    end
    
    //// Instantiate GF Multipliers ////
    genvar i;
    generate
        for (i=0; i<PARAM_MUL_INST; i=i+1) begin : generate_gf_multiplier
            chien_mul_general #(.PARAM_M(PARAM_M), .PARAM_ALPHA(PARAM_ALPHA)) chien_mul_general_inst (
                .clk(clk),
                .clk_ff(clk & enable_ff),
                .rst(rst),
                .rst_ff(rst | (rst_ff & rst_enable)),
                .cntr(cntr),
                .in_1(in_1_int[i]),
                .in_2(in_2_int[i]),
                .out_1(out_1_int[i])
            );                
        end
    endgenerate
 
    
    //// FSM ////
    localparam [1:0] IDLE = 2'b00, ACTIVE_MUL = 2'b01,  DONE_MUL = 2'b10;
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
                if ((calc_enable == 1) && (lock == 0)) begin
                    next_state = ACTIVE_MUL;
                end else begin
                    next_state = IDLE;
                end
            ACTIVE_MUL:
                if (cntr > 2) begin
                    next_state = ACTIVE_MUL;
                end else begin
                    next_state = DONE_MUL;
                end               
            DONE_MUL:
                 next_state = IDLE;
            default : next_state = IDLE;
        endcase
    end
    
    always @ (posedge clk)
    begin
        if (rst == 1'b1) begin
            lock <= 0;
        end else begin
            if ((calc_enable == 1) && (lock == 0)) begin
                lock <= 1;
            end else if (calc_enable == 0) begin
                lock <= 0;
            end
        end
    end
   
    /// Output Logic ///
    always @ (posedge clk)
    begin : OUTPUT_LOGIC
        if (rst == 1'b1) begin
            cntr <= PARAM_M+2;
            rst_ff <= 1;
            enable_ff = 0;
        end else begin
            case(curr_state)
                IDLE: begin
                    cntr <= PARAM_M+2;
                    rst_ff <= 1;
                    if (enable == 1) begin
                        enable_ff <= 1;
                    end else begin
                        enable_ff <= 0;
                    end
                end
                ACTIVE_MUL: begin
                    cntr = cntr -1;
                    rst_ff <= 0;
                    if (cntr == 1) begin
                        enable_ff <= 0;
                    end else begin
                        enable_ff <= 1;
                    end
                end
                DONE_MUL: begin
                    enable_ff <= 0;
                    rst_ff <= 0;
                end
                default: begin
                    cntr <= PARAM_M+2;
                    enable_ff <= 0;
                    rst_ff <= 1;
                end
            endcase
        end
    end

    always_comb
    begin
        if (rst == 1) begin
            ready <= 1;
        end else if (((calc_enable == 1) && (curr_state == IDLE) && (lock == 0)) || (curr_state != IDLE)) begin
            ready <= 0;
        end else begin
            ready <= 1;
        end            
    end
    
    //// Output Adder Logic ////
    assign out_1[PARAM_M-1:0] = out_1_int[0] ^ out_1_int[1] ^ out_1_int[2] ^ out_1_int[3];
    assign out_1[31:PARAM_M] = 0;
    
       
endmodule
