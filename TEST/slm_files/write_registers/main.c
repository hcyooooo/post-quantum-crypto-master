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

    while(1) { }
}


