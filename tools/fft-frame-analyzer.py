import serial
import struct
import numpy as np
import matplotlib.pyplot as plt

# === CONFIG ===
PORT = '/dev/tty.usbserial-BG01053R'  # Replace this with your actual serial port
BAUD = 115200
TIMEOUT = 2.0  # seconds
FFT_SIZE = 1024
SAMPLE_RATE = 48000
BIN_WIDTH = SAMPLE_RATE / FFT_SIZE  # 11.71875 Hz
FRAME_START = 0xA5A5A5A5
#MAX_BINS = 1749

# === OPEN SERIAL PORT ===
ser = serial.Serial(PORT, BAUD, timeout=TIMEOUT)

def smooth(y, box_pts):
    box = np.ones(box_pts)/box_pts
    y_smooth = np.convolve(y, box, mode='same')
    return y_smooth

def find_frame_start():
    """Wait for FRAME_START marker."""
    while True:
        # Read 4 bytes
        marker_bytes = ser.read(4)
        if len(marker_bytes) != 4:
            continue
        marker = struct.unpack('<I', marker_bytes)[0]  # Little-endian 32-bit unsigned
        if marker == FRAME_START:
            return

def read_uint32():
    """Read a 4-byte unsigned int (little-endian)."""
    raw = ser.read(4)
    if len(raw) != 4:
        raise RuntimeError("Failed to read 4-byte bin count.")
    return struct.unpack('<I', raw)[0]

def read_float32_array(count):
    """Read an array of `count` float32 values."""
    data = ser.read(4 * count)
    if len(data) != 4 * count:
        raise RuntimeError(f"Incomplete data frame: expected {count} floats, got {len(data) // 4}")
    return [struct.unpack('<f', data[i*4:i*4+4])[0] for i in range(count)]

# === MAIN ===
try:
    find_frame_start()
    bin_count = read_uint32()
    FFT_SIZE = bin_count * 2
    BIN_WIDTH = SAMPLE_RATE / FFT_SIZE  # 11.71875 Hz

    print(f"Reading {bin_count} bins...")
    
    bins = read_float32_array(bin_count)

    # Plot result
    #freqs = np.linspace(0, 24000, bin_count)  # Adjust for your sample rate
    freqs = np.arange(bin_count) * BIN_WIDTH
    smoothed_magnitude = smooth(bins, 10)

    print("Plotting...")

    plt.xscale('log')
    plt.xlim(20, 20000)  # Optional: set freq range (match your signal)
    plt.xticks([20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000], 
               ['20', '50', '100', '200', '500', '1k', '2k', '5k', '10k', '20k'])

    plt.plot(freqs, smoothed_magnitude)
    plt.title("Bode Plot")
    plt.axvline()
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("dB")
    plt.grid(True)
    plt.show()

except Exception as e:
    print(f"Error: {e}")
finally:
    ser.close()

