#include <io.h>

#ifdef __RISCV__

#include <stdint.h>
#include <stdio.h>
#include <i2c.h>

// Function to initialize I2C (configure clock and enable the peripheral)
void i2c_init() {
    // Implementation specific to hardware, assuming necessary register settings are handled here
    printf("I2C initialized\n");
}

// Function to set I2C clock frequency (to be customized according to your hardware)
void i2c_set_clock_frequency(uint32_t frequency) {
    // Implementation for setting the I2C clock frequency
    printf("I2C clock set to %u Hz\n", frequency);
}

// // Start condition function
// void i2c_start() {
//     while (i2c_register->fields.busy) {
//         // Wait for I2C bus to become available
//     }

//     i2c_register->fields.start = 1;  // Generate a start condition
//     i2c_register->raw = i2c_register->raw;  // Write back to trigger the start
// }

// // Stop condition function
// void i2c_stop() {
//     while (i2c_register->fields.busy) {
//         // Wait for I2C bus to become available
//     }

//     i2c_register->fields.start = 0;  // Stop condition is not explicit in your struct, but assuming we can just clear it
//     i2c_register->raw = i2c_register->raw;  // Write back
// }

// Wait until the current I2C operation completes
uint8_t i2c_wait_for_module_free() {
    I2C_CtrlRegister current_i2c_ctrl_register;
    int timeout = 1000000;  // Timeout value
    
    current_i2c_ctrl_register.raw = io->i2c_ctrl;
    // Wait until the I2C Master is free
    wait(5);
    /*printf("Wait for module free -> busy is %d \n", current_i2c_ctrl_register.fields.busy);
    printf("Wait for module free -> valid_out is %d \n", current_i2c_ctrl_register.fields.valid_out);
    printf("Wait for module free -> nack is %d \n", current_i2c_ctrl_register.fields.nack);
    printf("Wait for module free -> req_data is %d \n", current_i2c_ctrl_register.fields.req_data);*/
    while (current_i2c_ctrl_register.fields.busy) {
        if (--timeout == 0) {
            printf("TIMEOUT!!\n");
            return -1;  // Return an error code if timeout occurs
        }
        // Get the status of the I2C Master
        if (timeout%100 == 0) 
        { 
            /*printf("Waiting for module free -> busy is %d \n", current_i2c_ctrl_register.fields.busy);
            printf("Waiting for module free -> valid_out is %d \n", current_i2c_ctrl_register.fields.valid_out);
            printf("Waiting for module free -> nack is %d \n", current_i2c_ctrl_register.fields.nack);
            printf("Waiting for module free -> req_data is %d \n", current_i2c_ctrl_register.fields.req_data);
            printf("Waiting for module free ->  I2C status is %x \n", current_i2c_ctrl_register.fields.status);*/
            current_i2c_ctrl_register.raw = io->i2c_ctrl;
        }
    }
    // printf("Module is free -> busy is %d \n", current_i2c_ctrl_register.fields.busy);
    // printf("Module is free -> valid_out is %d \n", current_i2c_ctrl_register.fields.valid_out);
    // printf("Module is free -> nack is %d \n", current_i2c_ctrl_register.fields.nack);
    // printf("Module is free -> req_data is %d \n", current_i2c_ctrl_register.fields.req_data);
    return 0;
}

// Check for NACK
_Bool i2c_check_for_NACK() {
    I2C_CtrlRegister current_i2c_register;

    current_i2c_register.raw = io->i2c_ctrl;
    return current_i2c_register.fields.nack; // Returns true if there was a nack, false otherwise
}

/**
 * @brief Waits until a valid output is available on the I2C interface.
 *
 * This function blocks execution until the I2C Master signals that the received data 
 * output is valid.
 */
void i2c_wait_for_valid_out() {
    I2C_CtrlRegister current_i2c_register;

    // Wait until there is valid data in the receive buffer
    current_i2c_register.raw = io->i2c_ctrl;
    while (!current_i2c_register.fields.valid_out)
        current_i2c_register.raw = io->i2c_ctrl;
}

/**
 * @brief Computes the I2C slave address with the added read/write bit.
 *
 * This function takes a base 7-bit slave address and appends the R/W bit to it.
 *
 * @param slave_address  The 7-bit I2C slave address.
 * @param is_read        A boolean flag where true indicates a read operation and false indicates a write operation.
 *
 * @return uint8_t       The 8-bit I2C address including the read/write bit.
 */
uint8_t i2c_address_with_rw(uint8_t slave_address, _Bool is_read) {
    // Set the least significant bit to 0 for write or 1 for read
    return (slave_address << 1) | is_read;
}

/**
 * @brief Executes an I2C transaction using the specified register settings.
 *
 * This function initiates communication over the I2C bus based on the configuration
 * provided in the i2c_register parameter.
 *
 * @param i2c_register Structure containing I2C configuration parameters necessary
 *                     to perform the desired transaction.
 */
/*void i2c_transaction(I2C_Register i2c_register) {
    i2c_wait_for_module_free();  // Wait until the master is free
    i2c_register.fields.req_data = 1;  // Erase the req_data flag
    i2c_register.fields.valid_out = 1;  // Erase the valid_out flag
    io->i2c = i2c_register.raw;  // Trigger the I2C transaction
    // uint8_t operation_status = i2c_wait_for_module_free();  // Wait until the operation completes
    // if(operation_status != 0)
        if( i2c_check_for_NACK() )
            printf("NACK\n");
        else
            printf("I2C operation timed out\n");
}*/

/**
 * @brief Writes a single byte to a specified subaddress of an I2C slave device.
 *
 * This function sends a single byte of data to a given I2C slave device at the specified subaddress.
 * The length parameter indicates the number of bytes intended for the complete transaction.
 *
 * @param slave_address The I2C address of the target slave device.
 * @param subaddress The register or memory location within the slave device where data will be written.
 * @param data The byte of data to be written.
 * @param length The number of bytes for the write operation
 */
/*void i2c_write_single_byte(uint8_t slave_address, uint8_t data, uint8_t length) {
    I2C_Register i2c_register;

    uint8_t address = i2c_address_with_rw(slave_address, 0);  // 0 for write

    i2c_register.fields.data = data;
    i2c_register.fields.slave_address = address;  // Use the address with write bit
    i2c_register.fields.subaddress = 0x00;
    i2c_register.fields.n_bytes = length;
    i2c_register.fields.start = 1;   // Start transaction
    
    i2c_transaction(i2c_register);
}*/

/**
 * @brief Reads a single byte from an I2C slave device.
 *
 * This function initiates an I2C communication with the specified slave device,
 * sends the given subaddress, and reads a single byte of data. 
 * The length parameter indicates the number of bytes intended for the complete transaction.
 *
 * @param slave_address The 7-bit address of the I2C slave device.
 * @param subaddress    The register or memory address within the slave device from which to read.
 * @param length        The number of bytes to read. For a single byte read, this should be 1.
 *
 * @return The byte read from the slave device.
 */
/*char i2c_read_single_byte(uint8_t slave_address, uint8_t length) {
    I2C_Register i2c_register;

    uint8_t address = i2c_address_with_rw(slave_address, 1);  // 1 for read

    i2c_register.fields.data = 0;  // No data is being sent
    i2c_register.fields.slave_address = address;  // Use the address with read bit
    i2c_register.fields.subaddress = 0x00;
    i2c_register.fields.n_bytes = length;
    i2c_register.fields.start = 1;   // Start transaction
    
    //wait for the data to be available
    i2c_transaction(i2c_register);

    // Read received data from I2C register
    i2c_register.raw = io->i2c;
    return i2c_register.fields.data;
}*/

// Write data to the I2C bus
/*void i2c_write_multiple_byte(uint8_t slave_address, uint8_t* data, uint8_t length) {
    I2C_Register i2c_register;

    i2c_write_single_byte(slave_address, data[0], length);

    for (uint8_t i = 1; i < length; i++) {
        i2c_register.raw = io->i2c;
        
        // Wait for the master to request another byte to send
        while (!i2c_register.fields.req_data)
            i2c_register.raw = io->i2c;
        // Send a new byte to the I2C Master to send to the slave
        i2c_write_single_byte(slave_address, data[i], length);
    }
}*/

// Write data to the I2C bus
/*void i2c_read_multiple_byte(uint8_t slave_address, uint8_t* data, uint8_t length) {
    for (uint8_t i = 0; i < length; i++) {
        data[i] = i2c_read_single_byte(slave_address, length);
    }
}*/

void i2c_write(uint8_t slave_address, uint8_t* wdata, uint8_t wsize) {
    I2C_DataRegister data_register;
    I2C_CtrlRegister ctrl_register;
    data_register.fields.slave_address = (slave_address << 1) + 0; // Address with RW' = 0

    data_register.fields.subaddress = wdata[0];
    ctrl_register.fields.n_subaddress = 0;
    ctrl_register.fields.n_bytes = 0;
    if (wsize >= 2) {
        data_register.fields.subaddress |= wdata[1] << 8;
        ctrl_register.fields.n_subaddress = 1;
        ctrl_register.fields.n_bytes = wsize - 2;
    }

    if (wsize >= 3) {
        data_register.fields.data = wdata[2];
        ctrl_register.fields.n_bytes = wsize - 2;
    }
    
    ctrl_register.fields.start = 1;
    ctrl_register.fields.n_bytes = wsize - 2;

    i2c_wait_for_module_free();
    io->i2c_data = data_register.raw;
    io->i2c_ctrl = ctrl_register.raw;

    if (wsize > 3) {
        // keep sending wdata checking req data.
    }
}

void i2c_write_then_read(uint8_t slave_address, uint8_t* wdata, uint8_t* rdata, uint8_t wsize, uint8_t rsize) {
    I2C_DataRegister data_register;
    I2C_CtrlRegister ctrl_register;

    data_register.raw = 0x00;
    ctrl_register.raw = 0x00;

    data_register.fields.slave_address = (slave_address << 1) + 1; // Address with RW' = 1

    data_register.fields.subaddress = wdata[0];
    ctrl_register.fields.n_subaddress = 0;
    ctrl_register.fields.n_bytes = 0;
    
    if (wsize >= 2) {
        data_register.fields.subaddress |= wdata[1] << 8;
        ctrl_register.fields.n_subaddress = 1;
        ctrl_register.fields.n_bytes = wsize - 2;
    }

    if (wsize >= 3) {
        data_register.fields.data = wdata[2];
        ctrl_register.fields.n_bytes = wsize - 2;
    }
    
    ctrl_register.fields.start = 1;

    printf("n_bytes %d \n", ctrl_register.fields.n_bytes);

    printf("i2c_data to be written = %x \n" , data_register.raw);
    printf("i2c_ctrl to be written = %x \n" , ctrl_register.raw);

    printf("going to wait for module\n");
    i2c_wait_for_module_free();
    printf("module free, writing to register\n");
    io->i2c_data = data_register.raw;
    io->i2c_ctrl = ctrl_register.raw;

    if (wsize > 3) {
        // keep sending wdata.
    }

    printf("going to wait for module to finish my transaction \n");
    i2c_wait_for_module_free();
    printf("module free after my transaction\n");
    
    printf("going to wait for valid out\n");
    i2c_wait_for_valid_out();
    printf("valid out is set!\n");

    // Erase the flag
    ctrl_register.fields.valid_out = 1;
    io->i2c_ctrl = ctrl_register.raw;

    data_register.raw = io->i2c_data;
    return data_register.fields.data;
}


/**
 * @brief Writes a sequence of bytes to an I2C slave device.
 *
 * This function sends data to a specified I2C slave device, starting at a given subaddress.
 * It supports devices with variable-length subaddresses (e.g., 1 or 2 bytes).
 *
 * @param slave_addr        7-bit I2C address of the slave device.
 * @param subaddr           Subaddress/register within the slave device to write to.
 * @param n_subaddr_bytes   Number of bytes used for the subaddress (typically 1 or 2).
 * @param data              Pointer to the buffer containing the data to be written.
 * @param n_data_bytes      Number of data bytes to write from the buffer.
 */
void i2c_write_bytes(uint8_t slave_addr, uint16_t subaddr, uint8_t n_subaddr_bytes, const uint8_t *data, uint8_t n_data_bytes) {
    // Send each byte of data in sequence
    I2C_DataRegister data_register = {0};
    I2C_CtrlRegister ctrl_register = {0};

    for (uint8_t i = 0; i < n_data_bytes; ++i) {
        data_register.fields.data = data[i];
        data_register.fields.subaddress = subaddr;
        data_register.fields.slave_address = slave_addr << 1;

        ctrl_register.fields.n_bytes = 1; // One byte per transaction
        ctrl_register.fields.n_subaddress = subaddr;
        ctrl_register.fields.n_subaddress = n_subaddr_bytes - 1;
        ctrl_register.fields.req_data = 0; // This is a write
        ctrl_register.fields.start = 1;    // Trigger transaction

        io->i2c_ctrl = ctrl_register.raw;

        // Wait for busy flag to clear
        ctrl_register.raw = io->i2c_ctrl;
        while (ctrl_register.fields.busy) {
            ctrl_register.raw = io->i2c_ctrl;
        }
    }

    // If no data bytes are given, but a subaddress is specified (e.g. 0xEE)
    if (n_data_bytes == 0 && n_subaddr_bytes > 0) {
        data_register.fields.subaddress = subaddr;
        data_register.fields.slave_address = slave_addr << 1;

        // ctrl_register.fields.n_bytes = 1; // No data but we need to go through the state in the FSM
        ctrl_register.fields.n_bytes = 0; // No data
        ctrl_register.fields.n_subaddress = n_subaddr_bytes - 1;
        ctrl_register.fields.req_data = 0;
        ctrl_register.fields.start = 1;

        io->i2c_data = data_register.raw;
        io->i2c_ctrl = ctrl_register.raw;

        // ctrl_register.raw = io->i2c_ctrl;
        // while (ctrl_register.fields.busy) {
        //     ctrl_register.raw = io->i2c_ctrl;
        // }
        i2c_wait_for_module_free();
    }
}

uint8_t i2c_read_byte(uint8_t slave_addr, uint16_t subaddr, uint8_t subaddr_len) {
    I2C_DataRegister data_reg = {0};
    I2C_CtrlRegister ctrl_reg = {0};

    data_reg.fields.subaddress = subaddr;
    data_reg.fields.slave_address = (slave_addr << 1) | 0x01;  // LSB = 1 for read

    ctrl_reg.fields.start = 1;
    ctrl_reg.fields.n_bytes = 1;                 // 1 byte to read
    ctrl_reg.fields.n_subaddress = subaddr_len - 1;

    io->i2c_data = data_reg.raw;
    io->i2c_ctrl = ctrl_reg.raw;

    i2c_wait_for_module_free();

    I2C_CtrlRegister result_ctrl;
    result_ctrl.raw = io->i2c_ctrl;
    if (result_ctrl.fields.valid_out && !result_ctrl.fields.nack) {
        I2C_DataRegister result_data;
        result_data.raw = io->i2c_data;

        // Erase the flag
        result_ctrl.fields.valid_out = 1;
        io->i2c_ctrl = result_ctrl.raw;

        return result_data.fields.data;
    } else {
        // Handle NACK or invalid data
        return 0xFF;
    }
}

/**
 * @brief Reads multiple bytes from an I2C slave device.
 *
 * This function reads a specified number of bytes from a given subaddress of an I2C slave device.
 *
 * @param slave_addr    The 7-bit I2C address of the slave device.
 * @param subaddr       The subaddress (register address) within the slave device to start reading from.
 * @param subaddr_len   The length (in bytes) of the subaddress (typically 1 or 2).
 * @param buffer        Pointer to the buffer where the read data will be stored.
 * @param length        Number of bytes to read from the slave device.
 */
void i2c_read_bytes(uint8_t slave_addr, uint16_t subaddr, uint8_t subaddr_len, uint8_t* buffer, uint8_t length) {
    I2C_DataRegister data_reg = {0};
    I2C_CtrlRegister ctrl_reg = {0};

    data_reg.fields.subaddress = subaddr;
    data_reg.fields.slave_address = (slave_addr << 1) | 0x01;  // Read (LSB = 1)

    ctrl_reg.fields.start = 1;
    ctrl_reg.fields.n_bytes = length;              // Number of bytes to read
    ctrl_reg.fields.n_subaddress = subaddr_len - 1; // Number of subaddress bytes - 1

    io->i2c_data = data_reg.raw;
    io->i2c_ctrl = ctrl_reg.raw;

    for (uint8_t i = 0; i < length; i++) {
        // Wait for data to become valid
        I2C_CtrlRegister status;
        do {
            status.raw = io->i2c_ctrl;
        } while (!status.fields.valid_out && !status.fields.nack);

        if (status.fields.nack) {
            // Handle NACK (device didn't respond)
            buffer[i] = 0xFF;
            return;
        }

        // Erase the flag
        status.fields.valid_out = 1;
        io->i2c_ctrl = status.raw;

        I2C_DataRegister data;
        data.raw = io->i2c_data;
        buffer[i] = data.fields.data;
    }

    // Wait until controller is no longer busy (end of transaction)
    i2c_wait_for_module_free();
}

/*float ds1621_read_temperature(uint8_t i2c_addr) {
    uint8_t temp_data[2];

    // Read 2 bytes from temperature register (subaddress 0xAA)
    i2c_read_bytes(i2c_addr, 0xAA, 1, temp_data, 2);

    // Combine bytes into signed 16-bit value (MSB first)
    int16_t raw_temp = (temp_data[0] << 8) | temp_data[1];

    // DS1621 gives temperature in 2's complement, 9-bit (0.5°C precision)
    float temperature = raw_temp / 256.0f;

    return temperature;
}*/

void ds1621_start_conversion(uint8_t i2c_addr) {
    // Send 0xEE as subaddress with no data
    i2c_write_bytes(i2c_addr, 0x00EE, 1, NULL, 0);
    // uint8_t *wdata = {0xEE};
    // i2c_write(i2c_addr, wdata, 1);
}


int16_t ds1621_read_temperature_raw(uint8_t i2c_addr) {
    uint8_t temp_data[2];

    // Read 2 bytes from temperature register (subaddress 0xAA)
    i2c_read_bytes(i2c_addr, 0xAA, 1, temp_data, 2);

    // Combine bytes into signed 16-bit value (MSB first)
    int16_t raw_temp = (temp_data[0] << 8) | temp_data[1];

    // Return temperature in 0.5°C steps (e.g., 25.5°C -> 51)
    return raw_temp;
}


// Read data from the I2C bus
/*void i2c_read(uint8_t slave_address, uint8_t* data, uint8_t length) {
    uint8_t address = i2c_address_with_rw(slave_address, 1);  // 1 for read

    for (uint8_t i = 0; i < length; i++) {
        i2c_wait_for_module_free();  // Wait until the bus is free

        i2c_register.fields.data = 0;  // Ensure no data is being sent
        i2c_register.fields.slave_address = address;  // Use the address with read bit
        i2c_register.fields.n_bytes = 1;  // 1 byte at a time
        i2c_register.fields.req_data = 1;  // Request data from slave
        i2c_register.fields.start = 1;    // Start condition
        i2c_register.raw = i2c_register.raw;  // Trigger the register write
        
        i2c_wait_for_module_free();  // Wait until the operation completes

        // Read received data from I2C register
        data[i] = i2c_register.fields.data;
    }
}*/

// Function to write then read in a single I2C transaction (repeated start)
/*void i2c_write_then_read(uint8_t slave_address, uint8_t* write_data, uint8_t write_length, uint8_t* read_data, uint8_t read_length) {
    uint8_t write_address = i2c_address_with_rw(slave_address, 0);  // Write address with write bit
    uint8_t read_address = i2c_address_with_rw(slave_address, 1);   // Read address with read bit

    i2c_wait_for_module_free();  // Ensure the bus is free

    // Write data to the slave
    for (uint8_t i = 0; i < write_length; i++) {
        i2c_register->fields.data = write_data[i];
        i2c_register->fields.slave_address = write_address;  // Use write address
        i2c_register->fields.n_bytes = 1;  // 1 byte at a time
        i2c_register->fields.start = 1;   // Start condition
        i2c_register->raw = i2c_register->raw;  // Trigger the register write
        
        i2c_wait_for_module_free();  // Wait until the write operation completes
    }

    // Now perform the read operation (repeated start)
    for (uint8_t i = 0; i < read_length; i++) {
        i2c_register->fields.req_data = 1;  // Request data from slave
        i2c_register->fields.slave_address = read_address;  // Use read address
        i2c_register->fields.start = 1;     // Repeated start
        i2c_register->raw = i2c_register->raw;  // Trigger the register write

        i2c_wait_for_module_free();  // Wait until the read operation completes
        read_data[i] = i2c_register->fields.data;  // Read received data
    }
}*/

// int main() {
//     i2c_init();
//     i2c_set_clock_frequency(100000);  // Example: 100 kHz

//     uint8_t write_data[] = {0x01, 0x02};  // Example data to write
//     uint8_t read_data[2];  // Buffer for read data

//     // Example usage of write then read operation
//     i2c_write_then_read(0x50, write_data, sizeof(write_data), read_data, sizeof(read_data));

//     // Print received data (just for demonstration)
//     printf("Received data: %d, %d\n", read_data[0], read_data[1]);

//     return 0;
// }

#endif // __RISCV__