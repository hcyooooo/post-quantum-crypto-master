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
        "li t0,0 \n"
        "li t1,1023 \n"

        "p.lh t2,2(%[l_address]!) \n"
        "nop \n"
        "lp.setup x0,t1,(.LBR00) \n"
            "pq.sh_br1024 t0,%[s_address],t2 \n"
            "p.lh t2,2(%[l_address]!) \n"
            "addi t0,t0,1 \n" // j=j+1
        ".LBR00: \n"
        "nop \n"
        "pq.sh_br1024 t0,%[s_address],t2 \n"
        : : [l_address]"r" (pol_in), [s_address]"r" (pol_out) : "cc","memory"
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
        // t1 = tmp1
        // t2 = j -> 0
        // t3 = tmp2
        // t4 = address_lw1_final (pol_in+(k+j)*4)
        // t5 = address_lw2_final (pol_in+(k+j+m/2)*4)
        // s1 = m/2
        ///////////////////

        ///////////////////
        //// Index = 5 ////
        "pq.update_m x0,x5,x0 \n"  // index = 5
        "pq.update_m x0,x5,x0 \n"  // index = 5
        "li t2, 0 \n"   // j=0
        "li s1, 32 \n"  // s1=m/2        

        "li t1, 0 \n"  // (j)*4  reschedule
        // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s1,(.L020)\n" // outer loop
            //// 1 round ////
            // Calculate addresses
//            "slli t1, t2, 2 \n"  // (j)*4  reschedule
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "flw f0, 0(t4) \n"
            "add t3, t2, s1 \n"  // j+m/2
            "slli t3, t3, 2 \n"  // (j+m/2)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            "flw f1, 0(t5) \n"
            // nops
            "addi t1, t2, 64 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            // Perform butterfly
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 2 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "addi t1, t2, 128 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 3 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "add t1, t2, 192 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 4 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "add t1, t2, 256 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 5 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "add t1, t2, 320 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 6 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "add t1, t2, 384 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 7 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "add t1, t2, 448 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 4 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "addi t2,t2,1 \n" // j=j+1
            "slli t1, t2, 2 \n"  // (j)*4  reschedule
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"
            "pq.update_omega x0,x0,x0 \n"  // update_omega
        ".L020: \n"
        "nop \n"
        "li t2, 0 \n"   // j=0, reset counter

        ///////////////////
        //// Index = 6 ////
        "pq.update_m x0,x6,x0 \n"  // index = 6
        "pq.update_m x0,x6,x0 \n"  // index = 6
        "li s1, 64 \n"  // s1=m/2        

        "li t1, 0 \n"  // (j)*4  reschedule
        // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s1,(.L021)\n" // outer loop
            //// 1 round ////
            // Calculate addresses
//            "slli t1, t2, 2 \n"  // (j)*4  reschedule
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "flw f0, 0(t4) \n"
            "add t3, t2, s1 \n"  // j+m/2
            "slli t3, t3, 2 \n"  // (j+m/2)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            "flw f1, 0(t5) \n"
            // nops
            "addi t1, t2, 128 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            // Perform butterfly
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 2 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "addi t1, t2, 256 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 3 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "add t1, t2, 384 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 4 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "addi t2,t2,1 \n" // j=j+1
            "slli t1, t2, 2 \n"  // (j)*4  reschedule
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"
            "pq.update_omega x0,x0,x0 \n"  // update_omega
        ".L021: \n"
        "nop \n"
        "li t2, 0 \n"   // j=0, reset counter 

        ///////////////////
        //// Index = 7 ////
        "pq.update_m x0,x7,x0 \n"  // index = 7
        "pq.update_m x0,x7,x0 \n"  // index = 7
        "li s1, 128 \n" // s1=m/2        

        "li t1, 0 \n"  // (j)*4  reschedule
        // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s1,(.L022)\n" // outer loop
            // Calculate addresses
//            "slli t1, t2, 2 \n"  // j*4  reschedule
            "add t3, s1, t2 \n"  // j+m/2
            "slli t3, t3, 2 \n"  // (j+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "addi t1, t2, 256 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "addi t2,t2,1 \n" // j=j+1
            "slli t1, t2, 2 \n"  // j*4  reschedule
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"
            "li t3, 0 \n"   // k=0, reset counter
            "pq.update_omega x0,x0,x0 \n"  // update_omega
        ".L022: \n"
        "nop \n"
        "li t2, 0 \n"   // j=0, reset counter

        ///////////////////
        //// Index = 8 ////
        "pq.update_m x0,x8,x0 \n"  // index = 8
        "pq.update_m x0,x8,x0 \n"  // index = 8
        "li s1, 256 \n" // s1=m/2        

        "li t1, 0 \n"
        // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s1,(.L023)\n" // outer loop
            // Calculate addresses
//            "slli t1, t2, 2 \n"  // (j+k)*4 reschedule
            "add t4, t1, %[address_reg] \n"  // t4 = pol_in+(k+j)*4
            "add t3, s1, t2 \n"  // j+m/2
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t5, t3, %[address_reg] \n"  // t5 = pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "addi t2,t2,1 \n" // j=j+1
            "slli t1, t2, 2 \n"  // (j+k)*4  reschedule
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"
            "pq.update_omega x0,x0,x0 \n"  // update_omega
        ".L023: \n"
        "nop \n"
        "li t2, 0 \n"   // j=0, reset counter

        ///////////////////
        //// Index = 9 ////
        // Activate last round
        "pq.set_last_round x0,x0,x0 \n"  // last round
        "pq.update_m x0,x9,x0 \n"  // index = 9
        "pq.update_m x0,x9,x0 \n"  // index = 9     

        // for(int j=0; j<m/2; j=j+2)
        "lp.setupi  x1,256,(.L024)\n" // outer loop
            // Calculate addresses
            "addi t5, t2, 1 \n"  // t5 = j+1
            "slli t4, t2, 2 \n"  // t4 = (j)*4
            "slli t5, t5, 2 \n"  // t5 = (j+1)*4
            "add t4, t4, %[address_reg] \n"  // t4 = pol_in+(j)*4
            "add t5, t5, %[address_reg] \n"  // t5 = pol_in+(j+1)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            "pq.update_omega x0,x0,x0 \n"  // update_omega
            // nop
            "addi t2,t2,2 \n" // j=j+2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(%[address_out]) \n"
            "fsw f1, 1024(%[address_out]) \n"
            // Update store address
            "addi %[address_out],%[address_out],4 \n"              
            "pq.update_omega x0,x0,x0 \n"  // update_omega
        ".L024: \n"
        "nop \n"
    : : [address_reg]"r" (pol_in), [address_out]"r" (pol_out) : "s1", "cc","memory"
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
        // t1 = tmp1
        // t2 = j -> 0
        // t3 = tmp2
        // t4 = address_lw1_final (pol_in+(k+j)*4)
        // t5 = address_lw2_final (pol_in+(k+j+m/2)*4)
        // s1 = m/2
        ///////////////////

        ///////////////////
        //// Index = 5 ////
        "pq.update_m x0,x5,x0 \n"  // index = 5
        "pq.update_m x0,x5,x0 \n"  // index = 5
        "li t2, 0 \n"   // j=0
        "li s1, 32 \n"  // s1=m/2        

        "li t1, 0 \n"  // (j)*4  reschedule
        // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s1,(.L120)\n" // outer loop
            //// 1 round ////
            // Calculate addresses
//            "slli t1, t2, 2 \n"  // (j)*4  reschedule
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "flw f0, 0(t4) \n"
            "add t3, t2, s1 \n"  // j+m/2
            "slli t3, t3, 2 \n"  // (j+m/2)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            "flw f1, 0(t5) \n"
            // nops
            "addi t1, t2, 64 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            // Perform butterfly
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 2 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "addi t1, t2, 128 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 3 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "add t1, t2, 192 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 4 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "add t1, t2, 256 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 5 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "add t1, t2, 320 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 6 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "add t1, t2, 384 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 7 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "add t1, t2, 448 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 4 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "addi t2,t2,1 \n" // j=j+1
            "slli t1, t2, 2 \n"  // (j)*4  reschedule
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"
            "pq.update_omega x0,x0,x0 \n"  // update_omega
        ".L120: \n"
        "nop \n"
        "li t2, 0 \n"   // j=0, reset counter

        ///////////////////
        //// Index = 6 ////
        "pq.update_m x0,x6,x0 \n"  // index = 6
        "pq.update_m x0,x6,x0 \n"  // index = 6
        "li s1, 64 \n"  // s1=m/2        

        "li t1, 0 \n"  // (j)*4  reschedule
        // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s1,(.L121)\n" // outer loop
            //// 1 round ////
            // Calculate addresses
//            "slli t1, t2, 2 \n"  // (j)*4  reschedule
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "flw f0, 0(t4) \n"
            "add t3, t2, s1 \n"  // j+m/2
            "slli t3, t3, 2 \n"  // (j+m/2)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            "flw f1, 0(t5) \n"
            // nops
            "addi t1, t2, 128 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            // Perform butterfly
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 2 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "addi t1, t2, 256 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 3 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "add t1, t2, 384 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            //// 4 round ////
            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "addi t2,t2,1 \n" // j=j+1
            "slli t1, t2, 2 \n"  // (j)*4  reschedule
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"
            "pq.update_omega x0,x0,x0 \n"  // update_omega
        ".L121: \n"
        "nop \n"
        "li t2, 0 \n"   // j=0, reset counter 

        ///////////////////
        //// Index = 7 ////
        "pq.update_m x0,x7,x0 \n"  // index = 7
        "pq.update_m x0,x7,x0 \n"  // index = 7
        "li s1, 128 \n" // s1=m/2        

        "li t1, 0 \n"  // (j)*4  reschedule
        // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s1,(.L122)\n" // outer loop
            // Calculate addresses
//            "slli t1, t2, 2 \n"  // j*4  reschedule
            "add t3, s1, t2 \n"  // j+m/2
            "slli t3, t3, 2 \n"  // (j+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "addi t1, t2, 256 \n"  // j+k
            "add t3, s1, t1 \n"  // j+k+m/2
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"

            // Calculate addresses
            "slli t1, t1, 2 \n"  // (j+k)*4
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t4, t1, %[address_reg] \n"  // pol_in+(k+j)*4
            "add t5, t3, %[address_reg] \n"  // pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "addi t2,t2,1 \n" // j=j+1
            "slli t1, t2, 2 \n"  // j*4  reschedule
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"
            "li t3, 0 \n"   // k=0, reset counter
            "pq.update_omega x0,x0,x0 \n"  // update_omega
        ".L122: \n"
        "nop \n"
        "li t2, 0 \n"   // j=0, reset counter

        ///////////////////
        //// Index = 8 ////
        "pq.update_m x0,x8,x0 \n"  // index = 8
        "pq.update_m x0,x8,x0 \n"  // index = 8
        "li s1, 256 \n" // s1=m/2        

        "li t1, 0 \n"
        // for(int j=0; j<m/2; j=j+1)
        "lp.setup  x1,s1,(.L123)\n" // outer loop
            // Calculate addresses
//            "slli t1, t2, 2 \n"  // (j+k)*4 reschedule
            "add t4, t1, %[address_reg] \n"  // t4 = pol_in+(k+j)*4
            "add t3, s1, t2 \n"  // j+m/2
            "slli t3, t3, 2 \n"  // (j+k+m/2)*4
            "add t5, t3, %[address_reg] \n"  // t5 = pol_in+(k+j+m/2)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            // nops
            "addi t2,t2,1 \n" // j=j+1
            "slli t1, t2, 2 \n"  // (j+k)*4  reschedule
            "pq.ntt_single_bf x0,x0,x0 \n"  // single_bf
            "fsw f0, 0(t4) \n"
            "fsw f1, 0(t5) \n"
            "pq.update_omega x0,x0,x0 \n"  // update_omega
        ".L123: \n"
        "nop \n"
        "li t2, 0 \n"   // j=0, reset counter


        ///////////////////
        //// Index = 9 ////
        // Activate last round
        "pq.set_last_round x0,x0,x0 \n"  // last round
        "pq.update_m x0,x9,x0 \n"  // index = 9
        "pq.update_m x0,x9,x0 \n"  // index = 9
        "li t1, 1024 \n"  // m=1024
        "li s1, 512 \n" // s1=m/2    

        // for(int j=0; j<m/2; j=j+1)
        "li s1,256 \n"
        "lp.setup x1,s1,(.L124)\n" // outer loop
            // Calculate addresses
            "addi t5, t2, 1 \n"  // t5 = j+1
            "slli t4, t2, 2 \n"  // t4 = (j)*4
            "slli t5, t5, 2 \n"  // t5 = (j+1)*4
            "add t4, t4, %[address_reg] \n"  // t4 = pol_in+(j)*4
            "add t5, t5, %[address_reg] \n"  // t5 = pol_in+(j+1)*4
            // Perform butterfly
            "flw f0, 0(t4) \n"
            "flw f1, 0(t5) \n"
            "pq.update_omega x0,x0,x0 \n"  // update_omega
            // nop
            "addi t2,t2,2 \n" // j=j+2
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
        ".L124: \n"
        "nop \n"
    : : [address_reg]"r" (pol_in), [address_out]"r" (pol_out) : "s1", "cc","memory"
    );
}
