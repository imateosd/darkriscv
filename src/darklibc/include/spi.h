#ifndef SPILIBRARY_H
#define SPILIBRARY_H

#include <stdint.h> // For standard integer types like uint32_t

typedef struct {
    // --------------- TX RELATED ------------------
    unsigned int data_to_send    : 8;  // Bits 0-7
    unsigned int n_bytes_to_send : 3;  // Bits 8-10
    unsigned int start           : 1;  // Bit 11
    // ---------------- RX RELATED ------------------
    unsigned int n_bytes_received: 2; // Bits 12-13
    unsigned int rx_data_ready   : 1; // Bit 14
    unsigned int data_received   : 8; // Bits 15-22
    unsigned int tx_ready        : 1; // Bit 23
    // ----------------- OTHERS --------------------
    unsigned int empty          : 8; // Bits 24-31
} SPI_RegisterBits;


// Define a union to overlay the struct and a 32-bit integer
typedef union {
    uint32_t raw;          // The full 32-bit integer
    SPI_RegisterBits fields;     // The bit-field struct
} SPI_Register;


// Function to initialize the SPI peripheral
void spi_init();

// Function to set the SPI clock frequency
void spi_set_clock_frequency(uint32_t frequency);

// Function to set the SPI data mode (polarity and phase)
void spi_set_data_mode(uint8_t mode);

// Function to enable/disable the SPI peripheral
void spi_enable();
void spi_disable();

// Function to send data over SPI
void spi_send_data(uint8_t data);

// Function to receive data over SPI
uint8_t spi_receive_data();

// Function to send and receive data over SPI
uint8_t spi_send_receive_data(uint8_t data);


#endif // SPILIBRARY_H