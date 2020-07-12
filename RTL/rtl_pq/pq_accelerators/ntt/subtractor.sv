//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: subtractor
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module subtractor
#(
  parameter DATA_WIDTH = 16
)
(
  input logic [DATA_WIDTH-1:0] modulus,
  input logic [DATA_WIDTH-1:0] in1,
  input logic [DATA_WIDTH-1:0] in2,
  output logic [DATA_WIDTH-1:0] result
);

  logic [DATA_WIDTH-1:0] tmp1, tmp2;
  assign tmp1 = (in1 + modulus) - in2;
  assign tmp2 = tmp1-modulus;
  assign result = (tmp1 < modulus) ? tmp1 : tmp2;

endmodule
