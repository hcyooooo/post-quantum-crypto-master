#ifndef NTT_H
#define NTT_H

#include "inttypes.h"


void PQCLEAN_NEWHOPE512CCA_CLEAN_bitrev_vector(uint16_t *pol_in, uint16_t *pol_out);
void PQCLEAN_NEWHOPE512CCA_CLEAN_mul_coefficients(uint16_t *poly, const uint16_t *factors);
void PQCLEAN_NEWHOPE512CCA_CLEAN_ntt(uint16_t *pol_in, uint16_t *pol_out);
void PQCLEAN_NEWHOPE512CCA_CLEAN_invntt(uint16_t *pol_in, uint16_t *pol_out);

#endif
