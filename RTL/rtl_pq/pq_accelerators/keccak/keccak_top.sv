//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: keccak_top
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module keccak_top(
  input logic [31:0] input_state [49:0],
  input logic [4:0] round,
  input logic rst,
  output logic [31:0] output_state [49:0]

);

  keccak_f keccak_f_i
  (
    .input_state(input_state),
    .round(round),
    .rst(rst),
    .output_state(output_state)
  );
  
endmodule
