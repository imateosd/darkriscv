#include <io.h>
#include <spi.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>

#ifdef __RISCV__

void spi_init() {
    // Initialize the SPI peripheral
    // Implementation specific to the hardware
}

void spi_set_clock_frequency(uint32_t frequency) {
    // Set the SPI clock frequency
    // Implementation specific to the hardware
}

void spi_set_data_mode(uint8_t mode) {
    // Set the SPI data mode (polarity and phase)
    // Implementation specific to the hardware
}

void spi_enable() {
    // Enable the SPI peripheral
    // Implementation specific to the hardware
}

void spi_disable() {
    // Disable the SPI peripheral
    // Implementation specific to the hardware
}

/**
 * @brief Performs a single byte SPI transaction.
 *
 * This function initiates a single byte transaction over the SPI interface
 * using the provided SPI register configuration.
 *
 * @param new_spi_register [SPI_Register] The SPI register configuration to be used for the transaction.
 * @return [uint8_t] The byte received from the SPI transaction.
 */
uint8_t spi_transaction_single_byte(SPI_Register new_spi_register)
{
    // Send and receive data over SPI
    SPI_Register current_spi_register;

    // Wait until the transmit buffer is ready
    current_spi_register.raw = io->spi;
    while (current_spi_register.fields.tx_ready == 0) {
        // Wait for the transmit buffer to be ready
        current_spi_register.raw = io->spi;
    }
    new_spi_register.fields.tx_ready = 1; // Erase tx_ready flag
    new_spi_register.fields.rx_data_ready = 1; // Erase rx_data_ready flag
    // Write the data to the SPI peripheral
    io->spi = new_spi_register.raw;

    // Wait until the transaction has finished
    new_spi_register.raw = io->spi;
    while (new_spi_register.fields.tx_ready == 0) {
        new_spi_register.raw = io->spi;
    }
    // Wait for data to be available
    while (new_spi_register.fields.rx_data_ready == 0) {
        // Wait for data to be received
        new_spi_register.raw = io->spi;
    }
    uint8_t data_received = new_spi_register.fields.data_received;
    // printf("Received data: %d ", data_received);

    return data_received;
}

/**
 * @brief Transmits a single byte via SPI and simultaneously receives a byte.
 *
 * This function sends a single byte of data through the SPI interface and 
 * reads a byte of data received from the SPI slave device. Used for full-duplex communication where data is sent and received 
 * simultaneously.
 *
 * @param data The byte of data to be transmitted.
 * @param length The number of bytes to be in the transaction.
 * @param length The number of bytes to be in the complete transaction. Should be 1 when not called as part of a multi-byte transaction.
 * @param slave The slave device to communicate with.
 * @return uint8_t The byte received from the SPI transaction.
 */
uint8_t spi_write_read_single_byte(uint8_t data, uint8_t length, uint8_t slave)
{
    SPI_Register spi_register;
    spi_register.fields.data_to_send = data;
    spi_register.fields.n_bytes_to_send = length;
    spi_register.fields.start = 1;
    spi_register.fields.slave_select = slave;

    return spi_transaction_single_byte(spi_register);
}

/**
 * @brief Writes a single byte to the SPI bus.
 *
 * This function sends a single byte of data over the SPI bus.
 *
 * @param data The byte of data to be sent.
 * @param length The number of bytes to be in the complete transaction. Should be 1 when not called as part of a multi-byte transaction.
 * @param slave The slave device to communicate with.
 */
void spi_write_single_byte(uint8_t data,  uint8_t length, uint8_t slave)
{    
    SPI_Register spi_register;
    spi_register.fields.data_to_send = data;
    spi_register.fields.n_bytes_to_send = length;
    spi_register.fields.start = 1;
    spi_register.fields.slave_select = slave;

    spi_transaction_single_byte(spi_register);
}

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
uint8_t spi_read_single_byte(uint8_t length, uint8_t slave)
{
    SPI_Register spi_register;
    spi_register.fields.data_to_send = 0;
    spi_register.fields.n_bytes_to_send = length;
    spi_register.fields.start = 1;
    spi_register.fields.slave_select = slave;

    return spi_transaction_single_byte(spi_register);
}

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
void spi_write_read_multiple_bytes(uint8_t *tx_data, uint8_t *rx_data, uint8_t length, uint8_t slave) {
    for (uint8_t i = 0; i < length; i++) {
        rx_data[i] = spi_write_read_single_byte(tx_data[i], length, slave);
    }
}

/**
 * @brief Writes multiple bytes to the SPI bus.
 *
 * This function sends a sequence of bytes over the SPI bus.
 *
 * @param data Pointer to the array of bytes to be sent.
 * @param length Number of bytes to be sent.
 * @param slave The slave device to communicate with.
 */
void spi_write_multiple_bytes(uint8_t *data, uint8_t length, uint8_t slave) {
    for (uint8_t i = 0; i < length; i++) {
        spi_write_single_byte(data[i], length, slave);
    }
}

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
void spi_read_multiple_bytes(uint8_t *rx_data, uint8_t length, uint8_t slave) {
    for (uint8_t i = 0; i < length; i++) {
        rx_data[i] = spi_read_single_byte(length, slave);
    }
}

#endif