#include "poly_mul.h"
#include <stdint.h>
#include <string.h>


#define SCHB_N 16

#define N_RES (SABER_N << 1)
#define N_SB (SABER_N >> 2)
#define N_SB_RES (2*N_SB-1)


#define KARATSUBA_N 64

#define HW

static void karatsuba_simple(const uint16_t *a_1, const uint16_t *b_1, uint16_t *result_final) {   
    uint16_t d01[KARATSUBA_N / 2 - 1];
    uint16_t d0123[KARATSUBA_N / 2 - 1];
    uint16_t d23[KARATSUBA_N / 2 - 1];
    uint16_t result_d01[KARATSUBA_N - 1];

    int32_t i, j;

    memset(result_d01, 0, (KARATSUBA_N - 1)*sizeof(uint16_t));
    memset(d01, 0, (KARATSUBA_N / 2 - 1)*sizeof(uint16_t));
    memset(d0123, 0, (KARATSUBA_N / 2 - 1)*sizeof(uint16_t));
    memset(d23, 0, (KARATSUBA_N / 2 - 1)*sizeof(uint16_t));
    memset(result_final, 0, (2 * KARATSUBA_N - 1)*sizeof(uint16_t));

    uint16_t acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8, acc9, acc10;

#ifdef HW
    asm volatile(
        ////////////
        // acc1: t0
        // acc2: t1
        // acc3: t2
        // acc4: t3
        // acc5: t4
        // acc6: t5
        // acc7: t6
        // acc8: a0
        // acc9: a1
        // acc10: a2
        // tmp1: a3
        // tmp2: a4
        // tmp3: a5
        ////////////

        "li a7,8\n"
        "li s1,30\n"  // constant

        "lp.starti x1, (.start_outer_hw_loop_vec)\n"
        "lp.endi x1, (.end_outer_hw_loop_vec)\n"
        "lp.counti x1, 16\n"
        ".start_outer_hw_loop_vec:\n"

            // Load coefficients a
            "p.lhu t0,32(%[addr_a]!)\n"    // acc1 = a_1[i + 0 * KARATSUBA_N / 4] //a0
            "p.lhu t1,32(%[addr_a]!)\n"    // acc2 = a_1[i + 1 * KARATSUBA_N / 4] //a1
            "p.lhu t2,32(%[addr_a]!)\n"    // acc3 = a_1[i + 2 * KARATSUBA_N / 4] //a2
            "p.lhu t3,-94(%[addr_a]!)\n"   // acc4 = a_1[i + 3 * KARATSUBA_N / 4] //a3

            "pv.pack.h t0,t0,t0\n"
            "pv.pack.h t1,t1,t1\n"
            "pv.pack.h t2,t2,t2\n"
            "pv.pack.h t3,t3,t3\n"

            "lp.setup x0,a7,(.end_inner_hw_loop_vec)\n"
                // Load
                "p.lw t4,32(%[addr_b]!)\n"        // acc5 = b_1[j + 0 * KARATSUBA_N / 4] // b0
                "p.lw t5,32(%[addr_b]!)\n"        // acc6 = b_1[j + 1 * KARATSUBA_N / 4] // b1

                "p.lw a3,64(%[addr_final]!)\n"    // tmp1 = result_final[i + j + 0 * KARATSUBA_N / 4]
                "p.lw a4,-64(%[addr_final]!)\n"   // tmp2 = result_final[i + j + 2 * KARATSUBA_N / 4]
                "p.lw a5,0(%[addr_d01]!)\n"       // tmp3 = d01[i + j]

                // Operations
                "pv.add.h t6,t4,t5\n"             // acc7 = acc5 + acc6 // b01
                "pv.add.h a0,t0,t1\n"             // acc8 = acc1 + acc2 // a01

                "pq.mac a3,t0,t4\n"               // tmp1 = result_final[i + j + 0 * KARATSUBA_N / 4] + acc1 * acc5
                "pq.mac a4,t1,t5\n"               // tmp2 = result_final[i + j + 2 * KARATSUBA_N / 4] + acc2 * acc6
    
                "pq.mac a5,t6,a0\n"               // tmp3 = d01[i + j] + acc7 * acc8

                // Store results
                "p.sw a3,64(%[addr_final]!)\n"    // result_final[i + j + 0 * KARATSUBA_N / 4]
                "p.sw a4,64(%[addr_final]!)\n"    // result_final[i + j + 2 * KARATSUBA_N / 4]
                "p.sw a5,4(%[addr_d01]!)\n"       // d01[i + j]

                //-------------------------------------------------------------------------------------------------------------------------------------
    
                // Load
                "p.lw t6,32(%[addr_b]!)\n"        // acc7 = b_1[j + 2 * KARATSUBA_N / 4] // b2
                "p.lw a0,-92(%[addr_b]!)\n"       // acc8 = b_1[j + 3 * KARATSUBA_N / 4] // b3

                "p.lw a3,64(%[addr_final]!)\n"    // tmp1 = result_final[i + j + 4 * KARATSUBA_N / 4] 
                "p.lw a4,-64(%[addr_final]!)\n"   // tmp2 = result_final[i + j + 6 * KARATSUBA_N / 4]
    
                "p.lw a5,0(%[addr_d23]!)\n"       // tmp3 = d23[i + j]
    
                // Operations
                "pv.add.h a1,t2,t3\n"             // acc9 = acc3 + acc4 // a23
                "pv.add.h a2,t6,a0\n"             // acc10 = acc7 + acc8 // b23

                "pq.mac a3,t2,t6\n"               // tmp1 = result_final[i + j + 4 * KARATSUBA_N / 4] + acc3 * acc7
                "pq.mac a4,t3,a0\n"               // tmp2 = result_final[i + j + 6 * KARATSUBA_N / 4] + acc4 * acc8
    
                "pq.mac a5,a1,a2\n"               // tmp3 = d23[i + j] + acc9 * acc10

                // Store result
                "p.sw a3,64(%[addr_final]!)\n"    // result_final[i + j + 4 * KARATSUBA_N / 4]
                "p.sw a4,-188(%[addr_final]!)\n"  // result_final[i + j + 6 * KARATSUBA_N / 4]
                "p.sw a5,4(%[addr_d23]!)\n"       // d23[i + j]

                //-------------------------------------------------------------------------------------------------------------------------------------

                // Load
                "p.lw a3,64(%[addr_res_d01]!)\n"  // tmp1 = result_d01[i + j + 0 * KARATSUBA_N / 4]
                "p.lw a4,-64(%[addr_res_d01]!)\n" // tmp2 = result_d01[i + j + 2 * KARATSUBA_N / 4]
                "p.lw a5,0(%[addr_d0123]!)\n"     // tmp3 = d0123[i + j]

                // Operations
                "pv.add.h t4,t4,t6\n"             // acc5 = acc5 + acc7 // b02
                "pv.add.h t6,t0,t2\n"             // acc7 = acc1 + acc3 // a02

                "pv.add.h t5,t5,a0\n"             // acc6 = acc6 + acc8 // b13
                "pv.add.h a0,t1,t3\n"             // acc8 = acc2 + acc4 // a13

                "pq.mac a3,t4,t6\n"               // tmp1 = result_d01[i + j + 0 * KARATSUBA_N / 4] + acc5 * acc7
                "pq.mac a4,t5,a0\n"               // tmp2 = result_d01[i + j + 2 * KARATSUBA_N / 4] + acc6 * acc8

                "pv.add.h t4,t4,t5\n"             // acc5 = acc5 + acc6 //b0123
                "pv.add.h t6,t6,a0\n"             // acc7 = acc7 + acc8 //a0123

                "pq.mac a5,t4,t6\n"               // tmp3 = d0123[i + j] + acc5 * acc7

                // Store result
                "p.sw a3,64(%[addr_res_d01]!)\n"  // result_d01[i + j + 0 * KARATSUBA_N / 4]
                "p.sw a4,-60(%[addr_res_d01]!)\n" // result_d01[i + j + 2 * KARATSUBA_N / 4]
                "p.sw a5, 4(%[addr_d0123]!)\n"    // d0123[i + j]

            ".end_inner_hw_loop_vec:"

            // Reset addresses
            "li a6,32\n" // constant
            "sub %[addr_b],%[addr_b],a6\n"
            "sub %[addr_d0123],%[addr_d0123],s1\n"
            "sub %[addr_res_d01],%[addr_res_d01],s1\n"
            "sub %[addr_d23],%[addr_d23],s1\n"
            "sub %[addr_d01],%[addr_d01],s1\n"
            "sub %[addr_final],%[addr_final],s1\n"
        ".end_outer_hw_loop_vec:"
    
        // Reset addresses
        "li a6,32\n" // constant
        "sub %[addr_a],%[addr_a],a6\n" 
        "sub %[addr_final],%[addr_final],a6\n"
        "sub %[addr_d01],%[addr_d01],a6\n"
        "sub %[addr_d23],%[addr_d23],a6\n"
        "sub %[addr_res_d01],%[addr_res_d01],a6\n"
        "sub %[addr_d0123],%[addr_d0123],a6\n"
    : :   
    [addr_d0123]"r" (d0123),
    [addr_res_d01]"r" (result_d01),
    [addr_d23]"r" (d23),
    [addr_d01]"r" (d01),
    [addr_final]"r" (result_final),
    [addr_a]"r" (a_1),
    [addr_b]"r" (b_1)
    : "x1","s1","s2", "memory"
    );

#else
    for (i = 0; i < KARATSUBA_N / 4; i++) {

        acc1 = a_1[i]; //a0
        acc2 = a_1[i + KARATSUBA_N / 4]; //a1
        acc3 = a_1[i + 2 * KARATSUBA_N / 4]; //a2
        acc4 = a_1[i + 3 * KARATSUBA_N / 4]; //a3
        for (j = 0; j < KARATSUBA_N / 4; j++) {

            acc5 = b_1[j]; //b0
            acc6 = b_1[j + KARATSUBA_N / 4]; //b1

            //a0*b0 
            result_final[i + j + 0 * KARATSUBA_N / 4] = result_final[i + j + 0 * KARATSUBA_N / 4] + acc1 * acc5;
            //a1*b1
            result_final[i + j + 2 * KARATSUBA_N / 4] = result_final[i + j + 2 * KARATSUBA_N / 4] + acc2 * acc6;

            acc7 = acc5 + acc6; //b01
            acc8 = acc1 + acc2; //a01
            //a01*b01
            d01[i + j] = d01[i + j] + acc7 * acc8;

            acc7 = b_1[j + 2 * KARATSUBA_N / 4]; //b2
            acc8 = b_1[j + 3 * KARATSUBA_N / 4]; //b3

            //a2*b2
            result_final[i + j + 4 * KARATSUBA_N / 4] = result_final[i + j + 4 * KARATSUBA_N / 4] + acc7 * acc3;
            //a3*b3 
            result_final[i + j + 6 * KARATSUBA_N / 4] = result_final[i + j + 6 * KARATSUBA_N / 4] + acc8 * acc4;

            acc9 = acc3 + acc4; //a23
            acc10 = acc7 + acc8; //b23
            //a23*b23
            d23[i + j] = d23[i + j] + acc9 * acc10;
            //--------------------------------------------------------

            acc5 = acc5 + acc7; //b02
            acc7 = acc1 + acc3; //a02
            //a02*b02
            result_d01[i + j + 0 * KARATSUBA_N / 4] = result_d01[i + j + 0 * KARATSUBA_N / 4] + acc5 * acc7;

            acc6 = acc6 + acc8; //b13
            acc8 = acc2 + acc4; //a13
            //a13*b13
            result_d01[i + j + 2 * KARATSUBA_N / 4] = result_d01[i + j + 2 * KARATSUBA_N / 4] + acc6 * acc8;

            acc5 = acc5 + acc6; //b0123
            acc7 = acc7 + acc8; //a0123
            //a0123*b0123
            d0123[i + j] = d0123[i + j] + acc5 * acc7;

        }
    }
#endif

    // 2nd last stage 
    for (i = 0; i < KARATSUBA_N / 2 - 1; i++) {
        d0123[i] = d0123[i] - result_d01[i + 0 * KARATSUBA_N / 4] - result_d01[i + 2 * KARATSUBA_N / 4];
        d01[i] = d01[i] - result_final[i + 0 * KARATSUBA_N / 4] - result_final[i + 2 * KARATSUBA_N / 4];
        d23[i] = d23[i] - result_final[i + 4 * KARATSUBA_N / 4] - result_final[i + 6 * KARATSUBA_N / 4];
    }
    for (i = 0; i < KARATSUBA_N / 2 - 1; i++) {
        result_d01[i + 1 * KARATSUBA_N / 4] = result_d01[i + 1 * KARATSUBA_N / 4] + d0123[i];
        result_final[i + 1 * KARATSUBA_N / 4] = result_final[i + 1 * KARATSUBA_N / 4] + d01[i];
        result_final[i + 5 * KARATSUBA_N / 4] = result_final[i + 5 * KARATSUBA_N / 4] + d23[i];
    }

    // Last stage
    for (i = 0; i < KARATSUBA_N - 1; i++) {
        result_d01[i] = result_d01[i] - result_final[i] - result_final[i + KARATSUBA_N];
    }

    for (i = 0; i < KARATSUBA_N - 1; i++) {
        result_final[i + 1 * KARATSUBA_N / 2] = result_final[i + 1 * KARATSUBA_N / 2] + result_d01[i];
    }
}


static void toom_cook_4way (const uint16_t *a1, const uint16_t *b1, uint16_t *result) {
    uint16_t inv3 = 43691, inv9 = 36409, inv15 = 61167;

    uint16_t aw1[N_SB], aw2[N_SB], aw3[N_SB], aw4[N_SB], aw5[N_SB], aw6[N_SB], aw7[N_SB];
    uint16_t bw1[N_SB], bw2[N_SB], bw3[N_SB], bw4[N_SB], bw5[N_SB], bw6[N_SB], bw7[N_SB];
    uint16_t w1[N_SB_RES] = {0}, w2[N_SB_RES] = {0}, w3[N_SB_RES] = {0}, w4[N_SB_RES] = {0},
                            w5[N_SB_RES] = {0}, w6[N_SB_RES] = {0}, w7[N_SB_RES] = {0};
    uint16_t r0, r1, r2, r3, r4, r5, r6, r7;
    uint16_t *A0, *A1, *A2, *A3, *B0, *B1, *B2, *B3;
    A0 = (uint16_t *)a1;
    A1 = (uint16_t *)&a1[N_SB];
    A2 = (uint16_t *)&a1[2 * N_SB];
    A3 = (uint16_t *)&a1[3 * N_SB];
    B0 = (uint16_t *)b1;
    B1 = (uint16_t *)&b1[N_SB];
    B2 = (uint16_t *)&b1[2 * N_SB];
    B3 = (uint16_t *)&b1[3 * N_SB];

    uint16_t *C;
    C = result;

    int i, j;

    // EVALUATION
    for (j = 0; j < N_SB; ++j) {
        r0 = A0[j];
        r1 = A1[j];
        r2 = A2[j];
        r3 = A3[j];
        r4 = r0 + r2;
        r5 = r1 + r3;
        r6 = r4 + r5;
        r7 = r4 - r5;
        aw3[j] = r6;
        aw4[j] = r7;
        r4 = ((r0 << 2) + r2) << 1;
        r5 = (r1 << 2) + r3;
        r6 = r4 + r5;
        r7 = r4 - r5;
        aw5[j] = r6;
        aw6[j] = r7;
        r4 = (r3 << 3) + (r2 << 2) + (r1 << 1) + r0;
        aw2[j] = r4;
        aw7[j] = r0;
        aw1[j] = r3;
    }
    for (j = 0; j < N_SB; ++j) {
        r0 = B0[j];
        r1 = B1[j];
        r2 = B2[j];
        r3 = B3[j];
        r4 = r0 + r2;
        r5 = r1 + r3;
        r6 = r4 + r5;
        r7 = r4 - r5;
        bw3[j] = r6;
        bw4[j] = r7;
        r4 = ((r0 << 2) + r2) << 1;
        r5 = (r1 << 2) + r3;
        r6 = r4 + r5;
        r7 = r4 - r5;
        bw5[j] = r6;
        bw6[j] = r7;
        r4 = (r3 << 3) + (r2 << 2) + (r1 << 1) + r0;
        bw2[j] = r4;
        bw7[j] = r0;
        bw1[j] = r3;
    }

    // MULTIPLICATION
    karatsuba_simple(aw1, bw1, w1);
    karatsuba_simple(aw2, bw2, w2);
    karatsuba_simple(aw3, bw3, w3);
    karatsuba_simple(aw4, bw4, w4);
    karatsuba_simple(aw5, bw5, w5);
    karatsuba_simple(aw6, bw6, w6);
    karatsuba_simple(aw7, bw7, w7);
    

    // INTERPOLATION
    for (i = 0; i < N_SB_RES; ++i) {
        r0 = w1[i];
        r1 = w2[i];
        r2 = w3[i];
        r3 = w4[i];
        r4 = w5[i];
        r5 = w6[i];
        r6 = w7[i];

        r1 = r1 + r4;
        r5 = r5 - r4;
        r3 = ((r3 - r2) >> 1);
        r4 = r4 - r0;
        r4 = r4 - (r6 << 6);
        r4 = (r4 << 1) + r5;
        r2 = r2 + r3;
        r1 = r1 - (r2 << 6) - r2;
        r2 = r2 - r6;
        r2 = r2 - r0;
        r1 = r1 + 45 * r2;
        r4 = (((r4 - (r2 << 3)) * inv3) >> 3);
        r5 = r5 + r1;
        r1 = (((r1 + (r3 << 4)) * inv9) >> 1);
        r3 = -(r3 + r1);
        r5 = (((30 * r1 - r5) * inv15) >> 2);
        r2 = r2 - r4;
        r1 = r1 - r5;

        C[i]     += r6;
        C[i + 64]  += r5;
        C[i + 128] += r4;
        C[i + 192] += r3;
        C[i + 256] += r2;
        C[i + 320] += r1;
        C[i + 384] += r0;
    }
}


void PQCLEAN_FIRESABER_CLEAN_pol_mul(uint16_t *a, uint16_t *b, uint16_t *res, uint16_t p, uint32_t n)
{
    uint32_t i;
    // normal multiplication
    uint16_t c[512];

    for (i = 0; i < 512; i++) {
        c[i] = 0;
    }

    toom_cook_4way(a, b, c);

    // reduction
    for (i = n; i < 2 * n; i++) {
        res[i - n] = (c[i - n] - c[i]) & (p - 1);
    }
}
