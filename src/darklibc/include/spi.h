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
    // ---------------- CONTROL ---------------------
    unsigned int tx_ready        : 1; // Bit 23
    unsigned int slave_select    : 2; // Bits 24-25. Can be 1,2 or 3
    // ----------------- OTHERS --------------------
    unsigned int empty           : 6; // Bits 26-31
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

// Functions to enable/disable the SPI peripheral
void spi_enable();
void spi_disable();


/**
 * @brief Performs a single byte SPI transaction.
 *
 * This function initiates a single byte transaction over the SPI interface
 * using the provided SPI register configuration.
 *
 * @param new_spi_register [SPI_Register] The SPI register configuration to be used for the transaction.
 * @return [uint8_t] The byte received from the SPI transaction.
 */
uint8_t spi_transaction_single_byte(SPI_Register);

/**
 * @brief Transmits a single byte via SPI and simultaneously receives a byte.
 *
 * This function sends a single byte of data through the SPI interface and 
 * reads a byte of data received from the SPI slave device. Used for full-duplex communication where data is sent and received 
 * simultaneously.
 *
 * @param data The byte of data to be transmitted.
 * @param length The number of bytes to be in the complete transaction. Should be 1 when not called as part of a multi-byte transaction.
 * @param slave The slave device to communicate with.
 * @return uint8_t The byte received from the SPI transaction.
 */
uint8_t spi_write_read_single_byte(uint8_t, uint8_t, uint8_t);

/**
 * @brief Reads a single byte from the SPI bus.
 *
 * This function performs a read operation on the SPI bus and returns the 
 * byte that was read. Used to receive data from an SPI slave device.
 * 
 * @param length The number of bytes to be in the complete transaction. Should be 1 when not called as part of a multi-byte transaction.
 * @param slave The slave device to communicate with.
 * @return uint8_t The byte read from the SPI bus.
 */
uint8_t spi_read_single_byte(uint8_t, uint8_t);

/**
 * @brief Writes a single byte to the SPI bus.
 *
 * This function sends a single byte of data over the SPI bus.
 *
 * @param data The byte of data to be sent.
 * @param length The number of bytes to be in the complete transaction. Should be 1 when not called as part of a multi-byte transaction.
 * @param slave The slave device to communicate with.
 */
void spi_write_single_byte(uint8_t, uint8_t, uint8_t);

/**
 * @brief Reads multiple bytes from the SPI interface.
 *
 * This function reads a specified number of bytes from the SPI interface
 * and stores them in the provided buffer.
 *
 * @param rx_data Pointer to the buffer where the received data will be stored.
 * @param length The number of bytes to read from the SPI interface.
 * @param slave The slave device to communicate with.
 */
void spi_read_multiple_bytes(uint8_t*, uint8_t, uint8_t);

/**
 * @brief Writes multiple bytes to the SPI bus.
 *
 * This function sends a sequence of bytes over the SPI bus.
 *
 * @param data Pointer to the array of bytes to be sent.
 * @param length Number of bytes to be sent.
 * @param slave The slave device to communicate with.
 */
void spi_write_multiple_bytes(uint8_t*, uint8_t, uint8_t);

/**
 * @brief Writes and reads multiple bytes over SPI.
 *
 * This function transmits and receives a specified number of bytes over the SPI bus.
 *
 * @param tx_data Pointer to the data to be transmitted.
 * @param rx_data Pointer to the buffer where received data will be stored.
 * @param length Number of bytes to be transmitted and received.
 * @param slave The slave device to communicate with.
 */
void spi_write_read_multiple_bytes(uint8_t*, uint8_t*, uint8_t, uint8_t);


#endif // SPILIBRARY_H