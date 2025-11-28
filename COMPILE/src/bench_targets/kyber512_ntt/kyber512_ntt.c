#include <stdint.h>
#include "params.h"
#include "poly.h"
#include "gpio.h"

// 给 a6 打标记，方便用 searchlog 找
static inline void mark(uint16_t v) {
    asm volatile ("li a6, %0" :: "i"(v));
}

int main(void) {
    // 1. 初始化 GPIO，当成可选的“窗口标记”
    for (int i = 0; i < 8; i++) {
        set_gpio_pin_direction(i, DIR_OUT);
        set_gpio_pin_value(i, 0);
    }

    // 2. 准备一个 poly，填充一点假数据（只要 deterministic 就行）
    poly a;
    for (int i = 0; i < KYBER_N; i++) {
        a.coeffs[i] = (int16_t)(i & 0xFF);
    }

    // ========================
    //   第一段：NTT baseline
    // ========================
    set_gpio_pin_value(0, 1);   // GPIO0 = 1, 表示 NTT 运行中
    mark(0x1111);               // a6 = 0x1111 → NTT 开始

    PQCLEAN_KYBER512_CLEAN_poly_ntt(&a);

    mark(0x2222);               // a6 = 0x2222 → NTT 结束
    set_gpio_pin_value(0, 0);   // GPIO0 = 0

    // ============================
    //   第二段：inverse NTT (iNTT)
    // ============================
    set_gpio_pin_value(1, 1);   // GPIO1 = 1, 表示 iNTT 运行中
    mark(0x3333);               // a6 = 0x3333 → iNTT 开始

    // 注意：如果链接时报 undefined reference，
    // 说明函数名可能是 PQCLEAN_KYBER512_CLEAN_poly_invntt_tomont，
    // 那就把下面这一行的函数名改一下即可。
    PQCLEAN_KYBER512_CLEAN_poly_invntt(&a);

    mark(0x4444);               // a6 = 0x4444 → iNTT 结束
    set_gpio_pin_value(1, 0);   // GPIO1 = 0

    // 防止程序结束
    while (1) { }

    return 0;
}
