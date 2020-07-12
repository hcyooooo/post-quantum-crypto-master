//////////////////////////////////////////////////////////////////////////////////
// Company: Technical University of Munich
// Engineer: Tim Fritzmann
// 
// Create Date: 01/27/2020
// Module Name: accelerator_config
// Project Name: Post-Quantum Cryptography
// 
//////////////////////////////////////////////////////////////////////////////////

// Set PQ active if any of the accelerators is used
`define PQ_ACTIVE

// Set accelerators of EX stage
`define HW_ACCEL_EX
//`define HW_ACCEL_EX_MULTER
//`define HW_ACCEL_EX_MODBARRETT
//`define HW_ACCEL_EX_SHA256
//`define HW_ACCEL_EX_GF
`define HW_ACCEL_EX_BINOMSAMPLE
//`define HW_ACCEL_EX_MODMULACC
`define HW_ACCEL_EX_MODMULACC_REUSE

// Set accelerators of ID stage
`define HW_ACCEL_ID
`define HW_ACCEL_ID_NTT
`define HW_ACCEL_ID_KECCAK

// Set bit reversal in LSU stage
`define HW_BITREV

`ifdef HW_ACCEL_EX
  `define HW_ACCEL_EX_OR_HW_BITREV
`elsif HW_BITREV
  `define HW_ACCEL_EX_OR_HW_BITREV
`endif
