#include "stdint.h"
#include "gpio.h"

int main(void) {
    asm volatile (
        "li  s1,0x1\n"
        "li  s2,0x2\n"
        "li  s3,0x3\n"
        "li  s4,0x4\n"
        "li  s5,0x5\n"
        "li  s6,0x6\n"
        "li  s7,0x7\n"
        "li  s8,0x8\n"
        "li  s9,0x9\n"
    );

    #define DATA_BASE_ADDR 0x00100000
    volatile uint32_t * debug_ptr1 = (uint32_t *) DATA_BASE_ADDR + 0x2328;
    volatile uint32_t * debug_ptr2 = (uint32_t *) DATA_BASE_ADDR + 0x2329;
    volatile uint32_t * debug_ptr3 = (uint32_t *) DATA_BASE_ADDR + 0x232a;
    volatile uint32_t * debug_ptr4 = (uint32_t *) DATA_BASE_ADDR + 0x232b;
    volatile uint32_t * debug_ptr5 = (uint32_t *) DATA_BASE_ADDR + 0x232c;

    *debug_ptr1 = 0xaaaa;
    *debug_ptr2 = 0xbbbb;
    *debug_ptr3 = 0xcccc;
    *debug_ptr4 = 0xdddd;
    *debug_ptr5 = 0xeeee;

    int a, b;
    a = 2;
    b = 3;
    *debug_ptr1 = a*b;


    while(1) { }
}


