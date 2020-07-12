#include "fips202.h"
#include "ntt.h"
#include "poly.h"
#include "reduce.h"

/*************************************************
* Name:        coeff_freeze
*
* Description: Fully reduces an integer modulo q in constant time
*
* Arguments:   uint16_t x: input integer to be reduced
*
* Returns integer in {0,...,q-1} congruent to x modulo q
**************************************************/
static uint16_t coeff_freeze(uint16_t x) {
    uint16_t m, r;
    int16_t c;
    r = x % NEWHOPE_Q;

    m = r - NEWHOPE_Q;
    c = m;
    c >>= 15;
    r = m ^ ((r ^ m)&c);

    return r;
}

/*************************************************
* Name:        flipabs
*
* Description: Computes |(x mod q) - Q/2|
*
* Arguments:   uint16_t x: input coefficient
*
* Returns |(x mod q) - Q/2|
**************************************************/
static uint16_t flipabs(uint16_t x) {
    int16_t r, m;
    r = coeff_freeze(x);

    r = r - NEWHOPE_Q / 2;
    m = r >> 15;
    return (r + m) ^ m;
}

/*************************************************
* Name:        poly_frombytes
*
* Description: De-serialization of a polynomial
*
* Arguments:   - poly *r:                pointer to output polynomial
*              - const unsigned char *a: pointer to input byte array
**************************************************/
void PQCLEAN_NEWHOPE512CCA_CLEAN_poly_frombytes(poly *r, const unsigned char *a) {
    int i;
    for (i = 0; i < NEWHOPE_N / 4; i++) {
        r->coeffs[4 * i + 0] =                               a[7 * i + 0]        | (((uint16_t)a[7 * i + 1] & 0x3f) << 8);
        r->coeffs[4 * i + 1] = (a[7 * i + 1] >> 6) | (((uint16_t)a[7 * i + 2]) << 2) | (((uint16_t)a[7 * i + 3] & 0x0f) << 10);
        r->coeffs[4 * i + 2] = (a[7 * i + 3] >> 4) | (((uint16_t)a[7 * i + 4]) << 4) | (((uint16_t)a[7 * i + 5] & 0x03) << 12);
        r->coeffs[4 * i + 3] = (a[7 * i + 5] >> 2) | (((uint16_t)a[7 * i + 6]) << 6);
    }
}

/*************************************************
* Name:        poly_tobytes
*
* Description: Serialization of a polynomial
*
* Arguments:   - unsigned char *r: pointer to output byte array
*              - const poly *p:    pointer to input polynomial
**************************************************/
void PQCLEAN_NEWHOPE512CCA_CLEAN_poly_tobytes(unsigned char *r, const poly *p) {
    int i;
    uint16_t t0, t1, t2, t3;
    for (i = 0; i < NEWHOPE_N / 4; i++) {
        t0 = coeff_freeze(p->coeffs[4 * i + 0]);
        t1 = coeff_freeze(p->coeffs[4 * i + 1]);
        t2 = coeff_freeze(p->coeffs[4 * i + 2]);
        t3 = coeff_freeze(p->coeffs[4 * i + 3]);

        r[7 * i + 0] =  t0 & 0xff;
        r[7 * i + 1] = (unsigned char) ((t0 >> 8) | (t1 << 6));
        r[7 * i + 2] = (unsigned char) ((t1 >> 2));
        r[7 * i + 3] = (unsigned char) ((t1 >> 10) | (t2 << 4));
        r[7 * i + 4] = (unsigned char) ((t2 >> 4));
        r[7 * i + 5] = (unsigned char) ((t2 >> 12) | (t3 << 2));
        r[7 * i + 6] = (unsigned char) ((t3 >> 6));
    }
}

/*************************************************
* Name:        poly_compress
*
* Description: Compression and subsequent serialization of a polynomial
*
* Arguments:   - unsigned char *r: pointer to output byte array
*              - const poly *p:    pointer to input polynomial
**************************************************/
void PQCLEAN_NEWHOPE512CCA_CLEAN_poly_compress(unsigned char *r, const poly *p) {
    unsigned int i, j, k = 0;

    uint32_t t[8];

    for (i = 0; i < NEWHOPE_N; i += 8) {
        for (j = 0; j < 8; j++) {
            t[j] = coeff_freeze(p->coeffs[i + j]);
            t[j] = (((t[j] << 3) + NEWHOPE_Q / 2) / NEWHOPE_Q) & 0x7;
        }

        r[k]   =  (unsigned char) (t[0]       | (t[1] << 3) | (t[2] << 6));
        r[k + 1] = (unsigned char) ((t[2] >> 2) | (t[3] << 1) | (t[4] << 4) | (t[5] << 7));
        r[k + 2] = (unsigned char) ((t[5] >> 1) | (t[6] << 2) | (t[7] << 5));
        k += 3;
    }
}

/*************************************************
* Name:        poly_decompress
*
* Description: De-serialization and subsequent decompression of a polynomial;
*              approximate inverse of poly_compress
*
* Arguments:   - poly *r:                pointer to output polynomial
*              - const unsigned char *a: pointer to input byte array
**************************************************/
void PQCLEAN_NEWHOPE512CCA_CLEAN_poly_decompress(poly *r, const unsigned char *a) {
    unsigned int i, j;
    for (i = 0; i < NEWHOPE_N; i += 8) {
        r->coeffs[i + 0] =  a[0] & 7;
        r->coeffs[i + 1] = (a[0] >> 3) & 7;
        r->coeffs[i + 2] = (a[0] >> 6) | ((a[1] << 2) & 4);
        r->coeffs[i + 3] = (a[1] >> 1) & 7;
        r->coeffs[i + 4] = (a[1] >> 4) & 7;
        r->coeffs[i + 5] = (a[1] >> 7) | ((a[2] << 1) & 6);
        r->coeffs[i + 6] = (a[2] >> 2) & 7;
        r->coeffs[i + 7] = (a[2] >> 5);
        a += 3;
        for (j = 0; j < 8; j++) {
            r->coeffs[i + j] = ((uint32_t)r->coeffs[i + j] * NEWHOPE_Q + 4) >> 3;
        }
    }
}

/*************************************************
* Name:        poly_frommsg
*
* Description: Convert 32-byte message to polynomial
*
* Arguments:   - poly *r:                  pointer to output polynomial
*              - const unsigned char *msg: pointer to input message
**************************************************/
void PQCLEAN_NEWHOPE512CCA_CLEAN_poly_frommsg(poly *r, const unsigned char *msg) {
    unsigned int i, j, mask;
    for (i = 0; i < NEWHOPE_SYMBYTES; i++) {
        for (j = 0; j < 8; j++) {
            mask = -((msg[i] >> j) & 1);
            r->coeffs[8 * i + j +  0] = mask & (NEWHOPE_Q / 2);
            r->coeffs[8 * i + j + 256] = mask & (NEWHOPE_Q / 2);
        }
    }
}

/*************************************************
* Name:        poly_tomsg
*
* Description: Convert polynomial to 32-byte message
*
* Arguments:   - unsigned char *msg: pointer to output message
*              - const poly *x:      pointer to input polynomial
**************************************************/
void PQCLEAN_NEWHOPE512CCA_CLEAN_poly_tomsg(unsigned char *msg, const poly *x) {
    unsigned int i;
    uint16_t t;

    for (i = 0; i < 32; i++) {
        msg[i] = 0;
    }

    for (i = 0; i < 256; i++) {
        t  = flipabs(x->coeffs[i +  0]);
        t += flipabs(x->coeffs[i + 256]);
        t = ((t - NEWHOPE_Q / 2));

        t >>= 15;
        msg[i >> 3] |= t << (i & 7);
    }
}

#define HW_POLY_UNIFORM

/*************************************************
* Name:        poly_uniform
*
* Description: Sample a polynomial deterministically from a seed,
*              with output polynomial looking uniformly random
*
* Arguments:   - poly *a:                   pointer to output polynomial
*              - const unsigned char *seed: pointer to input seed
**************************************************/
void PQCLEAN_NEWHOPE512CCA_CLEAN_poly_uniform(poly *a, const unsigned char *seed) {
    unsigned int ctr = 0;
    uint16_t val;
    shake128ctx state;
    uint8_t buf[SHAKE128_RATE];
//    uint8_t extseed[NEWHOPE_SYMBYTES + 1];
    uint8_t extseed[NEWHOPE_SYMBYTES+8];
    int i, j;

    for (i = 0; i < NEWHOPE_SYMBYTES; i++) {
        extseed[i] = seed[i];
    }

#ifdef HW_POLY_UNIFORM
    // absorb_const = 0x80000000;
    extseed[NEWHOPE_SYMBYTES+4] = 0x00;
    extseed[NEWHOPE_SYMBYTES+5] = 0x00;
    extseed[NEWHOPE_SYMBYTES+6] = 0x00;
    extseed[NEWHOPE_SYMBYTES+7] = 0x80;
    // a7 -> ctr
    // a6 -> i
    // a4 -> tmp, j
    uint32_t output_squeeze[42];
    asm volatile (
        "li a6,0 \n"  // i = 0
        "LPU0: \n" // for (i = 0; i < NEWHOPE_N / 64; i++)
            "li a4,0x1f00 \n"
            "li a7,0 \n"  // ctr = 0
            "xor a4,a4,a6 \n"  // 0x00001fXX, where XX = i
            "sw a4, 32(%[addr_extseed]) \n"  // extseed[NEWHOPE_SYMBYTES] = (unsigned char) i;
            // Absorb
            // Reset state
            "keccak.f1600 x0,x0,x1 \n"
            // Absorb input
            "flw f0, 0(%[addr_extseed]) \n"
            "flw f1, 4(%[addr_extseed]) \n"
            "flw f2, 8(%[addr_extseed]) \n"
            "flw f3, 12(%[addr_extseed]) \n"
            "flw f4, 16(%[addr_extseed]) \n"
            "flw f5, 20(%[addr_extseed]) \n"
            "flw f6, 24(%[addr_extseed]) \n"
            "flw f7, 28(%[addr_extseed]) \n"
            "flw f8, 32(%[addr_extseed]) \n"
            "lw x23, 36(%[addr_extseed]) \n"
            "nop \n"
            "nop \n"

            "LPU1: \n"  // while cntr<64
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
                "fsw f0, 0(%[addr_squeeze]) \n"
                "fsw f1, 4(%[addr_squeeze]) \n"
                "fsw f2, 8(%[addr_squeeze]) \n"
                "fsw f3, 12(%[addr_squeeze]) \n"
                "fsw f4, 16(%[addr_squeeze]) \n"
                "fsw f5, 20(%[addr_squeeze]) \n"
                "fsw f6, 24(%[addr_squeeze]) \n"
                "fsw f7, 28(%[addr_squeeze]) \n"
                "fsw f8, 32(%[addr_squeeze]) \n"
                "fsw f9, 36(%[addr_squeeze]) \n"
                "fsw f10, 40(%[addr_squeeze]) \n"
                "fsw f11, 44(%[addr_squeeze]) \n"
                "fsw f12, 48(%[addr_squeeze]) \n"
                "fsw f13, 52(%[addr_squeeze]) \n"
                "fsw f14, 56(%[addr_squeeze]) \n"
                "fsw f15, 60(%[addr_squeeze]) \n"
                "fsw f16, 64(%[addr_squeeze]) \n"
                "fsw f17, 68(%[addr_squeeze]) \n"
                "fsw f18, 72(%[addr_squeeze]) \n"
                "fsw f19, 76(%[addr_squeeze]) \n"
                "fsw f20, 80(%[addr_squeeze]) \n"
                "fsw f21, 84(%[addr_squeeze]) \n"
                "fsw f22, 88(%[addr_squeeze]) \n"
                "fsw f23, 92(%[addr_squeeze]) \n"
                "fsw f24, 96(%[addr_squeeze]) \n"
                "fsw f25, 100(%[addr_squeeze]) \n"
                "fsw f26, 104(%[addr_squeeze]) \n"
                "fsw f27, 108(%[addr_squeeze]) \n"
                "fsw f28, 112(%[addr_squeeze]) \n"
                "fsw f29, 116(%[addr_squeeze]) \n"
                "fsw f30, 120(%[addr_squeeze]) \n"
                "fsw f31, 124(%[addr_squeeze]) \n"
                "sw x5, 128(%[addr_squeeze]) \n"
                "sw x6, 132(%[addr_squeeze]) \n"
                "sw x7, 136(%[addr_squeeze]) \n"
                "sw x9, 140(%[addr_squeeze]) \n"
                "sw x18, 144(%[addr_squeeze]) \n"
                "sw x19, 148(%[addr_squeeze]) \n"
                "sw x20, 152(%[addr_squeeze]) \n"
                "sw x21, 156(%[addr_squeeze]) \n"
                "sw x22, 160(%[addr_squeeze]) \n"
                "sw x23, 164(%[addr_squeeze]) \n"

                "li a4,0 \n" // j=0
                "li a3,64 \n"  // 64
//                "li a5,0 \n"  // coeff
                "LPU2: \n"
                    "li a5,0 \n"  // coeff
                    "p.lh a5,a4(%[addr_squeeze]) \n"
                    "nop \n"
                    "li a2, 0xffff \n"
                    "and a5,a5,a2 \n"
                    "li a2,61445 \n"  // 5*NEWHOPE_Q (0xF005)
                    "bgeu a5,a2,LPUIF \n"  // if(val < 5 * NEWHOPE_Q)
                        "p.sh a5,2(%[addr_coeffs]!) \n"
                        "addi a7,a7,1 \n"  // ctr++
                    "LPUIF: \n"
                    "addi a4,a4,2 \n"  // j=j+2
                    "li a2,168 \n"  // SHAKE128_RATE (0xA8)
                    "beq a4,a2,LPU3 \n"  // while j < SHAKE128_RATE
                    "blt a7,a3, LPU2 \n"  // for ctr < 64

                "LPU3: \n"      
            "blt a7,a3,LPU1 \n"  // while cntr<64

            "addi a6,a6,1 \n"  // i++
        "p.bneimm a6,8,LPU0 \n"  //  for (i = 0; i < NEWHOPE_N / 64; i++)
        "nop \n"
        : : [addr_extseed]"r" (extseed), [addr_squeeze]"r" (output_squeeze), [addr_coeffs]"r" (a->coeffs) : "a2","a3","a4","a5","a6","a7","t0","t1","t2","t3","t4","t5","t6","s1","s2","s3","s4","s5","s6","s7","s8","s9","s10","s11","cc","memory"   
    );

#else // HW_POLY_UNIFORM not defined
    for (i = 0; i < NEWHOPE_N / 64; i++) { // generate a in blocks of 64 coefficients
        ctr = 0;
        extseed[NEWHOPE_SYMBYTES] = (unsigned char) i; // domain-separate the 16 independent calls
        shake128_absorb(&state, extseed, NEWHOPE_SYMBYTES + 1);
        while (ctr < 64) { // Very unlikely to run more than once
            shake128_squeezeblocks(buf, 1, &state);
            for (j = 0; j < SHAKE128_RATE && ctr < 64; j += 2) {
                val = (buf[j] | ((uint16_t) buf[j + 1] << 8));
                if (val < 5 * NEWHOPE_Q) {
                    a->coeffs[i * 64 + ctr] = val;
                    ctr++;
                }
            }
        }
    }
#endif
}


#define HW_MODULO

/*************************************************
* Name:        poly_pointwise
*
* Description: Multiply two polynomials pointwise (i.e., coefficient-wise).
*
* Arguments:   - poly *r:       pointer to output polynomial
*              - const poly *a: pointer to first input polynomial
*              - const poly *b: pointer to second input polynomial
**************************************************/
void PQCLEAN_NEWHOPE512CCA_CLEAN_poly_mul_pointwise(poly *r, const poly *a, const poly *b) {
#ifdef HW_MODULO
    volatile uint32_t c=0x0C720C72; // R^2 mod 12289 packed in lower and higher halfword
    asm volatile (
        "pq.set_newhope512 x0,x0,x0 \n"  // set q
        // Mod add
        "lp.setupi x0, 256, (.loop_m)\n"
            "lw t0,0(%[addra]) \n"
            "lw t1,0(%[addrconst]) \n"
            "addi %[addra],%[addra],4 \n"
            "nop \n"
            "pq.mod_mul_r x0,t0,t1 \n"  // turn a into motgomery domain
            "lw t1,0(%[addrb]) \n"
            "addi %[addrb],%[addrb],4 \n"
            "nop \n"
            "pq.mod_mul_r x0,t0,t1 \n"
            "p.sw t0,4(%[addrc]!) \n"
        ".loop_m:\n"
        "nop\n"
        : : [addra]"r" (a->coeffs), [addrb]"r" (b->coeffs), [addrc]"r" (r->coeffs), [addrconst]"r" (&c) : "cc","memory"   
    );
#else
    int i;
    uint16_t t;
    for (i = 0; i < NEWHOPE_N; i++) {
        t            = PQCLEAN_NEWHOPE512CCA_CLEAN_montgomery_reduce(3186 * b->coeffs[i]); /* t is now in Montgomery domain */
        r->coeffs[i] = PQCLEAN_NEWHOPE512CCA_CLEAN_montgomery_reduce(a->coeffs[i] * t);  /* r->coeffs[i] is back in normal domain */
    }
#endif
}

/*************************************************
* Name:        poly_add
*
* Description: Add two polynomials
*
* Arguments:   - poly *r:       pointer to output polynomial
*              - const poly *a: pointer to first input polynomial
*              - const poly *b: pointer to second input polynomial
**************************************************/
void PQCLEAN_NEWHOPE512CCA_CLEAN_poly_add(poly *r, const poly *a, const poly *b) {
#ifdef HW_MODULO
    asm volatile (
        "pq.set_newhope512 x0,x0,x0 \n"  // set q
        // Mod add
        "lp.setupi x0, 256, (.loop_a)\n"
            "lw t0,0(%[addra]) \n"
            "lw t1,0(%[addrb]) \n"
            "addi %[addra],%[addra],4 \n"
            "addi %[addrb],%[addrb],4 \n"
            "pq.mod_add_r x0,t0,t1 \n"
            "p.sw t0,4(%[addrc]!) \n"
        ".loop_a:\n"
        "nop\n"
        : : [addra]"r" (a->coeffs), [addrb]"r" (b->coeffs), [addrc]"r" (r->coeffs) : "cc","memory" 
    );
#else
    int i;
    for (i = 0; i < NEWHOPE_N; i++) {
        r->coeffs[i] = (a->coeffs[i] + b->coeffs[i]) % NEWHOPE_Q;
    }
#endif
}

/*************************************************
* Name:        poly_sub
*
* Description: Subtract two polynomials
*
* Arguments:   - poly *r:       pointer to output polynomial
*              - const poly *a: pointer to first input polynomial
*              - const poly *b: pointer to second input polynomial
**************************************************/
void PQCLEAN_NEWHOPE512CCA_CLEAN_poly_sub(poly *r, const poly *a, const poly *b) {
#ifdef HW_MODULO
    asm volatile (
        "pq.set_newhope512 x0,x0,x0 \n"  // set q
        // Mod sub
        "lp.setupi x0, 256, (.loop_s)\n"
            "lw t0,0(%[addra]) \n"
            "lw t1,0(%[addrb]) \n"
            "addi %[addra],%[addra],4 \n"
            "addi %[addrb],%[addrb],4 \n"
            "pq.mod_sub_r x0,t0,t1 \n"
            "p.sw t0,4(%[addrc]!) \n"
        ".loop_s:\n"
        "nop\n"
        : : [addra]"r" (a->coeffs), [addrb]"r" (b->coeffs), [addrc]"r" (r->coeffs) : "cc","memory"   
    );
#else
    int i;
    for (i = 0; i < NEWHOPE_N; i++) {
        r->coeffs[i] = (a->coeffs[i] + 3 * NEWHOPE_Q - b->coeffs[i]) % NEWHOPE_Q;
    }
#endif
}

/*************************************************
* Name:        poly_ntt
*
* Description: Forward NTT transform of a polynomial in place
*              Input is assumed to have coefficients in bitreversed order
*              Output has coefficients in normal order
*
* Arguments:   - poly *r: pointer to in/output polynomial
**************************************************/
void PQCLEAN_NEWHOPE512CCA_CLEAN_poly_ntt(poly *pol_in, poly *pol_out) {
    PQCLEAN_NEWHOPE512CCA_CLEAN_ntt((uint16_t *)pol_in->coeffs, (uint16_t *)pol_out->coeffs);
}

/*************************************************
* Name:        poly_invntt
*
* Description: Inverse NTT transform of a polynomial in place
*              Input is assumed to have coefficients in normal order
*              Output has coefficients in normal order
*
* Arguments:   - poly *r: pointer to in/output polynomial
**************************************************/
void PQCLEAN_NEWHOPE512CCA_CLEAN_poly_invntt(poly *pol_in, poly *pol_out) { // Actual output in pol_in
    PQCLEAN_NEWHOPE512CCA_CLEAN_bitrev_vector(pol_in->coeffs, pol_out->coeffs);
    PQCLEAN_NEWHOPE512CCA_CLEAN_invntt((uint16_t *)pol_out->coeffs, (uint16_t *)pol_in->coeffs);
}

