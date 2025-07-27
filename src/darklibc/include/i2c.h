#ifndef I2CLIBRARY_H
#define I2CLIBRARY_H

#include <stdint.h>

typedef struct {
    unsigned int data          : 8;  // Bits 0-7   (Data to send if write, data received if read)
    unsigned int subaddress    : 16;  // Bits 8-15  (Subaddress)
    unsigned int slave_address : 8;  // Bits 16-23 (Slave Address)
} I2C_DataRegisterBits;
typedef struct {
    unsigned int start          : 1;  // Bit  0     (Trigger start)
    unsigned int n_bytes        : 3;  // Bits 1-3   (Number of bytes in transaction)
    unsigned int n_subaddress   : 1;  // Bit  4     (Number of bytes in subaddress - 1)
    unsigned int valid_out      : 1;  // Bit  5     (Valid data in the receive buffer)
    unsigned int nack           : 1;  // Bit  6     (NACK received)
    unsigned int req_data       : 1;  // Bit  7     (Request data)
    unsigned int busy           : 1;  // Bit  8     (Busy flag)
    unsigned int status         : 4;  // Bit  9-12  (Status)
} I2C_CtrlRegisterBits;

typedef union {
    uint32_t raw;             // The full 32-bit integer
    I2C_DataRegisterBits fields;  // The bit-field struct
} I2C_DataRegister;

typedef union {
    uint32_t raw;             // The full 32-bit integer
    I2C_CtrlRegisterBits fields;  // The bit-field struct
} I2C_CtrlRegister;


/**
 * @brief Sends a single byte via I2C.
 *
 * This function sends a byte to a specific slave device and subaddress over I2C.
 *
 * @param slaveAddress The I2C slave device address.
 * @param subaddress The register/subaddress within the slave device.
 * @param byteToSend The byte of data to be transmitted.
 * @return int 0 on success, -1 if no ACK received or if I2C is busy.
 */
// void i2c_write_single_byte(char, char, char);

// void i2cSendMultipleBytes(char slaveAddress, char subaddress, char byteToSend);


/**
 * @brief Reads a single byte via I2C.
 *
 * This function reads a byte from a specific slave device and subaddress over I2C.
 *
 * @param slaveAddress The I2C slave device address.
 * @param subaddress The register/subaddress within the slave device.
 * @return char The byte read, or -1 on error.
 */
// char i2c_read_single_byte(char, char);



void i2c_init();
void i2c_set_clock_frequency(uint32_t frequency);
uint8_t i2c_wait_for_module_free();
_Bool i2c_check_for_NACK();
void i2c_wait_for_valid_out();
uint8_t i2c_address_with_rw(uint8_t slave_address, _Bool is_read);

/**
 * @brief Executes an I2C transaction using the specified register settings.
 *
 * This function initiates communication over the I2C bus based on the configuration
 * provided in the i2c_register parameter. The register structure typically contains
 * information such as the target register address, control flags, and data payload,
 * which are essential for managing the I2C protocol transaction.
 *
 * @param i2c_register Structure containing I2C configuration parameters necessary
 *                     to perform the desired transaction.
 */
/*void i2c_transaction(I2C_Register i2c_register);
void i2c_write_single_byte(uint8_t slave_address, uint8_t data, uint8_t length);
void i2c_write_single_byte(uint8_t slave_address, uint8_t data, uint8_t length);
char i2c_read_single_byte(uint8_t slave_address, uint8_t length);
void i2c_write_multiple_byte(uint8_t slave_address, uint8_t* data, uint8_t length);
void i2c_read_multiple_byte(uint8_t slave_address, uint8_t* data, uint8_t length);*/

void i2c_write(uint8_t slave_address, uint8_t* wdata, uint8_t wsize);
void i2c_write_then_read(uint8_t slave_address, uint8_t* wdata, uint8_t* rdata, uint8_t wsize, uint8_t rsize);

void i2c_write_bytes(uint8_t slave_addr, uint16_t subaddr, uint8_t n_subaddr_bytes, const uint8_t *data, uint8_t n_data_bytes);
void i2c_read_bytes(uint8_t slave_addr, uint16_t subaddr, uint8_t subaddr_len, uint8_t* buffer, uint8_t length);

void ds1621_start_conversion(uint8_t i2c_addr);
int16_t ds1621_read_temperature_raw(uint8_t i2c_addr);

#endif // I2CLIBRARY_H