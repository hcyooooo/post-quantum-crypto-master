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

void PQCLEAN_FIRESABER_CLEAN_cbd(uint16_t *r, const unsigned char *buf) {
#ifndef HW
    uint16_t Qmod_minus1 = SABER_Q - 1;

    uint32_t t, d, a[4], b[4];
    int i, j;

    for (i = 0; i < SABER_N / 4; i++) {
        t = (uint32_t) load_littleendian(buf + 3 * i, 3);
        d = 0;
        for (j = 0; j < 3; j++) {
            d += (t >> j) & 0x249249;
        }

        a[0] =  d & 0x7;
        b[0] = (d >>  3) & 0x7;
        a[1] = (d >>  6) & 0x7;
        b[1] = (d >>  9) & 0x7;
        a[2] = (d >> 12) & 0x7;
        b[2] = (d >> 15) & 0x7;
        a[3] = (d >> 18) & 0x7;
        b[3] = (d >> 21);

        r[4 * i + 0] = (uint16_t)(a[0]  - b[0]) & Qmod_minus1;
        r[4 * i + 1] = (uint16_t)(a[1]  - b[1]) & Qmod_minus1;
        r[4 * i + 2] = (uint16_t)(a[2]  - b[2]) & Qmod_minus1;
        r[4 * i + 3] = (uint16_t)(a[3]  - b[3]) & Qmod_minus1;

    }
#else
    asm volatile(
    "li t5,64 \n"
    "lp.setup x0,t5,(.LOOPS) \n"
        // Load 3 bytes
        "p.lw t0,3(%[address_lw]!) \n"

        // prepare first pair in t0,t2
        "srli t2,t0,3 \n"

        // prepare second pair in t3,t4
        "srli t3,t0,6 \n"
        "srli t4,t0,9 \n"

        // pack pairs
        "pv.pack.h t3,t3,t0 \n"
        "pv.pack.h t4,t4,t2 \n"       

        "pq.bs_k3 t4,t3,t4 \n"
        "p.sw t4,4(%[address_sw]!) \n"

        ////////
        // prepare first pair in t1,t2
        "srli t1,t0,12 \n"
        "srli t2,t0,15 \n"
        // prepare second pair in t3,t4
        "srli t3,t0,18 \n"
        "srli t4,t0,21 \n"

        // pack pairs
        "pv.pack.h t3,t3,t1 \n"
        "pv.pack.h t4,t4,t2 \n"       

        "pq.bs_k3 t4,t3,t4 \n"
        "p.sw t4,4(%[address_sw]!) \n"
    ".LOOPS: \n"
    "nop \n"
   
    : : [address_lw]"r" (buf), [address_sw]"r" (r) : "cc","memory"
    );
#endif
}
