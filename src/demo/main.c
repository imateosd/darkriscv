// Ejemplo de utilización de las librerías

#include <io.h>
#include <stdio.h>
#include <stdint.h>
#include <spi.h>
#include <i2c.h>
#include <gpio.h>
#include <utils.h>

int main(void)
{
#ifndef SMALL
#endif

  
    io->led = 0xaaaa;
    io->gpio_function = 0x0001; // Set first pin as PWM
    io->pwm_control = 0x000000FF; // Set PWM duty cycle to 100% for the first PWM module
    io->gpio_ctrl = 0x00FF; // Set all pins as outputs
    io->gpio = 0x00F0; // Set pins 4-7 high and the rest low

    io->display_control = 0x93848586;

    uint8_t pwm_value = 0;
    while(1)
    {        
        uint8_t sw_state = io->switches;
        io->led ^= sw_state; // Alternar el estado de los estado de los LEDs sólo si el switch correspondiente está activado
        printf("Hola, mundo!!\n");

        // I2C
        // Lectura de temperatura del sensor DS1621
        #define DS1621_ADDRESS  0x49
        ds1621_start_conversion(DS1621_ADDRESS);
        wait(100000);
        wait(100000);
        int raw = ds1621_read_temperature_raw(DS1621_ADDRESS);
        int temp_x10 = (int) ( (raw * 10) / 256 );
        printf("Temperatura: %d.%d°C \n\r\n", temp_x10 / 10, temp_x10 % 10);


        // SPI
        // Lectura de datos por SPI de MCP3008
        uint8_t spi_tx_data[3] = { 0x01, 0x80, 0x00};
        uint8_t spi_rx_data[3];
        spi_write_read_multiple_bytes(spi_tx_data, spi_rx_data, 3, 1);
        printf("Recibido por SPI 0x%x, 0x%x\n\n", spi_rx_data[1], spi_rx_data[2]);

        // Usar el valor leído del ADC para controlar el PWM. Como el ADC devuelve 10 bits, necesitamos mapear el resultado a los 8 bits del PWM
        uint16_t adc_value = ((spi_rx_data[1] & 0x03) << 8) | spi_rx_data[2];
        printf("El valor del ADC es %x \n\r\n", adc_value);
        uint8_t mapped_value = adc_value >> 2;
        // Mostrar el valor leído por ADC en el display de 7 segmentos
        // update_display(mapped_value);
        // Cambiar el brillo del LED en función del valor leído por ADC
        // io->pwm_control = mapped_value;

        // Mostrar cuatro dígitos en los display de 7 segmentos, 
        update_individual_display(3, 10, false, true);
        update_individual_display(2, 11, false, true);
        update_individual_display(1, 12, false, true);
        update_individual_display(0, 13, true, true);
        
        // 'breathe' LED con PWM
        io->pwm_control = pwm_value;
        pwm_value+= 5;

        // GPIO
        // Encender un LED a través de GPIO siguiendo el estado de una entrada
        // Configurar como salida el pin de entrada
        gpio_direction(3, false);
        _Bool state = gpio_get(3); // Leer el estado del pin de entrada
        // Configurar como salida el LED
        gpio_direction(1, true);
        // Configurar el estado
        gpio_set(1, state);

        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
        wait(100000);
    }
}