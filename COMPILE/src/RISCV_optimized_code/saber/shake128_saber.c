#include <stddef.h>
#include <stdint.h>
#include "shake128_saber.h"

//////////////////// HW support Saber ////////////////////
/*************************************************
 * Name:        shake128_saber
 *
 * Description: shake128_saber XOF with non-incremental API
 *
 * Arguments:   - uint8_t *output:      pointer to output
 *              - size_t outlen:        requested output length in bytes
 *              - const uint8_t *input: pointer to input
 *              - size_t inlen:         length of input in bytes
 **************************************************/
void shake128_saber(uint8_t *output, size_t outlen, const uint8_t *input, size_t inlen)
{
  // Prepare input to absorb
  uint32_t input_absorb[10];
  uint32_t output_squeeze[34];

//  uint32_t nblocks;
//  nblocks = outlen/1344*8;

  for (int i = 0; i < 8; i++) {
    input_absorb[i] = (input[(i<<2)+3]<<24) ^ (input[(i<<2)+2]<<16) ^ (input[(i<<2)+1]<<8) ^ input[(i<<2)];
  }
  
  if (inlen == 32)
    input_absorb[8] = 0x1F;
  else  // inlen == 34
    input_absorb[8] = (0x1F<<16) ^ (input[33]<<8) ^ input[32];

  input_absorb[9] = 0x80000000;

  asm volatile(
      // Reset state
      "addi a6,%[o_len],0 \n"
      "keccak.f1600 x0,x0,x1 \n"
      // Absorb input
      "flw f0, 0(%[address_lw]) \n"
      "flw f1, 4(%[address_lw]) \n"
      "flw f2, 8(%[address_lw]) \n"
      "flw f3, 12(%[address_lw]) \n"
      "flw f4, 16(%[address_lw]) \n"
      "flw f5, 20(%[address_lw]) \n"
      "flw f6, 24(%[address_lw]) \n"
      "flw f7, 28(%[address_lw]) \n"
      "flw f8, 32(%[address_lw]) \n"
      "lw x23, 36(%[address_lw]) \n"
      "nop \n"
      "nop \n"
      // a7 -> ctr
      // a6 -> KYBER_N
      // a2 -> KYBER_Q
      ////////
      "li a6,0 \n" // ctr = 0
      ".LPU1%=: \n"  // while (ctr < KYBER_N)
          "keccak.f1600 x0,x0,x0 \n"
          "keccak.f1600 x0,x1,x0 \n"
          "keccak.f1600 x0,x2,x0 \n"
          "keccak.f1600 x0,x3,x0 \n"
          "keccak.f1600 x0,x4,x0 \n"
          "keccak.f1600 x0,x5,x0 \n"
          "keccak.f1600 x0,x6,x0 \n"
          "keccak.f1600 x0,x7,x0 \n"
          "keccak.f1600 x0,x8,x0 \n"
          "keccak.f1600 x0,x9,x0 \n"
          "keccak.f1600 x0,x10,x0 \n"
          "keccak.f1600 x0,x11,x0 \n"
          "keccak.f1600 x0,x12,x0 \n"
          "keccak.f1600 x0,x13,x0 \n"
          "keccak.f1600 x0,x14,x0 \n"
          "keccak.f1600 x0,x15,x0 \n"
          "keccak.f1600 x0,x16,x0 \n"
          "keccak.f1600 x0,x17,x0 \n"
          "keccak.f1600 x0,x18,x0 \n"
          "keccak.f1600 x0,x19,x0 \n"
          "keccak.f1600 x0,x20,x0 \n"
          "keccak.f1600 x0,x21,x0 \n"
          "keccak.f1600 x0,x22,x0 \n"
          "keccak.f1600 x0,x23,x0 \n"
          // Squeeze output
          "fsw f0, 0(%[address_sw]) \n"
          "fsw f1, 4(%[address_sw]) \n"
          "fsw f2, 8(%[address_sw]) \n"
          "fsw f3, 12(%[address_sw]) \n"
          "fsw f4, 16(%[address_sw]) \n"
          "fsw f5, 20(%[address_sw]) \n"
          "fsw f6, 24(%[address_sw]) \n"
          "fsw f7, 28(%[address_sw]) \n"
          "fsw f8, 32(%[address_sw]) \n"
          "fsw f9, 36(%[address_sw]) \n"
          "fsw f10, 40(%[address_sw]) \n"
          "fsw f11, 44(%[address_sw]) \n"
          "fsw f12, 48(%[address_sw]) \n"
          "fsw f13, 52(%[address_sw]) \n"
          "fsw f14, 56(%[address_sw]) \n"
          "fsw f15, 60(%[address_sw]) \n"
          "fsw f16, 64(%[address_sw]) \n"
          "fsw f17, 68(%[address_sw]) \n"
          "fsw f18, 72(%[address_sw]) \n"
          "fsw f19, 76(%[address_sw]) \n"
          "fsw f20, 80(%[address_sw]) \n"
          "fsw f21, 84(%[address_sw]) \n"
          "fsw f22, 88(%[address_sw]) \n"
          "fsw f23, 92(%[address_sw]) \n"
          "fsw f24, 96(%[address_sw]) \n"
          "fsw f25, 100(%[address_sw]) \n"
          "fsw f26, 104(%[address_sw]) \n"
          "fsw f27, 108(%[address_sw]) \n"
          "fsw f28, 112(%[address_sw]) \n"
          "fsw f29, 116(%[address_sw]) \n"
          "fsw f30, 120(%[address_sw]) \n"
          "fsw f31, 124(%[address_sw]) \n"
          "sw x5, 128(%[address_sw]) \n"
          "sw x6, 132(%[address_sw]) \n"
          "sw x7, 136(%[address_sw]) \n"
          "sw x9, 140(%[address_sw]) \n"
          "sw x18, 144(%[address_sw]) \n"
          "sw x19, 148(%[address_sw]) \n"
          "sw x20, 152(%[address_sw]) \n"
          "sw x21, 156(%[address_sw]) \n"
          "sw x22, 160(%[address_sw]) \n"
          "sw x23, 164(%[address_sw]) \n"
          "addi %[address_sw],%[address_sw],168 \n"
          "addi a6,a6,168 \n"
          "blt a6,%[o_len],.LPU1%= \n"  // while cntr<nblocks
    : : [address_lw]"r" (input_absorb), [address_sw]"r" (output), [o_len]"r" (outlen) : "x5", "x6", "x7", "x9", "x18", "x19", "x20", "x21", "x22", "x23", "x24", "x25", "x26", "x27", "x28", "x29", "x30", "x31", "cc","memory"
  );

/*  for (int i = 0; i < outlen; i=i+4) {
    output[i] = (uint8_t) output_squeeze[i>>2];
    output[i+1] = (uint8_t) (output_squeeze[i>>2]>>8);
    output[i+2] = (uint8_t) (output_squeeze[i>>2]>>16);
    output[i+3] = (uint8_t) (output_squeeze[i>>2]>>24);
  }
*/
}
