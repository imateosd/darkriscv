import serial
import sys
from tqdm import tqdm


def send_binary_file_via_uart(port, baudrate, filename):
    with open(filename, 'rb') as f:
        data = f.read()
    
    filesize = len(data)
    if filesize > 65535:
        print("File too large (max 65535 bytes supported).")
        return
    
    size_bytes = filesize.to_bytes(2, byteorder='big')

    with serial.Serial(port, baudrate, timeout=1) as ser:
        ser.write(size_bytes)
        print(f"Sent file size: {filesize} bytes")

        idx = 0
        print("Waiting for '.' to send each byte...")

        while idx < filesize:
            incoming = ser.read(size=1)
            if not incoming:
                continue
            
            if incoming == b'.':
                ser.write(data[idx:idx+1])
                print(f"Sent byte {idx+1}/{filesize}: {data[idx]}")
                idx += 1

        print("File transmission complete.")

def send_binary_file_via_uart_with_progressbar(port, baudrate, filename):
    with open(filename, 'rb') as f:
        data = f.read()
    
    filesize = len(data)
    if filesize > 65535:
        print("File too large (max 65535 bytes supported).")
        return
    
    size_bytes = filesize.to_bytes(2, byteorder='big')

    with serial.Serial(port, baudrate, timeout=1) as ser:
        ser.write(size_bytes)
        print(f"Sent file size: {filesize} bytes")

        idx = 0
        print("Waiting for '.' to send each byte...")

        with tqdm(total=filesize, unit="B", unit_scale=True, desc="Sending") as pbar:
            while idx < filesize:
                incoming = ser.read(size=1)
                if not incoming:
                    continue

                if incoming == b'.':
                    ser.write(data[idx:idx+1])
                    idx += 1
                    pbar.update(1)

        print("File transmission complete.")

if __name__ == "__main__":
    # Default values
    serial_port = "COM4"
    baudrate = 115200
    binary_file = "src/darksocv_uart.bin"

    # Override defaults if arguments provided
    if len(sys.argv) > 1:
        serial_port = sys.argv[1]
    if len(sys.argv) > 2:
        baudrate = int(sys.argv[2])
    if len(sys.argv) > 3:
        binary_file = sys.argv[3]

    print(f"Using serial port: {serial_port}")
    print(f"Using baudrate: {baudrate}")
    print(f"Using binary file: {binary_file}")

    # send_binary_file_via_uart_with_progressbar(serial_port, baudrate, binary_file)
    send_binary_file_via_uart(serial_port, baudrate, binary_file)
