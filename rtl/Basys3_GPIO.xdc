###########################################################
##  MSEEI 2023-2024
##  Basys3 General Purpose I/O
###########################################################

## Irene Mateos Dom?nguez
## DNI: 48259794K

## 	Switches

# GPIO as inputs?
#set_property PACKAGE_PIN V17 [get_ports {TMP_INT}]
#set_property IOSTANDARD LVCMOS33 [get_ports {TMP_INT}]
#set_property PACKAGE_PIN V16 [get_ports {GPIO[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[1]}]
#set_property PACKAGE_PIN W16 [get_ports {GPIO[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[2]}]
#set_property PACKAGE_PIN W17 [get_ports {GPIO[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[3]}]
#set_property PACKAGE_PIN W15 [get_ports {GPIO[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[4]}]
#set_property PACKAGE_PIN V15 [get_ports {GPIO[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[5]}]
#set_property PACKAGE_PIN W14 [get_ports {GPIO[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[6]}]
#set_property PACKAGE_PIN W13 [get_ports {GPIO[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[7]}]

#set_property PACKAGE_PIN V17 [get_ports {SW[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SW[0]}]
#set_property PACKAGE_PIN V16 [get_ports {SW[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SW[1]}]
#set_property PACKAGE_PIN W16 [get_ports {SW[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SW[2]}]
#set_property PACKAGE_PIN W17 [get_ports {SW[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SW[3]}]
#set_property PACKAGE_PIN W15 [get_ports {SW[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SW[4]}]
#set_property PACKAGE_PIN V15 [get_ports {SW[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SW[5]}]
#set_property PACKAGE_PIN W14 [get_ports {SW[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SW[6]}]
#set_property PACKAGE_PIN W13 [get_ports {SW[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SW[7]}]


## 	LEDs

set_property PACKAGE_PIN U16 [get_ports {LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
set_property PACKAGE_PIN E19 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
set_property PACKAGE_PIN U19 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
set_property PACKAGE_PIN V19 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]

#GPIO used for the on board LEDs (GPIO as outputs)
#set_property PACKAGE_PIN W18 [get_ports {GPIO[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[0]}]
#set_property PACKAGE_PIN U15 [get_ports {GPIO[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[1]}]
#set_property PACKAGE_PIN U14 [get_ports {GPIO[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[2]}]
#set_property PACKAGE_PIN V14 [get_ports {GPIO[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[3]}]
#set_property PACKAGE_PIN V13 [get_ports {GPIO[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[4]}]
#set_property PACKAGE_PIN V3 [get_ports {GPIO[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[5]}]
#set_property PACKAGE_PIN W3 [get_ports {GPIO[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[6]}]
#set_property PACKAGE_PIN U3 [get_ports {GPIO[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[7]}]

## LED[12]
set_property PACKAGE_PIN P3 [get_ports {DEBUG[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DEBUG[0]}]
## LED[13]
set_property PACKAGE_PIN N3 [get_ports {DEBUG[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DEBUG[1]}]
## LED[14]
set_property PACKAGE_PIN P1 [get_ports {DEBUG[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DEBUG[2]}]
## LED[15]
set_property PACKAGE_PIN L1 [get_ports {DEBUG[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DEBUG[3]}]


##7	segment display



###########################################################
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
###########################################################

# Pulsadores

# BTN[0]=BTNC; BTN[1]=BTNU; BTN[2]=BTNR; BTN[3]=BTND; BTN[4]=BTNL;
# Mapeado de los pulsadores a las se?ales correctas
set_property PACKAGE_PIN U18 [get_ports XRES]
# Definici?n del est?ndar de las entradas conectadas a los pulsadores
set_property IOSTANDARD LVCMOS33 [get_ports XRES]

# Configuraci?n de la corriente de salida en el puerto que alimenta el led 7.

# Configuraci?n del reloj que viene en la placa Basys3 (100MHz)
set_property IOSTANDARD LVCMOS33 [get_ports XCLK]
set_property PACKAGE_PIN W5 [get_ports XCLK]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports XCLK]

# UART
set_property PACKAGE_PIN B18 [get_ports UART_RXD]
set_property PACKAGE_PIN A18 [get_ports UART_TXD]
set_property IOSTANDARD LVCMOS33 [get_ports UART_RXD]
set_property IOSTANDARD LVCMOS33 [get_ports UART_TXD]

#I2C
set_property PACKAGE_PIN A17 [get_ports I2C_SCL]
set_property PACKAGE_PIN A15 [get_ports I2C_SDA]
set_property IOSTANDARD LVCMOS33 [get_ports I2C_SCL]
set_property IOSTANDARD LVCMOS33 [get_ports I2C_SDA]

#SPI
set_property PACKAGE_PIN A14 [get_ports SPI_CLK]
set_property PACKAGE_PIN A16 [get_ports SPI_MISO]
set_property PACKAGE_PIN B15 [get_ports SPI_MOSI]
set_property PACKAGE_PIN B16 [get_ports SPI_CS]
set_property IOSTANDARD LVCMOS33 [get_ports SPI_CLK]
set_property IOSTANDARD LVCMOS33 [get_ports SPI_MISO]
set_property IOSTANDARD LVCMOS33 [get_ports SPI_MOSI]
set_property IOSTANDARD LVCMOS33 [get_ports SPI_CS]

# GPIO on JA
set_property PACKAGE_PIN J1 [get_ports {GPIO[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[0]}]
set_property PACKAGE_PIN L2 [get_ports {GPIO[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[1]}]
set_property PACKAGE_PIN J2 [get_ports {GPIO[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[2]}]
set_property PACKAGE_PIN G2 [get_ports {GPIO[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[3]}]
set_property PACKAGE_PIN H1 [get_ports {GPIO[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[4]}]
set_property PACKAGE_PIN K2 [get_ports {GPIO[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[5]}]
set_property PACKAGE_PIN H2 [get_ports {GPIO[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[6]}]
set_property PACKAGE_PIN G3 [get_ports {GPIO[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO[7]}]

set_property DRIVE 4 [get_ports I2C_SDA]
set_property DRIVE 4 [get_ports I2C_SCL]
set_property OFFCHIP_TERM NONE [get_ports SPI_CLK]
set_property OFFCHIP_TERM NONE [get_ports SPI_CS]
set_property OFFCHIP_TERM NONE [get_ports SPI_MOSI]
set_property PULLUP true [get_ports SPI_CS]
set_property SLEW FAST [get_ports SPI_CLK]
set_property SLEW FAST [get_ports SPI_MOSI]
