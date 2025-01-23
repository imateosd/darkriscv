import serial, time

# Open the serial port
ser = serial.Serial('COM6', 115200)  # Update with your serial port and baud rate

# Load the binary data
with open('src/darksocv_uart.bin', 'rb') as f:
    data = f.read()

# Reboot CPU
print("Rebooting CPU...")
ser.write(bytes('reboot\n'.encode()))

time.sleep(1)

print("Rebooted.... Sending new firmware...")

# Send the data
ser.write(data)

print("Successfully sent new firmware.")

# Optionally, close the port
ser.close()