#include "inttypes.h"
#include "ntt.h"
#include "params.h"
#include "reduce.h"

/*************************************************
* Name:        bitrev_vector
*
* Description: Permutes coefficients of a polynomial into bitreversed order
*
* Arguments:   - uint16_t* poly: pointer to in/output polynomial
**************************************************/
void PQCLEAN_NEWHOPE1024CCA_CLEAN_bitrev_vector(uint16_t *pol_in, uint16_t *pol_out) {
    unsigned int i, r;
    uint16_t tmp;

    asm volatile (
        "li s1,0 \n"
        "li s2,1024 \n"
        ".LBR00: \n"
            "p.lh s3,2(%[l_address]!) \n"
            "pq.sh_br1024 s1,%[s_address],s3 \n"
            "addi s1,s1,1 \n" // j=j+1
            "blt s1,s2, .LBR00 \n"
        : : [l_address]"r" (pol_in), [s_address]"r" (pol_out) : "s1", "s2", "s3", "cc","memory"
    );
}

/*************************************************
* Name:        mul_coefficients
*
* Description: Performs pointwise (coefficient-wise) multiplication
*              of two polynomials
* Arguments:   - uint16_t* poly:          pointer to in/output polynomial
*              - const uint16_t* factors: pointer to input polynomial, coefficients
*                                         are assumed to be in Montgomery representation
**************************************************/
void PQCLEAN_NEWHOPE1024CCA_CLEAN_mul_coefficients(uint16_t *poly, const uint16_t *factors) {
    unsigned int i;

    for (i = 0; i < NEWHOPE_N; i++) {
        poly[i] = PQCLEAN_NEWHOPE1024CCA_CLEAN_montgomery_reduce((poly[i] * factors[i]));
    }
}

void ntt_asm_loop(uint16_t *pol_a)
{
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
        "pq.set_newhope1024 x0,x0,x0 \n"  // set scheme
        "pq.ntt_multiple_bf x0,x0,x0 \n"  // activate multiple bf

        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"

        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"

        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"

        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"

        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"

        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"

        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"

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

        : : [address_lw]"r" (pol_a) : "cc","memory"
    );
}

/*************************************************
* Name:        ntt
*
* Description: Computes number-theoretic transform (NTT) of
*              a polynomial in place; inputs assumed to be in
*              bitreversed order, output in normal order
*
* Arguments:   - uint16_t * pol_in:          pointer to in/output polynomial
**************************************************/
void PQCLEAN_NEWHOPE1024CCA_CLEAN_ntt(uint16_t *pol_in, uint16_t *pol_out) {
    asm volatile(
      "pq.set_first_rounds x0,x0,x0 \n"  // first rounds
      "pq.set_fwd_ntt x0,x0,x0 \n"  // set fwdntt
      "pq.update_m x0,x0,x0 \n"  // index = 0
      "pq.update_m x0,x0,x0 \n"  // index = 0
    );
    // Hardware optimized loop for shorter distances
    ntt_asm_loop(pol_in);
    ntt_asm_loop(pol_in+32*2);
    ntt_asm_loop(pol_in+32*4);
    ntt_asm_loop(pol_in+32*6);

    ntt_asm_loop(pol_in+32*8);
    ntt_asm_loop(pol_in+32*10);
    ntt_asm_loop(pol_in+32*12);
    ntt_asm_loop(pol_in+32*14);

    ntt_asm_loop(pol_in+32*16);
    ntt_asm_loop(pol_in+32*18);
    ntt_asm_loop(pol_in+32*20);
    ntt_asm_loop(pol_in+32*22);

    ntt_asm_loop(pol_in+32*24);
    ntt_asm_loop(pol_in+32*26);
    ntt_asm_loop(pol_in+32*28);
    ntt_asm_loop(pol_in+32*30);

    // Remaining loops
    // Remaining loops
    asm volatile
    (
        ///////////////////
        // s1 = n -> 1024
        // s2 = m -> 64
        // s3 = j -> 0
        // s4 = k -> 0
        // s5 = address_lw1_final (pol_in+(k+j)*4)
        // s6 = address_lw2_final (pol_in+(k+j+m/2)*4)
        // s7 = n/2
        // s8 = m/2
        ///////////////////

        ///////////////////
        //// Index = 5 ////
        "pq.update_m x0,x5,x0 \n"  // index = 5
        "pq.update_m x0,x5,x0 \n"  // index = 5
        "li s1, 1024 \n" // n=1024
        "li s2, 64 \n"  // m=64
        "li s3, 0 \n"   // j=0
        "li s4, 0 \n"   // k=0
        "li s7, 512 \n" // s7=n/2
        "li s8, 32 \n"  // s8=m/2        

//        ".L020: \n"  // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s8,(.L020)\n" // outer loop
//
            ".L010: \n"  // for(int k=0; k<n/2; k=k+m)
                // Calculate addresses
                "add s5, s3, s4 \n"  // s5 = j+k
                "srli s6, s2, 1 \n"  // s6 = m/2
                "add s6, s6, s5 \n"  // s6 = j+k+m/2
                "slli s5, s5, 2 \n"  // s5 = (j+k)*4
                "slli s6, s6, 2 \n"  // s6 = (j+k+m/2)*4
                "add s5, s5, %[address_reg] \n"  // s5 = pol_in+(k+j)*4
                "add s6, s6, %[address_reg] \n"  // s6 = pol_in+(k+j+m/2)*4
                // Perform butterfly
                "flw f0, 0(s5) \n"
                "flw f1, 0(s6) \n"
                "nop \n"
                "nop \n"
                "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
                "fsw f0, 0(s5) \n"
                "fsw f1, 0(s6) \n"

            "add s4,s4,s2 \n" // k=k+m
            "blt s4,s7, .L010 \n"
        "li s4, 0 \n"   // k=0, reset counter
        "pq.update_omega x0,x0,x0 \n"  // update_omega
        "addi s3,s3,1 \n" // j=j+1
//        "blt s3,s8, .L020 \n"
        ".L020: \n"
        "nop \n"
//
        "li s3, 0 \n"   // j=0, reset counter     

        ///////////////////
        //// Index = 6 ////
        "pq.update_m x0,x6,x0 \n"  // index = 6
        "pq.update_m x0,x6,x0 \n"  // index = 6
        "li s2, 128 \n"  // m=128
        "li s8, 64 \n"  // s8=m/2        

//        ".L021: \n"  // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s8,(.L021)\n" // outer loop
//
            ".L011: \n"  // for(int k=0; k<n/2; k=k+m)
                // Calculate addresses
                "add s5, s3, s4 \n"  // s5 = j+k
                "srli s6, s2, 1 \n"  // s6 = m/2
                "add s6, s6, s5 \n"  // s6 = j+k+m/2
                "slli s5, s5, 2 \n"  // s5 = (j+k)*4
                "slli s6, s6, 2 \n"  // s6 = (j+k+m/2)*4
                "add s5, s5, %[address_reg] \n"  // s5 = pol_in+(k+j)*4
                "add s6, s6, %[address_reg] \n"  // s6 = pol_in+(k+j+m/2)*4
                // Perform butterfly
                "flw f0, 0(s5) \n"
                "flw f1, 0(s6) \n"
                "nop \n"
                "nop \n"
                "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
                "fsw f0, 0(s5) \n"
                "fsw f1, 0(s6) \n"

            "add s4,s4,s2 \n" // k=k+m
            "blt s4,s7, .L011 \n"
        "li s4, 0 \n"   // k=0, reset counter
        "pq.update_omega x0,x0,x0 \n"  // update_omega
        "addi s3,s3,1 \n" // j=j+1
//        "blt s3,s8, .L021 \n"
        ".L021: \n"
        "nop \n"
//
        "li s3, 0 \n"   // j=0, reset counter

        ///////////////////
        //// Index = 7 ////
        "pq.update_m x0,x7,x0 \n"  // index = 7
        "pq.update_m x0,x7,x0 \n"  // index = 7
        "li s2, 256 \n"  // m=256
        "li s8, 128 \n" // s8=m/2        

//        ".L022: \n"  // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s8,(.L022)\n" // outer loop
//
            ".L012: \n"  // for(int k=0; k<n/2; k=k+m)
                // Calculate addresses
                "add s5, s3, s4 \n"  // s5 = j+k
                "srli s6, s2, 1 \n"  // s6 = m/2
                "add s6, s6, s5 \n"  // s6 = j+k+m/2
                "slli s5, s5, 2 \n"  // s5 = (j+k)*4
                "slli s6, s6, 2 \n"  // s6 = (j+k+m/2)*4
                "add s5, s5, %[address_reg] \n"  // s5 = pol_in+(k+j)*4
                "add s6, s6, %[address_reg] \n"  // s6 = pol_in+(k+j+m/2)*4
                // Perform butterfly
                "flw f0, 0(s5) \n"
                "flw f1, 0(s6) \n"
                "nop \n"
                "nop \n"
                "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
                "fsw f0, 0(s5) \n"
                "fsw f1, 0(s6) \n"

            "add s4,s4,s2 \n" // k=k+m
            "blt s4,s7, .L012 \n"
        "li s4, 0 \n"   // k=0, reset counter
        "pq.update_omega x0,x0,x0 \n"  // update_omega
        "addi s3,s3,1 \n" // j=j+1
//        "blt s3,s8, .L022 \n"
        ".L022: \n"
        "nop \n"
//
        "li s3, 0 \n"   // j=0, reset counter

        ///////////////////
        //// Index = 8 ////
        "pq.update_m x0,x8,x0 \n"  // index = 8
        "pq.update_m x0,x8,x0 \n"  // index = 8
        "li s2, 512 \n"  // m=512
        "li s8, 256 \n" // s8=m/2        

//        ".L023: \n"  // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s8,(.L023)\n" // outer loop
//
            ".L013: \n"  // for(int k=0; k<n/2; k=k+m)
                // Calculate addresses
                "add s5, s3, s4 \n"  // s5 = j+k
                "srli s6, s2, 1 \n"  // s6 = m/2
                "add s6, s6, s5 \n"  // s6 = j+k+m/2
                "slli s5, s5, 2 \n"  // s5 = (j+k)*4
                "slli s6, s6, 2 \n"  // s6 = (j+k+m/2)*4
                "add s5, s5, %[address_reg] \n"  // s5 = pol_in+(k+j)*4
                "add s6, s6, %[address_reg] \n"  // s6 = pol_in+(k+j+m/2)*4
                // Perform butterfly
                "flw f0, 0(s5) \n"
                "flw f1, 0(s6) \n"
                "nop \n"
                "nop \n"
                "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
                "fsw f0, 0(s5) \n"
                "fsw f1, 0(s6) \n"

            "add s4,s4,s2 \n" // k=k+m
            "blt s4,s7, .L013 \n"
        "li s4, 0 \n"   // k=0, reset counter
        "pq.update_omega x0,x0,x0 \n"  // update_omega
        "addi s3,s3,1 \n" // j=j+1
//        "blt s3,s8, .L023 \n"
        ".L023: \n"
        "nop \n"
//
        "li s3, 0 \n"   // j=0, reset counter
  

        ///////////////////
        //// Index = 9 ////
        // Activate last round
        "pq.set_last_round x0,x0,x0 \n"  // last round
        "pq.update_m x0,x9,x0 \n"  // index = 9
        "pq.update_m x0,x9,x0 \n"  // index = 9
        "li s2, 1024 \n"  // m=1024
        "li s8, 512 \n"  // s8=m/2        

//        ".L024: \n"  // for(int j=0; j<m/2; j=j+2)
        "lp.setupi  x1,256,(.L024)\n" // outer loop
//
                // Calculate addresses
                "addi s6, s3, 1 \n"  // s6 = j+1
                "slli s5, s3, 2 \n"  // s5 = (j)*4
                "slli s6, s6, 2 \n"  // s6 = (j+1)*4
                "add s5, s5, %[address_reg] \n"  // s5 = pol_in+(j)*4
                "add s6, s6, %[address_reg] \n"  // s6 = pol_in+(j+1)*4
                // Perform butterfly
                "flw f0, 0(s5) \n"
                "flw f1, 0(s6) \n"
                "pq.update_omega x0,x0,x0 \n"  // update_omega
                "nop \n"
                "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
                "fsw f0, 0(%[address_out]) \n"
                "fsw f1, 1024(%[address_out]) \n"
                // Update store address
                "addi %[address_out],%[address_out],4 \n"              
        "pq.update_omega x0,x0,x0 \n"  // update_omega
        "addi s3,s3,2 \n" // j=j+2
//        "blt s3,s8, .L024 \n"
        ".L024: \n"
        "nop \n"
//
    : : [address_reg]"r" (pol_in), [address_out]"r" (pol_out) : "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "cc","memory"
    );
}

void PQCLEAN_NEWHOPE1024CCA_CLEAN_invntt(uint16_t *pol_in, uint16_t *pol_out) {
    asm volatile(
      "pq.set_first_rounds x0,x0,x0 \n"  // first rounds
      "pq.set_inv_ntt x0,x0,x0 \n"  // set invntt
      "pq.update_m x0,x0,x0 \n"  // index = 0
      "pq.update_m x0,x0,x0 \n"  // index = 0
    );

    // Hardware optimized loop for shorter distances
    ntt_asm_loop(pol_in);
    ntt_asm_loop(pol_in+32*2);
    ntt_asm_loop(pol_in+32*4);
    ntt_asm_loop(pol_in+32*6);

    ntt_asm_loop(pol_in+32*8);
    ntt_asm_loop(pol_in+32*10);
    ntt_asm_loop(pol_in+32*12);
    ntt_asm_loop(pol_in+32*14);

    ntt_asm_loop(pol_in+32*16);
    ntt_asm_loop(pol_in+32*18);
    ntt_asm_loop(pol_in+32*20);
    ntt_asm_loop(pol_in+32*22);

    ntt_asm_loop(pol_in+32*24);
    ntt_asm_loop(pol_in+32*26);
    ntt_asm_loop(pol_in+32*28);
    ntt_asm_loop(pol_in+32*30);

    // Remaining loops
    asm volatile
    (
        ///////////////////
        // s1 = n -> 1024
        // s2 = m -> 64
        // s3 = j -> 0
        // s4 = k -> 0
        // s5 = address_lw1_final (pol_in+(k+j)*4)
        // s6 = address_lw2_final (pol_in+(k+j+m/2)*4)
        // s7 = n/2
        // s8 = m/2
        ///////////////////
        ///////////////////
        //// Index = 5 ////
        "pq.update_m x0,x5,x0 \n"  // index = 5
        "pq.update_m x0,x5,x0 \n"  // index = 5
        "li s1, 1024 \n" // n=1024
        "li s2, 64 \n"  // m=64
        "li s3, 0 \n"   // j=0
        "li s4, 0 \n"   // k=0
        "li s7, 512 \n" // s7=n/2
        "li s8, 32 \n" // s8=m/2        

//        ".L120: \n"  // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s8,(.L120)\n" // outer loop
//
            ".L110: \n"  // for(int k=0; k<n/2; k=k+m)
                // Calculate addresses
                "add s5, s3, s4 \n"  // s5 = j+k
                "srli s6, s2, 1 \n"  // s6 = m/2
                "add s6, s6, s5 \n"  // s6 = j+k+m/2
                "slli s5, s5, 2 \n"  // s5 = (j+k)*4
                "slli s6, s6, 2 \n"  // s6 = (j+k+m/2)*4
                "add s5, s5, %[address_reg] \n"  // s5 = pol_in+(k+j)*4
                "add s6, s6, %[address_reg] \n"  // s6 = pol_in+(k+j+m/2)*4
                // Perform butterfly
                "flw f0, 0(s5) \n"
                "flw f1, 0(s6) \n"
                "nop \n"
                "nop \n"
                "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
                "fsw f0, 0(s5) \n"
                "fsw f1, 0(s6) \n"

            "add s4,s4,s2 \n" // k=k+m
            "blt s4,s7, .L110 \n"
        "li s4, 0 \n"   // k=0, reset counter
        "pq.update_omega x0,x0,x0 \n"  // update_omega
        "addi s3,s3,1 \n" // j=j+1
//        "blt s3,s8, .L120 \n"
        ".L120: \n"
        "nop \n"
//
        "li s3, 0 \n"   // j=0, reset counter     

        ///////////////////
        //// Index = 6 ////
        "pq.update_m x0,x6,x0 \n"  // index = 6
        "pq.update_m x0,x6,x0 \n"  // index = 6
        "li s2, 128 \n"  // m=128
        "li s8, 64 \n" // s8=m/2        

//        ".L121: \n"  // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s8,(.L121)\n" // outer loop
//
            ".L111: \n"  // for(int k=0; k<n/2; k=k+m)
                // Calculate addresses
                "add s5, s3, s4 \n"  // s5 = j+k
                "srli s6, s2, 1 \n"  // s6 = m/2
                "add s6, s6, s5 \n"  // s6 = j+k+m/2
                "slli s5, s5, 2 \n"  // s5 = (j+k)*4
                "slli s6, s6, 2 \n"  // s6 = (j+k+m/2)*4
                "add s5, s5, %[address_reg] \n"  // s5 = pol_in+(k+j)*4
                "add s6, s6, %[address_reg] \n"  // s6 = pol_in+(k+j+m/2)*4
                // Perform butterfly
                "flw f0, 0(s5) \n"
                "flw f1, 0(s6) \n"
                "nop \n"
                "nop \n"
                "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
                "fsw f0, 0(s5) \n"
                "fsw f1, 0(s6) \n"

            "add s4,s4,s2 \n" // k=k+m
            "blt s4,s7, .L111 \n"
        "li s4, 0 \n"   // k=0, reset counter
        "pq.update_omega x0,x0,x0 \n"  // update_omega
        "addi s3,s3,1 \n" // j=j+1
//        "blt s3,s8, .L121 \n"
        ".L121: \n"
        "nop \n"
//
        "li s3, 0 \n"   // j=0, reset counter

        ///////////////////
        //// Index = 7 ////
        "pq.update_m x0,x7,x0 \n"  // index = 7
        "pq.update_m x0,x7,x0 \n"  // index = 7
        "li s2, 256 \n"  // m=256
        "li s8, 128 \n" // s8=m/2        

//        ".L122: \n"  // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s8,(.L122)\n" // outer loop
//
            ".L112: \n"  // for(int k=0; k<n/2; k=k+m)
                // Calculate addresses
                "add s5, s3, s4 \n"  // s5 = j+k
                "srli s6, s2, 1 \n"  // s6 = m/2
                "add s6, s6, s5 \n"  // s6 = j+k+m/2
                "slli s5, s5, 2 \n"  // s5 = (j+k)*4
                "slli s6, s6, 2 \n"  // s6 = (j+k+m/2)*4
                "add s5, s5, %[address_reg] \n"  // s5 = pol_in+(k+j)*4
                "add s6, s6, %[address_reg] \n"  // s6 = pol_in+(k+j+m/2)*4
                // Perform butterfly
                "flw f0, 0(s5) \n"
                "flw f1, 0(s6) \n"
                "nop \n"
                "nop \n"
                "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
                "fsw f0, 0(s5) \n"
                "fsw f1, 0(s6) \n"

            "add s4,s4,s2 \n" // k=k+m
            "blt s4,s7, .L112 \n"
        "li s4, 0 \n"   // k=0, reset counter
        "pq.update_omega x0,x0,x0 \n"  // update_omega
        "addi s3,s3,1 \n" // j=j+1
//        "blt s3,s8, .L122 \n"
        ".L122: \n"
        "nop \n"
//
        "li s3, 0 \n"   // j=0, reset counter

        ///////////////////
        //// Index = 8 ////
        "pq.update_m x0,x8,x0 \n"  // index = 8
        "pq.update_m x0,x8,x0 \n"  // index = 8
        "li s2, 512 \n"  // m=512
        "li s8, 256 \n" // s8=m/2        

//        ".L123: \n"  // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s8,(.L123)\n" // outer loop
//
            ".L113: \n"  // for(int k=0; k<n/2; k=k+m)
                // Calculate addresses
                "add s5, s3, s4 \n"  // s5 = j+k
                "srli s6, s2, 1 \n"  // s6 = m/2
                "add s6, s6, s5 \n"  // s6 = j+k+m/2
                "slli s5, s5, 2 \n"  // s5 = (j+k)*4
                "slli s6, s6, 2 \n"  // s6 = (j+k+m/2)*4
                "add s5, s5, %[address_reg] \n"  // s5 = pol_in+(k+j)*4
                "add s6, s6, %[address_reg] \n"  // s6 = pol_in+(k+j+m/2)*4
                // Perform butterfly
                "flw f0, 0(s5) \n"
                "flw f1, 0(s6) \n"
                "nop \n"
                "nop \n"
                "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
                "fsw f0, 0(s5) \n"
                "fsw f1, 0(s6) \n"

            "add s4,s4,s2 \n" // k=k+m
            "blt s4,s7, .L113 \n"
        "li s4, 0 \n"   // k=0, reset counter
        "pq.update_omega x0,x0,x0 \n"  // update_omega
        "addi s3,s3,1 \n" // j=j+1
//        "blt s3,s8, .L123 \n"
        ".L123: \n"
        "nop \n"
// 
        "li s3, 0 \n"   // j=0, reset counter

        ///////////////////
        //// Index = 9 ////
        // Activate last round
        "pq.set_last_round x0,x0,x0 \n"  // last round
        "pq.update_m x0,x9,x0 \n"  // index = 9
        "pq.update_m x0,x9,x0 \n"  // index = 9
        "li s2, 1024 \n"  // m=1024
        "li s8, 512 \n" // s8=m/2    

//        ".L124: \n"  // for(int j=0; j<m/2; j=j+1)
        "li s8,256 \n"
        "lp.setup x1,s8,(.L124)\n" // outer loop
//
                // Calculate addresses
                "addi s6, s3, 1 \n"  // s6 = j+1
                "slli s5, s3, 2 \n"  // s5 = (j)*4
                "slli s6, s6, 2 \n"  // s6 = (j+1)*4
                "add s5, s5, %[address_reg] \n"  // s5 = pol_in+(j)*4
                "add s6, s6, %[address_reg] \n"  // s6 = pol_in+(j+1)*4
                // Perform butterfly
                "flw f0, 0(s5) \n"
                "flw f1, 0(s6) \n"
                "pq.update_omega x0,x0,x0 \n"  // update_omega
                "nop \n"
                "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
                "pq.mul_gamma1 x0,x0,x0 \n"  // multiply with gamma1
                "pq.update_gamma x0,x0,x0 \n"  // update_gamma
                "pq.mul_gamma2 x0,x0,x0 \n"  // multiply with gamma2
                "pq.update_gamma x0,x0,x0 \n"  // update_gamma      
                "fsw f0, 0(%[address_out]) \n"
                "fsw f1, 1024(%[address_out]) \n"
                // Update store address
                "addi %[address_out],%[address_out],4 \n"
        "pq.update_omega x0,x0,x0 \n"  // update_omega
        "addi s3,s3,2 \n" // j=j+2
//        "blt s3,s8, .L124 \n"
        ".L124: \n"
        "nop \n"
//
    : : [address_reg]"r" (pol_in), [address_out]"r" (pol_out) : "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "cc","memory"
    );
}
