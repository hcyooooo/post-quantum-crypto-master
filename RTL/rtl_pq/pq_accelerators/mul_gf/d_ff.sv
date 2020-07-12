//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: d_ff
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////


module d_ff(
    input logic clk,
    input logic rst,
    input logic init,
    input logic d,
    output logic q
);

always @(posedge clk)
begin
    if (rst) begin
        q <= init;
    end else begin
        q <= d;
    end
end
endmodule
