import serial
import struct

SERIAL_PORT = '/dev/ttyUSB0'  # This is the Ubuntu device
BAUD_RATE = 115200            # Match your XMOS baud rate

def main():
    ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
    print(f"Opened {SERIAL_PORT} at {BAUD_RATE} baud.")

    while True:
        data = ser.read(4)  # Read 4 bytes (like a float, or a uint32 marker)
        if data:
            value = struct.unpack('<f', data)[0]
            print(f"Received bytes: {value}")
            #print(f"Received bytes: {data.hex()}")

if __name__ == "__main__":
    main()

