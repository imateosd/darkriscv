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
void update_individual_display(uint8_t display, uint8_t value, _Bool decimal_point, _Bool enabled) {
    if (enabled && value > 15) {
        printf("Value is too big to be displayed. Can only display a nibble!\n\r\n");
        return;
    }
    // Clear previous value for this display
    io->display_control &= ~(0xFF << (display * 8));
    // Set new value, decimal point, and enabled bit
    io->display_control |= ((value & 0x0F) | (decimal_point << 4) | (enabled << 7)) << (display * 8);
}

/**
 * @brief Updates the 4 individual displays with a 16 bit value.
 *
 * @param value The 16-bit value to be shown on the display.
 */
void update_display(uint16_t value) {
    uint8_t partial_value;
    for (uint8_t i = 0; i < 4; i++) {
        partial_value = (value >> (4 * i)) & 0xF;
        update_individual_display(i, partial_value, true, true);
    }
}

/**
 * @brief Waits for approximately 100 microseconds.
 */
void wait(int cycles) {
    while (cycles--) {
        __asm__ volatile ("nop");
    }
}

/**
 * @brief Waits for a specified number of cycles.
 *
 * @param cycles The number of cycles to wait.
 */
void wait_100us() {
    unsigned int start;
    asm volatile ("rdcycle %0" : "=r"(start));  // Read current cycle count
    while (1) {
        unsigned int now;
        asm volatile ("rdcycle %0" : "=r"(now));
        if ((now - start) >= 10000) break;  // Wait for 10,000 cycles
    }
}