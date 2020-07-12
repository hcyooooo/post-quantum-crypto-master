/* Based on the public domain implementation in
 * crypto_hash/keccakc512/simple/ from http://bench.cr.yp.to/supercop.html
 * by Ronny Van Keer
 * and the public domain "TweetFips202" implementation
 * from https://twitter.com/tweetfips202
 * by Gilles Van Assche, Daniel J. Bernstein, and Peter Schwabe */

#include <stdint.h>
#include <assert.h>
#include "keccakf1600.h"


void KeccakF1600_StateExtractBytes(uint64_t *state, unsigned char *data, unsigned int offset, unsigned int length)
{
    unsigned int i;
    for(i=0;i<length;i++)
    {
        data[i] = state[(offset + i) >> 3] >> (8*((offset + i) & 0x07));
    }
}

void KeccakF1600_StateXORBytes(uint64_t *state, const unsigned char *data, unsigned int offset, unsigned int length)
{
    unsigned int i;
    for(i = 0; i < length; i++)
    {
        state[(offset + i) >> 3] ^= (uint64_t)data[i] << (8 * ((offset + i) & 0x07));
    }
}

void KeccakF1600_StatePermute(uint64_t * state)
{
  int round;
  asm volatile (
      "flw f0, 0(%[address_lw]) \n"
      "flw f1, 4(%[address_lw]) \n"
      "flw f2, 8(%[address_lw]) \n"
      "flw f3, 12(%[address_lw]) \n"
      "flw f4, 16(%[address_lw]) \n"
      "flw f5, 20(%[address_lw]) \n"
      "flw f6, 24(%[address_lw]) \n"
      "flw f7, 28(%[address_lw]) \n"
      "flw f8, 32(%[address_lw]) \n"
      "flw f9, 36(%[address_lw]) \n"
      "flw f10, 40(%[address_lw]) \n"
      "flw f11, 44(%[address_lw]) \n"
      "flw f12, 48(%[address_lw]) \n"
      "flw f13, 52(%[address_lw]) \n"
      "flw f14, 56(%[address_lw]) \n"
      "flw f15, 60(%[address_lw]) \n"
      "flw f16, 64(%[address_lw]) \n"
      "flw f17, 68(%[address_lw]) \n"
      "flw f18, 72(%[address_lw]) \n"
      "flw f19, 76(%[address_lw]) \n"
      "flw f20, 80(%[address_lw]) \n"
      "flw f21, 84(%[address_lw]) \n"
      "flw f22, 88(%[address_lw]) \n"
      "flw f23, 92(%[address_lw]) \n"
      "flw f24, 96(%[address_lw]) \n"
      "flw f25, 100(%[address_lw]) \n"
      "flw f26, 104(%[address_lw]) \n"
      "flw f27, 108(%[address_lw]) \n"
      "flw f28, 112(%[address_lw]) \n"
      "flw f29, 116(%[address_lw]) \n"
      "flw f30, 120(%[address_lw]) \n"
      "flw f31, 124(%[address_lw]) \n"
      "lw x5, 128(%[address_lw]) \n"
      "lw x6, 132(%[address_lw]) \n"
      "lw x7, 136(%[address_lw]) \n"
      "lw x9, 140(%[address_lw]) \n"
      "lw x18, 144(%[address_lw]) \n"
      "lw x19, 148(%[address_lw]) \n"
      "lw x20, 152(%[address_lw]) \n"
      "lw x21, 156(%[address_lw]) \n"
      "lw x22, 160(%[address_lw]) \n"
      "lw x23, 164(%[address_lw]) \n"
      "lw x24, 168(%[address_lw]) \n"
      "lw x25, 172(%[address_lw]) \n"
      "lw x26, 176(%[address_lw]) \n"
      "lw x27, 180(%[address_lw]) \n"
      "lw x28, 184(%[address_lw]) \n"
      "lw x29, 188(%[address_lw]) \n"
      "lw x30, 192(%[address_lw]) \n"
      "lw x31, 196(%[address_lw]) \n"
      "nop \n"
      "nop \n"

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

      "fsw f0, 0(%[address_lw]) \n"
      "fsw f1, 4(%[address_lw]) \n"
      "fsw f2, 8(%[address_lw]) \n"
      "fsw f3, 12(%[address_lw]) \n"
      "fsw f4, 16(%[address_lw]) \n"
      "fsw f5, 20(%[address_lw]) \n"
      "fsw f6, 24(%[address_lw]) \n"
      "fsw f7, 28(%[address_lw]) \n"
      "fsw f8, 32(%[address_lw]) \n"
      "fsw f9, 36(%[address_lw]) \n"
      "fsw f10, 40(%[address_lw]) \n"
      "fsw f11, 44(%[address_lw]) \n"
      "fsw f12, 48(%[address_lw]) \n"
      "fsw f13, 52(%[address_lw]) \n"
      "fsw f14, 56(%[address_lw]) \n"
      "fsw f15, 60(%[address_lw]) \n"
      "fsw f16, 64(%[address_lw]) \n"
      "fsw f17, 68(%[address_lw]) \n"
      "fsw f18, 72(%[address_lw]) \n"
      "fsw f19, 76(%[address_lw]) \n"
      "fsw f20, 80(%[address_lw]) \n"
      "fsw f21, 84(%[address_lw]) \n"
      "fsw f22, 88(%[address_lw]) \n"
      "fsw f23, 92(%[address_lw]) \n"
      "fsw f24, 96(%[address_lw]) \n"
      "fsw f25, 100(%[address_lw]) \n"
      "fsw f26, 104(%[address_lw]) \n"
      "fsw f27, 108(%[address_lw]) \n"
      "fsw f28, 112(%[address_lw]) \n"
      "fsw f29, 116(%[address_lw]) \n"
      "fsw f30, 120(%[address_lw]) \n"
      "fsw f31, 124(%[address_lw]) \n"
      "sw x5, 128(%[address_lw]) \n"
      "sw x6, 132(%[address_lw]) \n"
      "sw x7, 136(%[address_lw]) \n"
      "sw x9, 140(%[address_lw]) \n"
      "sw x18, 144(%[address_lw]) \n"
      "sw x19, 148(%[address_lw]) \n"
      "sw x20, 152(%[address_lw]) \n"
      "sw x21, 156(%[address_lw]) \n"
      "sw x22, 160(%[address_lw]) \n"
      "sw x23, 164(%[address_lw]) \n"
      "sw x24, 168(%[address_lw]) \n"
      "sw x25, 172(%[address_lw]) \n"
      "sw x26, 176(%[address_lw]) \n"
      "sw x27, 180(%[address_lw]) \n"
      "sw x28, 184(%[address_lw]) \n"
      "sw x29, 188(%[address_lw]) \n"
      "sw x30, 192(%[address_lw]) \n"
      "sw x31, 196(%[address_lw]) \n"
      : : [address_lw]"r" (state) : "x5", "x6", "x7", "x9", "x18", "x19", "x20", "x21", "x22", "x23", "x24", "x25", "x26", "x27", "x28", "x29", "x30", "x31", "cc","memory"
  );
}
