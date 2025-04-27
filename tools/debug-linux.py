import serial
import struct
import matplotlib.pyplot as plt

print("hello")
# ======== CONFIG ========
#SERIAL_PORT = '/dev/tty.usbserial-A5069RR4'  # <-- Change this to match your system
SERIAL_PORT = '/dev/ttyUSB0'  # <-- Change this to match your system
BAUD_RATE = 115200                      # <-- Match whatever you set in uart_tx
FFT_SIZE = 1024 #65536                         # Full FFT size (input samples)
HALF_FFT_SIZE = 3#FFT_SIZE // 2            # Number of magnitudes per frame
FRAME_START = 0xA5A5A5A5
FRAME_END   = 0x5A5A5A5A
# =========================

def find_frame_start(ser):
    """Wait for FRAME_START marker."""
    while True:
        # Read 4 bytes
        marker_bytes = ser.read(4)
        if len(marker_bytes) != 4:
            continue
        marker = struct.unpack('<I', marker_bytes)[0]  # Little-endian 32-bit unsigned
        if marker == FRAME_START:
            return

def read_floats(ser, count):
    """Read count floats from UART."""
    floats = []
    for _ in range(count):
        bytes_float = ser.read(4)
        if len(bytes_float) != 4:
            raise RuntimeError("Timeout reading float")
        val = struct.unpack('<f', bytes_float)[0]
        floats.append(val)
        print(f"Received float: {val}")
    return floats

def check_frame_end(ser):
    """Verify FRAME_END marker."""
    marker_bytes = ser.read(4)
    if len(marker_bytes) != 4:
        raise RuntimeError("Timeout reading FRAME_END")
    marker = struct.unpack('<I', marker_bytes)[0]
    if marker != FRAME_END:
        raise RuntimeError(f"Frame end marker incorrect: got {hex(marker)}")

def main():
    ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=3)
    print(f"Connected to {SERIAL_PORT} at {BAUD_RATE} baud")

    plt.ion()
    fig, ax = plt.subplots()
    line, = ax.plot([], [])
    ax.set_ylim(0, 100)  # Adjust based on expected magnitude
    ax.set_xlim(0, HALF_FFT_SIZE)

    while True:
        print("Waiting for frame start...")
        find_frame_start(ser)

        print("Reading FFT data...")
        magnitudes = read_floats(ser, HALF_FFT_SIZE)

        check_frame_end(ser)

        # Update plot
        line.set_ydata(magnitudes)
        line.set_xdata(range(len(magnitudes)))
        ax.relim()
        ax.autoscale_view()
        plt.pause(0.01)

if __name__ == "__main__":
    main()
