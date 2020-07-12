#include <string.h>
#include "gpio.h"
#include "api.h"

#define DEBUG

int main(void)
{

    set_gpio_pin_direction(0,DIR_OUT);
    set_gpio_pin_direction(1,DIR_OUT);
    set_gpio_pin_direction(2,DIR_OUT);
    set_gpio_pin_direction(3,DIR_OUT);
    set_gpio_pin_direction(4,DIR_OUT);
    set_gpio_pin_direction(5,DIR_OUT);
    set_gpio_pin_direction(6,DIR_OUT);
    set_gpio_pin_direction(7,DIR_OUT);


    unsigned char ct[PQCLEAN_KYBER512_CLEAN_CRYPTO_CIPHERTEXTBYTES], ss[PQCLEAN_KYBER512_CLEAN_CRYPTO_BYTES], ss1[PQCLEAN_KYBER512_CLEAN_CRYPTO_BYTES];
    unsigned char pk[PQCLEAN_KYBER512_CLEAN_CRYPTO_PUBLICKEYBYTES], sk[PQCLEAN_KYBER512_CLEAN_CRYPTO_SECRETKEYBYTES];

    set_gpio_pin_value(0,1);
    asm volatile("li  a6,0x4141");    // Register x16
    PQCLEAN_KYBER512_CLEAN_crypto_kem_keypair(pk, sk);
    asm volatile("li  a6,0x4242");
    set_gpio_pin_value(1,1);
    asm volatile("li  a6,0x4343");
    PQCLEAN_KYBER512_CLEAN_crypto_kem_enc(ct,ss,pk);
    asm volatile("li  a6,0x4444");
    set_gpio_pin_value(2,1);
    asm volatile("li  a6,0x4545");
    PQCLEAN_KYBER512_CLEAN_crypto_kem_dec(ss1,ct,sk);
    asm volatile("li  a6,0x4646");
    set_gpio_pin_value(3,1);
    if(memcmp(ss,ss1,PQCLEAN_KYBER512_CLEAN_CRYPTO_BYTES)) {  // If set, compare was false
    	set_gpio_pin_value(0,0);
    	set_gpio_pin_value(1,0);
    	set_gpio_pin_value(2,0);
    	set_gpio_pin_value(3,0);
    	set_gpio_pin_value(4,0);
    	set_gpio_pin_value(5,0);
    	set_gpio_pin_value(6,0);
    	set_gpio_pin_value(7,0);
    }
    else if (ss1[31] == 0x78) {
    	set_gpio_pin_value(0,1);
    	set_gpio_pin_value(1,1);
    	set_gpio_pin_value(2,1);
    	set_gpio_pin_value(3,1);
    	set_gpio_pin_value(4,1);
    	set_gpio_pin_value(5,1);
    	set_gpio_pin_value(6,1);
    	set_gpio_pin_value(7,1);
    }
    else {
    	set_gpio_pin_value(0,0);
    	set_gpio_pin_value(1,0);
    	set_gpio_pin_value(2,0);
    	set_gpio_pin_value(3,0);
    	set_gpio_pin_value(4,0);
    	set_gpio_pin_value(5,0);
    	set_gpio_pin_value(6,0);
    	set_gpio_pin_value(7,0);
    }

#ifdef DEBUG
    #define DATA_BASE_ADDR 0x00100000
    volatile uint32_t * debug_ptr0 = (uint32_t *) DATA_BASE_ADDR + 0x2327;
    volatile uint32_t * debug_ptr1 = (uint32_t *) DATA_BASE_ADDR + 0x2328;
    volatile uint32_t * debug_ptr2 = (uint32_t *) DATA_BASE_ADDR + 0x2329;
    volatile uint32_t * debug_ptr3 = (uint32_t *) DATA_BASE_ADDR + 0x232a;
    volatile uint32_t * debug_ptr4 = (uint32_t *) DATA_BASE_ADDR + 0x232b;
    volatile uint32_t * debug_ptr5 = (uint32_t *) DATA_BASE_ADDR + 0x232c;

    for(int i=0; i<PQCLEAN_KYBER512_CLEAN_CRYPTO_PUBLICKEYBYTES; i++)
    {
        *debug_ptr1 = pk[i];
    }
    for(int i=0; i<PQCLEAN_KYBER512_CLEAN_CRYPTO_SECRETKEYBYTES; i++)
    {
        *debug_ptr2 = sk[i];
    }
    for(int i=0; i<PQCLEAN_KYBER512_CLEAN_CRYPTO_CIPHERTEXTBYTES; i++)
    {
        *debug_ptr3 = ct[i];
    }
    for(int i=0; i<PQCLEAN_KYBER512_CLEAN_CRYPTO_BYTES; i++)
    {
        *debug_ptr4 = ss[i];
    }
    for(int i=0; i<PQCLEAN_KYBER512_CLEAN_CRYPTO_BYTES; i++)
    {
        *debug_ptr5 = ss1[i];
    }

#endif


    while(1) { }
}
