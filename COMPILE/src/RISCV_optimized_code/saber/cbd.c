/*---------------------------------------------------------------------
This file has been adapted from the implementation
(available at, Public Domain https://github.com/pq-crystals/kyber)
of "CRYSTALS – Kyber: a CCA-secure module-lattice-based KEM"
by : Joppe Bos, Leo Ducas, Eike Kiltz, Tancrede Lepoint,
Vadim Lyubashevsky, John M. Schanck, Peter Schwabe & Damien stehle
----------------------------------------------------------------------*/

#include "SABER_params.h"
#include "api.h"
#include "cbd.h"
#include <stdint.h>

static uint64_t load_littleendian(const unsigned char *x, int bytes) {
    int i;
    uint64_t r = x[0];
    for (i = 1; i < bytes; i++) {
        r |= (uint64_t)x[i] << (8 * i);
    }
    return r;
}

#define HW

void PQCLEAN_SABER_CLEAN_cbd(uint16_t *r, const unsigned char *buf) {
#ifndef HW
    uint16_t Qmod_minus1 = SABER_Q - 1;

    uint32_t t, d, a[4], b[4];
    int i, j;

    for (i = 0; i < SABER_N / 4; i++) {
        t = (uint32_t) load_littleendian(buf + 4 * i, 4);
        d = 0;
        for (j = 0; j < 4; j++) {
            d += (t >> j) & 0x11111111;
        }

        a[0] =  d & 0xf;
        b[0] = (d >>  4) & 0xf;
        a[1] = (d >>  8) & 0xf;
        b[1] = (d >> 12) & 0xf;
        a[2] = (d >> 16) & 0xf;
        b[2] = (d >> 20) & 0xf;
        a[3] = (d >> 24) & 0xf;
        b[3] = (d >> 28);

        r[4 * i + 0] = (uint16_t)(a[0]  - b[0]) & Qmod_minus1;
        r[4 * i + 1] = (uint16_t)(a[1]  - b[1]) & Qmod_minus1;
        r[4 * i + 2] = (uint16_t)(a[2]  - b[2]) & Qmod_minus1;
        r[4 * i + 3] = (uint16_t)(a[3]  - b[3]) & Qmod_minus1;
    }
#else
    asm volatile(
    "li t5,64 \n"
    "lp.setup x0,t5,(.LOOPS) \n"
        // Load 4 bytes
        "p.lh t0,2(%[address_lw]!) \n"  // a0
        "p.lh t1,2(%[address_lw]!) \n"

        // first
        "srli t2,t0,4 \n" // a1
        "srli t3,t0,8 \n" // a2
        "srli t4,t0,12 \n" // a3

        // pack pairs
        "pv.pack.h t5,t3,t0 \n"  // a2,a0
        "pv.pack.h t6,t4,t2 \n"  // a3,a1

        "pq.bs_k4 t6,t5,t6 \n"
        "p.sw t6,4(%[address_sw]!) \n"

        // second
        "srli t2,t1,4 \n" // a1
        "srli t3,t1,8 \n" // a2
        "srli t4,t1,12 \n" // a3

        // pack pairs
        "pv.pack.h t5,t3,t1 \n"  // a2,a0
        "pv.pack.h t6,t4,t2 \n"  // a3,a1

        "pq.bs_k4 t6,t5,t6 \n"
        "p.sw t6,4(%[address_sw]!) \n"
    ".LOOPS: \n"
    "nop \n"
   
    : : [address_lw]"r" (buf), [address_sw]"r" (r) : "cc","memory"
    );
#endif
}
