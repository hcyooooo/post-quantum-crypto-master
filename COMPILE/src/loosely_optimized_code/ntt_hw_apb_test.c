#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#include "uart.h"
#include "utils.h"
#include "gpio.h"

#define HW_NTT_BASE_ADDR        0x1A108000u
#define HW_NTT_REG(offset)     (*(volatile uint32_t *)(HW_NTT_BASE_ADDR + (offset)))

#define HW_NTT_CMD              0x000u
#define HW_NTT_CONFIG           0x004u
#define HW_NTT_PARAM_N          0x008u
#define HW_NTT_MODULUS          0x00Cu
#define HW_NTT_MIN_QINV         0x010u
#define HW_NTT_STATUS           0x034u
#define HW_NTT_RF_WINDOW_BASE   0x100u

#define HW_NTT_STATUS_BUSY_BIT      (1u << 0)
#define HW_NTT_STATUS_CONFLICT_BIT  (1u << 3)
#define HW_NTT_STATUS_WRITING_BIT   (1u << 4)

#define HW_NTT_RF_WORDS         128u
#define HW_NTT_TIMEOUT_CYCLES   1000000u

#define TEST_PARAM_N            256u
#define TEST_MODULUS            3329u
#define TEST_MIN_QINV           0x30CFFu

static inline void ntt_write(uint32_t offset, uint32_t value) {
    HW_NTT_REG(offset) = value;
}

static inline uint32_t ntt_read(uint32_t offset) {
    return HW_NTT_REG(offset);
}

static void uart_print(const char *str) {
    uart_send(str, (unsigned int)strlen(str));
}

static void u32_to_hex(uint32_t value, char *buffer) {
    static const char hex_chars[] = "0123456789ABCDEF";
    buffer[0] = '0';
    buffer[1] = 'x';
    for (int i = 0; i < 8; ++i) {
        buffer[2 + i] = hex_chars[(value >> (28 - 4 * i)) & 0xFu];
    }
    buffer[10] = '\0';
}

static void report_fail(const char *label, uint32_t expected, uint32_t observed) {
    char hex_buf[11];
    uart_print("[NTT][FAIL] ");
    uart_print(label);
    uart_print(" expected ");
    u32_to_hex(expected, hex_buf);
    uart_print(hex_buf);
    uart_print(" got ");
    u32_to_hex(observed, hex_buf);
    uart_print(hex_buf);
    uart_print("\r\n");
}

static int wait_for_regfile_idle(void) {
    for (uint32_t iter = 0; iter < HW_NTT_TIMEOUT_CYCLES; ++iter) {
        uint32_t status = ntt_read(HW_NTT_STATUS);
        if ((status & HW_NTT_STATUS_WRITING_BIT) == 0u) {
            if (status & HW_NTT_STATUS_CONFLICT_BIT) {
                ntt_write(HW_NTT_STATUS, HW_NTT_STATUS_CONFLICT_BIT);
            }
            return 0;
        }
    }
    return -1;
}

static bool verify_register(uint32_t offset, uint32_t mask, uint32_t test_value, const char *label) {
    uint32_t original = ntt_read(offset);
    ntt_write(offset, test_value);
    uint32_t observed = ntt_read(offset) & mask;
    ntt_write(offset, original);

    if (observed != (test_value & mask)) {
        report_fail(label, test_value & mask, observed);
        return false;
    }
    return true;
}

static bool test_register_block(void) {
    bool ok = true;
    ok &= verify_register(HW_NTT_PARAM_N, 0x7FFu, TEST_PARAM_N, "PARAM_N");
    ok &= verify_register(HW_NTT_MODULUS, 0xFFFFu, TEST_MODULUS, "MODULUS");
    ok &= verify_register(HW_NTT_MIN_QINV, 0x3FFFFu, TEST_MIN_QINV, "MIN_QINV");
    ok &= verify_register(HW_NTT_CONFIG, 0x3u, 0x0u, "CONFIG");
    return ok;
}

static bool test_rf_window(void) {
    if (wait_for_regfile_idle() != 0) {
        uart_print("[NTT][FAIL] RF window busy timeout\r\n");
        return false;
    }

    for (uint32_t i = 0; i < HW_NTT_RF_WORDS; ++i) {
        uint32_t pattern = 0xCAFE0000u | i;
        ntt_write(HW_NTT_RF_WINDOW_BASE + (i << 2), pattern);
    }

    bool ok = true;
    for (uint32_t i = 0; i < HW_NTT_RF_WORDS; ++i) {
        uint32_t expected = 0xCAFE0000u | i;
        uint32_t observed = ntt_read(HW_NTT_RF_WINDOW_BASE + (i << 2));
        if (observed != expected) {
            char hex_buf[11];
            uart_print("[NTT][FAIL] RF word index ");
            u32_to_hex(i, hex_buf);
            uart_print(hex_buf);
            uart_print("\r\n");
            report_fail("RF word", expected, observed);
            ok = false;
            break;
        }
    }
    return ok;
}

static bool test_ntt_command(void) {
    if (wait_for_regfile_idle() != 0) {
        uart_print("[NTT][FAIL] CMD wait timeout\r\n");
        return false;
    }

    ntt_write(HW_NTT_PARAM_N, TEST_PARAM_N);
    ntt_write(HW_NTT_MODULUS, TEST_MODULUS);
    ntt_write(HW_NTT_MIN_QINV, TEST_MIN_QINV);
    ntt_write(HW_NTT_CONFIG, 0x1u);

    ntt_write(HW_NTT_CMD, 0x1u);

    bool busy_seen = false;
    for (uint32_t iter = 0; iter < HW_NTT_TIMEOUT_CYCLES; ++iter) {
        uint32_t status = ntt_read(HW_NTT_STATUS);
        if (status & HW_NTT_STATUS_BUSY_BIT) {
            busy_seen = true;
            break;
        }
    }

    ntt_write(HW_NTT_STATUS, HW_NTT_STATUS_BUSY_BIT);

    if (!busy_seen) {
        uart_print("[NTT][FAIL] CMD busy flag never asserted\r\n");
        return false;
    }

    return true;
}

int main(void) {
    uart_set_cfg(0, 1);      // parity disabled, divisor=1 matches PULPino default 115200 baud
    bool ok = true;

    uart_print("\r\n[NTT] APB register test start\r\n");
    set_gpio_pin_value(0,1);
    set_gpio_pin_value(1,1);
    set_gpio_pin_value(2,1);
    set_gpio_pin_value(3,1);
    // if (!test_register_block()) {
    //     ok = false;
    // }

    // if (!test_rf_window()) {
    //     ok = false;
    // }

    // if (!test_ntt_command()) {
    //     ok = false;
    // }

    // if (ok) {
    //     uart_print("[NTT] All tests PASSED\r\n");
    //     eoc(0);
    // } else {
    //     uart_print("[NTT] Tests FAILED\r\n");
    //     eoc(1);
    // }



    while (1) { }
    return 0;
}
