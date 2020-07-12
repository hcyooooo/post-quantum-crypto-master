//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: sha256_top
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module sha256_top
(
    input logic clk,
    input logic rst,
    input logic enable,
    input logic [31:0] in_1,
    input logic [31:0] in_2,
    output logic [31:0] out_1,
    output logic ready
);

    logic gen_hash;
    logic gen_hash_pulse;
    logic write_input;
    logic read_output;
    logic [511:0] msg;
    logic [255:0] hash_out;
    logic block_ready;
    logic rst_manual;
    logic rst_soft;
    logic lock;
    
    always_ff  @(posedge clk)
    begin      
        if (gen_hash == 1 && block_ready == 0) begin
            ready = 0;
        end else begin
            ready = 1;
        end
        
    end
    
    assign write_input = in_2[31] & enable;   // control signals
    assign gen_hash = in_2[30] & enable;      // control signals
    assign gen_hash_pulse = in_2[30] & enable & (~lock);      // control signals
    assign read_output = in_2[29] & enable;   // control signals
    assign rst_manual = in_2[28] & enable;    // control signals
    assign rst_soft = in_2[27] & enable;      // control signals
    
    always_ff  @(posedge clk, posedge rst)
    begin
        if (rst == 1) begin
            lock <= 0;
        end else if (rst_manual == 1 || rst_soft == 1) begin
            lock <= 0;
        end else if(gen_hash_pulse == 1) begin
            lock <= 1;
        end
    end
    
    // Write logic
    always_ff @(posedge clk, posedge rst)
    begin
        if (rst == 1) begin
            msg = 0;
            msg[32*8-1:31*8] = 128;  // For padding
            msg[2*8-1:1*8] = 1;  // For padding
        end else if(rst_manual == 1) begin
            msg = 0;
            msg[32*8-1:31*8] = 128;  // For padding
            msg[2*8-1:1*8] = 1;  // For padding
        end else begin
            if (enable == 1 && write_input == 1) begin
                case (in_2[5:0])
                    0: msg[64*8-1:63*8] = in_1[7:0];
                    1: msg[63*8-1:62*8] = in_1[7:0];
                    2: msg[62*8-1:61*8] = in_1[7:0];
                    3: msg[61*8-1:60*8] = in_1[7:0];
                    4: msg[60*8-1:59*8] = in_1[7:0];
                    5: msg[59*8-1:58*8] = in_1[7:0];
                    6: msg[58*8-1:57*8] = in_1[7:0];
                    7: msg[57*8-1:56*8] = in_1[7:0];
                    8: msg[56*8-1:55*8] = in_1[7:0];
                    9: msg[55*8-1:54*8] = in_1[7:0];
                    10: msg[54*8-1:53*8] = in_1[7:0];
                    11: msg[53*8-1:52*8] = in_1[7:0];
                    12: msg[52*8-1:51*8] = in_1[7:0];
                    13: msg[51*8-1:50*8] = in_1[7:0];
                    14: msg[50*8-1:49*8] = in_1[7:0];
                    15: msg[49*8-1:48*8] = in_1[7:0];
                    16: msg[48*8-1:47*8] = in_1[7:0];
                    17: msg[47*8-1:46*8] = in_1[7:0];
                    18: msg[46*8-1:45*8] = in_1[7:0];
                    19: msg[45*8-1:44*8] = in_1[7:0];
                    20: msg[44*8-1:43*8] = in_1[7:0];
                    21: msg[43*8-1:42*8] = in_1[7:0];
                    22: msg[42*8-1:41*8] = in_1[7:0];
                    23: msg[41*8-1:40*8] = in_1[7:0];
                    24: msg[40*8-1:39*8] = in_1[7:0];
                    25: msg[39*8-1:38*8] = in_1[7:0];
                    26: msg[38*8-1:37*8] = in_1[7:0];
                    27: msg[37*8-1:36*8] = in_1[7:0];
                    28: msg[36*8-1:35*8] = in_1[7:0];
                    29: msg[35*8-1:34*8] = in_1[7:0];
                    30: msg[34*8-1:33*8] = in_1[7:0];
                    
                    31: msg[33*8-1:32*8] = in_1[7:0];
                    32: msg[32*8-1:31*8] = in_1[7:0];
                    33: msg[31*8-1:30*8] = in_1[7:0];
                    34: msg[30*8-1:29*8] = in_1[7:0];
                    35: msg[29*8-1:28*8] = in_1[7:0];
                    36: msg[28*8-1:27*8] = in_1[7:0];
                    37: msg[27*8-1:26*8] = in_1[7:0];
                    38: msg[26*8-1:25*8] = in_1[7:0];
                    39: msg[25*8-1:24*8] = in_1[7:0];
                    40: msg[24*8-1:23*8] = in_1[7:0];
                    41: msg[23*8-1:22*8] = in_1[7:0];
                    42: msg[22*8-1:21*8] = in_1[7:0];
                    43: msg[21*8-1:20*8] = in_1[7:0];
                    44: msg[20*8-1:19*8] = in_1[7:0];
                    45: msg[19*8-1:18*8] = in_1[7:0];
                    46: msg[18*8-1:17*8] = in_1[7:0];
                    47: msg[17*8-1:16*8] = in_1[7:0];
                    48: msg[16*8-1:15*8] = in_1[7:0];
                    49: msg[15*8-1:14*8] = in_1[7:0];
                    50: msg[14*8-1:13*8] = in_1[7:0];
                    51: msg[13*8-1:12*8] = in_1[7:0];
                    52: msg[12*8-1:11*8] = in_1[7:0];
                    53: msg[11*8-1:10*8] = in_1[7:0];
                    54: msg[10*8-1:9*8] = in_1[7:0];
                    55: msg[9*8-1:8*8] = in_1[7:0];
                    56: msg[8*8-1:7*8] = in_1[7:0];
                    57: msg[7*8-1:6*8] = in_1[7:0];
                    58: msg[6*8-1:5*8] = in_1[7:0];
                    59: msg[5*8-1:4*8] = in_1[7:0];
                    60: msg[4*8-1:3*8] = in_1[7:0];
                    61: msg[3*8-1:2*8] = in_1[7:0];
                    62: msg[2*8-1:1*8] = in_1[7:0];
                    63: msg[1*8-1:0] = in_1[7:0];
                    
                    default: msg = 0;
                endcase
            end
        end
    end

    // Read logic
    always_comb
    begin
        if (rst == 1) begin
            out_1 = 0;
        end else begin
            if (enable == 1 && read_output == 1) begin
                case (in_2[4:0])
                    0: out_1 = hash_out[32*8-1:31*8];
                    1: out_1 = hash_out[31*8-1:30*8];
                    2: out_1 = hash_out[30*8-1:29*8];
                    3: out_1 = hash_out[29*8-1:28*8];
                    4: out_1 = hash_out[28*8-1:27*8];
                    5: out_1 = hash_out[27*8-1:26*8];
                    6: out_1 = hash_out[26*8-1:25*8];
                    7: out_1 = hash_out[25*8-1:24*8];
                    8: out_1 = hash_out[24*8-1:23*8];
                    9: out_1 = hash_out[23*8-1:22*8];
                    10: out_1 = hash_out[22*8-1:21*8];
                    11: out_1 = hash_out[21*8-1:20*8];
                    12: out_1 = hash_out[20*8-1:19*8];
                    13: out_1 = hash_out[19*8-1:18*8];
                    14: out_1 = hash_out[18*8-1:17*8];
                    15: out_1 = hash_out[17*8-1:16*8];
                    16: out_1 = hash_out[16*8-1:15*8];
                    17: out_1 = hash_out[15*8-1:14*8];
                    18: out_1 = hash_out[14*8-1:13*8];
                    19: out_1 = hash_out[13*8-1:12*8];
                    20: out_1 = hash_out[12*8-1:11*8];
                    21: out_1 = hash_out[11*8-1:10*8];
                    22: out_1 = hash_out[10*8-1:9*8];
                    23: out_1 = hash_out[9*8-1:8*8];
                    24: out_1 = hash_out[8*8-1:7*8];
                    25: out_1 = hash_out[7*8-1:6*8];
                    26: out_1 = hash_out[6*8-1:5*8];
                    27: out_1 = hash_out[5*8-1:4*8];
                    28: out_1 = hash_out[4*8-1:3*8];
                    29: out_1 = hash_out[3*8-1:2*8];
                    30: out_1 = hash_out[2*8-1:1*8];
                    default: out_1 = hash_out[1*8-1:0];
                endcase
            end else begin
                out_1 = 0;
            end
        end
    end
    
    sha256 sha256_i
    (
        .clk(clk),
        .rst(rst | rst_manual),
        .gen_hash(gen_hash_pulse),
        .load_hash(),
        .hash_in(),
        .msg(msg),
        .block_ready(block_ready),
        .hash_out(hash_out)
    );

endmodule
