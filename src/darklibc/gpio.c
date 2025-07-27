// #include <io.h>
#include <gpio.h>


#ifdef __RISCV__

/**
 * @brief Sets the direction of a GPIO pin.
 *
 * @param pin The GPIO pin number to set.
 * @param output True to set as output.
 */
void gpio_direction(uint8_t pin, _Bool direction) {
    if (direction) {
        io->gpio_ctrl |= (1 << pin);   // Set bit to configure as output
    } else {
        io->gpio_ctrl &= ~(1 << pin);  // Clear bit to configure as input
    }
}

/**
 * @brief Sets the value of a GPIO pin.
 *
 * @param pin The GPIO pin number to set.
 * @param value The value to set the pin to (0 for low, 1 for high).
 */
void gpio_set(uint8_t pin, _Bool value) {
    if (value) {
        io->gpio |= (1 << pin);   // Set bit to configure as output
    } else {
        io->gpio &= ~(1 << pin);  // Clear bit to configure as input
    }
}

/**
 * @brief Reads the value of a GPIO pin.
 *
 * @param pin The GPIO pin number to read.
 * @return true if the pin is high, false if the pin is low.
 */
_Bool gpio_get(uint8_t pin) {
    return (_Bool)(io->gpio & (1 << pin));
}

/**
 * @brief Sets the PWM duty cycle for a GPIO pin.
 *
 * @param pin The GPIO pin number to set.
 * @param duty_cycle The duty cycle value to set (0-255).
 */
void gpio_pwm_set_cycle(uint8_t pin, uint8_t duty_cycle) {
    if (pin < 4)
        io->pwm_control = (io->pwm_control & 0xFFFFFF00) | duty_cycle; // Set PWM duty cycle for the first PWM module
    else if (pin < 8)
        io->pwm_control = (io->pwm_control & 0xFFFF00FF) | (duty_cycle << 8); // Set PWM duty cycle for the second PWM module
    else if (pin < 12)
        io->pwm_control = (io->pwm_control & 0xFF00FFFF) | (duty_cycle << 16); // Set PWM duty cycle for the third PWM module
    else
        io->pwm_control = (io->pwm_control & 0x00FFFFFF) | (duty_cycle << 24); // Set PWM duty cycle for the fourth PWM module
}

/**
 * @brief Enables or disables PWM on a GPIO pin.
 *
 * @param pin The GPIO pin number to configure for PWM.
 * @param function_enabled True to enable PWM on the pin.
 */
void gpio_pwm_enable(uint8_t pin, _Bool pwm_enabled) {
    if (pwm_enabled) {
        io->gpio_function |= (1 << pin);   // Enable PWM on the pin
    } else {
        io->gpio_function &= ~(1 << pin);  // Disable PWM on the pin
    }
}

#endif