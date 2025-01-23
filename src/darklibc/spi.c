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

void spi_send_data(uint8_t data) {
    // Send data over SPI
    // Implementation specific to the hardware
    
}

uint8_t spi_receive_data() {
    SPI_Register spi_register;
    spi_register.raw = io->spi;

    // Wait until the receive buffer is not empty
    while (spi_register.fields.rx_data_ready == 0) {
        // Wait for data to be received
        spi_register.raw = io->spi;
    }

    // Read the received data from the receive buffer
    uint8_t received_data = spi_register.fields.data_received;

    // Return the received data
    return received_data;
}

uint8_t spi_send_receive_data(uint8_t data) {
    // Send and receive data over SPI
    // Implementation specific to the hardware
    SPI_Register spi_register;

    // Wait until the transmit buffer is ready
    spi_register.raw = io->spi;
    while (spi_register.fields.tx_ready == 0) {
        // Wait for the transmit buffer to be ready
        spi_register.raw = io->spi;
    }

    // Configure the register to send data
    spi_register.fields.data_to_send = data;
    spi_register.fields.n_bytes_to_send = 3; // ?
    spi_register.fields.start = 1;


    // Write the data to the SPI peripheral
    io->spi = spi_register.raw;

    // Wait until the receive buffer is not empty
    spi_register.raw = io->spi;
    while (spi_register.fields.rx_data_ready == 0) {
        // Wait for data to be received
        spi_register.raw = io->spi;
    }

    // Read the number of bytes that have been received
    uint8_t n_bytes_received = spi_register.fields.n_bytes_received;

    // Read the received data from the receive buffer
    // Read all the received bytes from the receive buffer
    uint8_t received_data;
    for (uint8_t i = 0; i < n_bytes_received; i++) {
        spi_register.raw = io->spi;
        while (spi_register.fields.rx_data_ready == 0) {
            // Wait for data to be received
            spi_register.raw = io->spi;
        }
        received_data = spi_register.fields.data_received;
        // Process the received data here
        printf("Received data: %d\n", received_data);
    }

    // TO DO figure out a way to return all the received data bytes
    // Return the received data
    return received_data;

    return 0; // Placeholder return value
}

#endif