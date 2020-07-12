#include "gpio.h"

int main(void) {
    set_gpio_pin_direction(0, DIR_OUT);
    set_gpio_pin_direction(1, DIR_OUT);
    set_gpio_pin_direction(2, DIR_OUT);
    set_gpio_pin_direction(3, DIR_OUT);
    set_gpio_pin_direction(4, DIR_OUT);
    set_gpio_pin_direction(5, DIR_OUT);
    set_gpio_pin_direction(6, DIR_OUT);
    set_gpio_pin_direction(7, DIR_OUT);
    set_gpio_pin_value(0, 1);
    set_gpio_pin_value(1, 1);
    set_gpio_pin_value(2, 1);
    set_gpio_pin_value(3, 1);
    set_gpio_pin_value(4, 1);
    set_gpio_pin_value(5, 1);
    set_gpio_pin_value(6, 1);
    set_gpio_pin_value(7, 1);

    while(1) { }
}


