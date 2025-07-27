#ifndef UTILSLIBRARY_H
#define UTILSLIBRARY_H

#include <io.h>
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>

/**
 * @brief Updates the value a 7-segment display.
 *
 *
 * @param display         The position of the display to update.
 * @param value           The value to display (typically 0-9 or A-F for hexadecimal).
 * @param decimal_point   If true, the decimal point will be illuminated.
 * @param enabled         If true, the display will be enabled; otherwise, it will be turned off.
 */
void update_individual_display(uint8_t display, uint8_t value, _Bool decimal_point, _Bool enabled);

/**
 * @brief Updates the 4 individual displays with a 16 bit value.
 *
 * @param value The 16-bit value to be shown on the display.
 */
void update_display(uint16_t value);


/**
 * @brief Waits for approximately 100 microseconds.
 */
void wait_100us();

/**
 * @brief Waits for a specified number of cycles.
 *
 * @param cycles The number of cycles to wait.
 */
void wait(int cycles);


#endif // UTILSLIBRARY_H