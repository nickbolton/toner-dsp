import struct
import serial
import matplotlib.pyplot as plt
import numpy as np

# === Serial Config ===
PORT = "/dev/tty.usbserial-BG01053R"
BAUD = 115200
FRAME_START = 0xA5A5A5A5
FLOAT_SIZE = 4

def wait_for_frame_header(ser):
    while True:
        # Read 4 bytes
        marker_bytes = ser.read(4)
        if len(marker_bytes) != 4:
            continue
        marker = struct.unpack('<I', marker_bytes)[0]  # Little-endian 32-bit unsigned
        if marker == FRAME_START:
            return

def read_frame(ser):

    # Read 4-byte little-endian uint32 count
    count_bytes = ser.read(4)
    if len(count_bytes) != 4:
        raise ValueError("Failed to read float count")
    num_floats = struct.unpack('<I', count_bytes)[0]

    print(f"Reading {num_floats} float samples...")

    # Read the data
    data_bytes = ser.read(num_floats * FLOAT_SIZE)
    if len(data_bytes) != num_floats * FLOAT_SIZE:
        raise ValueError("Incomplete data frame")

    # Convert bytes to list of floats
    floats = list(struct.unpack('<' + 'f' * num_floats, data_bytes))
    return floats

def plot_time_and_fft(samples, sample_rate=48000):
    time_axis = np.arange(len(samples)) / sample_rate
    fft_mags = np.abs(np.fft.rfft(samples * np.hamming(len(samples))))
    fft_freqs = np.fft.rfftfreq(len(samples), 1/sample_rate)

    # Plot time-domain
    plt.figure(figsize=(12, 6))
    plt.subplot(2, 1, 1)
    plt.plot(time_axis, samples)
    plt.title("Time-Domain Signal")
    plt.xlabel("Time (s)")
    plt.ylabel("Amplitude")
    plt.grid(True)

    # Plot FFT
    plt.subplot(2, 1, 2)
    plt.semilogx(fft_freqs, 20 * np.log10(fft_mags + 1e-9))  # dB scale
    plt.title("FFT Magnitude")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude (dB)")
    plt.grid(True)
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    with serial.Serial(PORT, BAUD, timeout=3) as ser:
        print("Waiting for frame header...")
        wait_for_frame_header(ser)
        samples = read_frame(ser)
        plot_time_and_fft(samples)

