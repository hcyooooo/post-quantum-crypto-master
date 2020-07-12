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

void PQCLEAN_LIGHTSABER_CLEAN_cbd(uint16_t *r, const unsigned char *buf) {
#ifndef HW
    uint16_t Qmod_minus1 = SABER_Q - 1;

    uint64_t t, d, a[4], b[4];
    int i, j;

    for (i = 0; i < SABER_N / 4; i++) {
        t = load_littleendian(buf + 5 * i, 5);
        d = 0;
        for (j = 0; j < 5; j++) {
            d += (t >> j) & 0x0842108421UL;
        }

        a[0] =  d & 0x1f;
        b[0] = (d >>  5) & 0x1f;
        a[1] = (d >> 10) & 0x1f;
        b[1] = (d >> 15) & 0x1f;
        a[2] = (d >> 20) & 0x1f;
        b[2] = (d >> 25) & 0x1f;
        a[3] = (d >> 30) & 0x1f;
        b[3] = (d >> 35);

        r[4 * i + 0] = (uint16_t)(a[0]  - b[0]) & Qmod_minus1;
        r[4 * i + 1] = (uint16_t)(a[1]  - b[1]) & Qmod_minus1;
        r[4 * i + 2] = (uint16_t)(a[2]  - b[2]) & Qmod_minus1;
        r[4 * i + 3] = (uint16_t)(a[3]  - b[3]) & Qmod_minus1;
    }
#else
    asm volatile(
    "li t5,64 \n"
    "lp.setup x0,t5,(.LOOPS) \n"
        // Load 5 bytes
        "p.lw t0,4(%[address_lw]!) \n"
        "p.lb t1,1(%[address_lw]!) \n"

        // prepare first pair in t0,t2
        "srli t2,t0,5 \n"

        // prepare second pair in t3,t4
        "srli t3,t0,10 \n"
        "srli t4,t0,15 \n"

        // pack pairs
        "pv.pack.h t3,t3,t0 \n"
        "pv.pack.h t4,t4,t2 \n"       

        "pq.bs_k5 t4,t3,t4 \n"
        "p.sw t4,4(%[address_sw]!) \n"

        // prepare third pair in a0,a1
        "srli a0,t0,20 \n"
        "srli a1,t0,25 \n"

        // prepare fourth pair in a2,a3
        "srli a2,t0,30 \n"
        "slli a3,t1,2 \n"
        "or a2,a2,a3 \n" 
        "srli a3,t1,3 \n"

        // pack pairs
        "pv.pack.h a2,a2,a0 \n"
        "pv.pack.h a3,a3,a1 \n"

        "pq.bs_k5 a3,a2,a3 \n"
        "p.sw a3,4(%[address_sw]!) \n"
    ".LOOPS: \n"
    "nop \n"
   
    : : [address_lw]"r" (buf), [address_sw]"r" (r) : "a0","a1","a2","a3","cc","memory"
    );
#endif
}
