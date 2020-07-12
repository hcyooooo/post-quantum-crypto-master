#include "fips202.h"
#include "symmetric.h"

#include <stdlib.h>
/*************************************************
* Name:        kyber_shake128_absorb
*
* Description: Absorb step of the SHAKE128 specialized for the Kyber context.

* Arguments:   - keccak_state *s:           pointer to (uninitialized) output Keccak state
*              - const uint8_t *input:      pointer to KYBER_SYMBYTES input to be absorbed into s
*              - uint8_t i                  additional byte of input
*              - uint8_t j                  additional byte of input
**************************************************/
void PQCLEAN_KYBER1024_CLEAN_kyber_shake128_absorb(keccak_state *s, const uint8_t *input, uint8_t x, uint8_t y) {
    size_t i;
    uint8_t extseed[KYBER_SYMBYTES + 2];

    for (i = 0; i < KYBER_SYMBYTES; i++) {
        extseed[i] = input[i];
    }
    extseed[i++] = x;
    extseed[i]   = y;
    shake128_absorb(s, extseed, KYBER_SYMBYTES + 2);
}

/*************************************************
* Name:        kyber_shake128_squeezeblocks
*
* Description: Squeeze step of SHAKE128 XOF. Squeezes full blocks of SHAKE128_RATE bytes each.
*              Modifies the state. Can be called multiple times to keep squeezing,
*              i.e., is incremental.
*
* Arguments:   - uint8_t *output:            pointer to output blocks
*              - unsigned long long nblocks: number of blocks to be squeezed (written to output)
*              - keccak_state *s:            pointer to in/output Keccak state
**************************************************/
void PQCLEAN_KYBER1024_CLEAN_kyber_shake128_squeezeblocks(uint8_t *output, size_t nblocks, keccak_state *s) {
    shake128_squeezeblocks(output, nblocks, s);
}

void shake256_hw2(uint8_t *output, size_t outlen, const uint8_t *input, size_t inlen);
/*************************************************
* Name:        shake256_prf
*
* Description: Usage of SHAKE256 as a PRF, concatenates secret and public input
*              and then generates outlen bytes of SHAKE256 output
*
* Arguments:   - uint8_t *output:      pointer to output
*              - size_t outlen:        number of requested output bytes
*              - const uint8_t * key:  pointer to the key (of length KYBER_SYMBYTES)
*              - const uint8_t nonce:  single-byte nonce (public PRF input)
**************************************************/
void PQCLEAN_KYBER1024_CLEAN_shake256_prf(uint8_t *output, size_t outlen, const uint8_t *key, uint8_t nonce) {
    uint8_t extkey[KYBER_SYMBYTES + 1];
    size_t i;

    for (i = 0; i < KYBER_SYMBYTES; i++) {
        extkey[i] = key[i];
    }
    extkey[i] = nonce;

    shake256_hw2(output, outlen, extkey, KYBER_SYMBYTES + 1);
}

//////////////////// HW support ////////////////////
/*************************************************
 * Name:        shake256
 *
 * Description: SHAKE256 XOF with non-incremental API
 *
 * Arguments:   - uint8_t *output:      pointer to output
 *              - size_t outlen:        requested output length in bytes
 *              - const uint8_t *input: pointer to input
 *              - size_t inlen:         length of input in bytes
 **************************************************/
void shake256_hw2(uint8_t *output, size_t outlen,
    const uint8_t *input, size_t inlen)
{
  // Prepare input to absorb
  uint32_t input_absorb[10];
  uint32_t output_squeeze[34];

  for (int i = 0; i < 8; i++) {
    input_absorb[i] = (input[(i<<2)+3]<<24) ^ (input[(i<<2)+2]<<16) ^ (input[(i<<2)+1]<<8) ^ input[(i<<2)];
  }
  
  if (inlen == 32)
    input_absorb[8] = 0x1F;
  else if (inlen == 33)
    input_absorb[8] = (0x1F<<8) ^ input[32];
  else  // inlen == 34
    input_absorb[8] = (0x1F<<16) ^ (input[33]<<8) ^ input[32];

  input_absorb[9] = 0x80000000;

  asm volatile(
      // Reset state
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
      "lw x6, 36(%[address_lw]) \n"
      "nop \n"
      "nop \n"
      // Perform permutation
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
    : : [address_lw]"r" (input_absorb), [address_sw]"r" (output_squeeze) : "x5", "x6", "x7", "x9", "x18", "x19", "x20", "x21", "x22", "x23", "x24", "x25", "x26", "x27", "x28", "x29", "x30", "x31", "cc","memory"
  );

    
  for (int i = 0; i < outlen; i=i+4) {
    output[i] = (uint8_t) output_squeeze[i>>2];
    output[i+1] = (uint8_t) (output_squeeze[i>>2]>>8);
    output[i+2] = (uint8_t) (output_squeeze[i>>2]>>16);
    output[i+3] = (uint8_t) (output_squeeze[i>>2]>>24);
  }


#ifdef PROFILE_HASHING
  uint64_t t1 = hal_get_time();
  hash_cycles += (t1-t0);
#endif
}
