#ifndef GPIOLIBRARY_H
#define GPIOLIBRARY_H

#include <io.h>
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>

/**
 * @brief Sets the direction of a GPIO pin.
 *
 * @param pin The GPIO pin number to set.
 * @param output True to set as output.
 */
void gpio_direction(uint8_t pin, _Bool direction);

/**
 * @brief Sets the value of a GPIO pin.
 *
 * @param pin The GPIO pin number to set.
 * @param value The value to set the pin to (0 for low, 1 for high).
 */
void gpio_set(uint8_t pin, _Bool value);

/**
 * @brief Reads the value of a GPIO pin.
 *
 * @param pin The GPIO pin number to read.
 * @return true if the pin is high, false if the pin is low.
 */
_Bool gpio_get(uint8_t pin);

/**
 * @brief Sets the PWM duty cycle for a GPIO pin.
 *
 * @param pin The GPIO pin number to set.
 * @param duty_cycle The duty cycle value to set (0-255).
 */
void gpio_pwm_set_cycle(uint8_t pin, uint8_t duty_cycle);

/**
 * @brief Enables or disables PWM on a GPIO pin.
 *
 * @param pin The GPIO pin number to configure for PWM.
 * @param function_enabled True to enable PWM on the pin.
 */
void gpio_pwm_enable(uint8_t pin, _Bool pwm_enabled);

#endif // GPIOLIBRARY_H