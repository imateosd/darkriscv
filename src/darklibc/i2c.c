#include <io.h>

#ifdef __RISCV__

#include <i2c.h>
#include <io.h>
#include <stdio.h>
#include <stdarg.h>


// i2c => relleno de 0s (20 bits) | busy (1 bit) | req_data (1 bit) | nack (1 bit) | valid_out (1 bit) | data_out (8 bit)							


void i2cSendByte(char slaveAddress, char subaddress, char byteToSend)
{
    printf("Starting i2cSendByte\n");

    if ( !( io->i2c & ( 1 << 11) ) )
    {   // I2C module is not busy

        // Command to start the transaction. 
        // Structure: 
        // 1 bit |          3 bits                |    8 bits    |   8 bits   |       8 bits
        // Start | Number of bytes in transaction | slaveAddress | subaddress | data (to send if write)
        io->i2c = (0x01 << 27) + (0x02<<24) + (slaveAddress<<16) + (subaddress<<8) + byteToSend;

        // Check if there's an acknowledgment
        int iterations = 0;
        while ( !( io->i2c&(1<<29) ) && (iterations < 20000) )
        {
            iterations++;
        }
        if (iterations < 20000) // The not ack flag was set
        {
            printf("No ACK received\n");
            return -1;
        }
    }
    else
    {
        printf("i2c is busy!");
    }
}

char i2cReadByte(char slaveAddress, char subaddress)
{
    printf("Starting i2cReadByte\n");
    printf("i2c = %x\n", io->i2c);
    if ( !( io->i2c & ( 1 << 11) ) )
    {   // I2C module is not busy
        
        // Command to start the transaction. 
        // Structure: 
        // 1 bit |          3 bits                |    8 bits    |   8 bits   |       8 bits
        // Start | Number of bytes in transaction | slaveAddress | subaddress | data (to send if write)
        io->i2c = (0x01 << 27) + (0x01<<24) + (slaveAddress<<16) + (subaddress<<8) + (0x00000000);

        // Check if there's an acknowledgment // !!! there shouldn't be ack from the slave after they send their data!!!
        int iterations = 0;
        while ( !( io->i2c&(1<<29) ) && (iterations < 20000) )
        {
            iterations++;
        }
        if (iterations < 20000) // The not ack flag was set
        {
            printf("No ACK received\n");
            return -1;
        }

        // Now we wait until the data to be read has been received
        iterations = 0;
        while (!( io->i2c&(1<<8) ) && (iterations < 200000) )
        {
            iterations++;
        }
        if (iterations < 2000000) // The valid_data flag was set
        {
                
            printf("Valid data in the buffer\n");
            // clear valid_out flag
            io->i2c = (1 << 28);
            printf("i2c = %x\n", io->i2c);
            char data = (char) (io->i2c);
            printf("the data read from %x at %x is %x\n", slaveAddress, subaddress, data);
            return data;
        }
        else
            printf("No valid data received\n");
        return -1;
    }
    else
    {
        printf("i2c is busy!");
        return -1;
    }
}

#endif