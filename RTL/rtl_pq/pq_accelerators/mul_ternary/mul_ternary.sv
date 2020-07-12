//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: mul_ternary
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module mul_ternary #(parameter PARAM_N=512, parameter PARAM_Q=251, parameter PARAM_LOG_Q=8)(
    input logic clk,
    input logic rst,
    input logic enable,
    input logic rst_command,
    input logic start_calc,
    input logic negative_wrap,  
    input logic [PARAM_LOG_Q-1:0] poly_gen [PARAM_N-1:0],
    input logic [1:0] poly_ter [PARAM_N-1:0],
    output logic [PARAM_LOG_Q-1:0] poly_out [PARAM_N-1:0],
    output logic ready
);

    logic [7:0] ff_out [PARAM_N-1:0];
    logic [7:0] mau_out [PARAM_N-1:0];
    logic [7:0] mau_out_0;
//    logic [1:0] mau_sel;
    logic [1:0] mau_sel [PARAM_N-1:0];
    logic [9:0] cntr;
    logic [9:0] cntr_sel;
    logic rst_ff;
    logic enable_ff;
    
    logic enable_clk;
    assign enable_clk =  (cntr == PARAM_N) ? 0:1; 
       
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
                if ((enable == 1'b1) & (start_calc == 1)) begin
                    next_state = DELAY;
                end else begin
                    next_state = IDLE;
                end
            DELAY: next_state = ACTIVE;
            ACTIVE: 
                if (cntr == PARAM_N-1) begin
                    next_state = DONE;
                end else begin
                    next_state = ACTIVE;
                end
            DONE: 
                if (rst_command == 1) begin
                    next_state = IDLE;
                end else begin
                    next_state = DONE;
                end
            default : next_state = IDLE;
        endcase
    end
    
    /// Output Logic ///
    always @ (posedge clk)
    begin : OUTPUT_LOGIC
        if (rst == 1'b1) begin
            cntr <= 0;
            rst_ff <= 1;
            enable_ff <= 0;
        end else begin
            case(curr_state)
                IDLE: begin
                    cntr <= 0;
                    rst_ff <= 1;
                    enable_ff <= 0;
                    ready <= 1;
                end
                DELAY: begin
                    rst_ff <= 0;
                    cntr <= 0;
                    enable_ff <= 1;
                    ready <= 0;
                end
                ACTIVE: begin
                    rst_ff <= 0;
                    cntr <= cntr + 1;
                    if (cntr < PARAM_N) begin
                        enable_ff <= 1;
                    end else begin
                        enable_ff <= 0;
                    end
                    ready <= 0;
                end
                DONE: begin
                    rst_ff <= 0;
                    cntr <= cntr;
                    enable_ff <= 0;
                    ready <= 1;
                end
                default: begin
                    rst_ff <= 1;
                    cntr <= 0;
                    enable_ff <= 0;
                    ready <= 1;
                end
            endcase
        end
    end
    
    assign poly_out = ff_out;
    
    //// LFSR ////
//    assign mau_sel = poly_ter[cntr];
    always_comb
    begin
        if (cntr <= PARAM_N-1) begin
            cntr_sel = PARAM_N-1 - cntr;
        end else begin
            cntr_sel = 0;
        end 
    end
    
    always_comb
    begin
        for (int j=0; j<PARAM_N; j++) begin
          if (cntr < PARAM_N) begin
            if ((j > cntr_sel) & (negative_wrap == 1)) begin
                if (poly_ter[cntr] == 0) begin
                    mau_sel[j] = 0;
                end else begin
                    mau_sel[j] = {~poly_ter[cntr][1], poly_ter[cntr][0]};
                end
            end else begin
                mau_sel[j] = poly_ter[cntr];
            end
          end else begin
            mau_sel[j] = 0;
          end
        end
    end
    
    genvar i;
    
    generate 
        for (i=0; i < PARAM_N; i++)
        begin
            mau #(.PARAM_LOG_Q(PARAM_LOG_Q), .PARAM_Q(PARAM_Q)) mau_i (
                .in_1(poly_gen[i]),
                .in_2(ff_out[i]),
                .in_sel(mau_sel[i]),
                .out_1(mau_out[i])
            );
            						
		    if (i == PARAM_N - 1)
		    begin
                dff #(.PARAM_WIDTH(PARAM_LOG_Q)) dff_i (
                    .clk(clk & enable_clk),
                    .rst(rst_ff),
                    .enable(enable_ff),
                    .d(mau_out[0]),
                    .q(ff_out[i])
                 );
            end else begin
                dff dff_i (
                    .clk(clk & enable_clk),
                    .rst(rst_ff),
                    .enable(enable_ff),
                    .d(mau_out[i+1]),
                    .q(ff_out[i])
                );
            end
        end
    endgenerate
endmodule
