#include <xs1.h>
#include <xclib.h>
#include <math.h>
#include <stdio.h>
#include <xmath/xmath.h>
#include <stdlib.h>
#include <xscope.h>
#include <print.h>
#include <uart.h>
#include <platform.h>

#define SAMPLE_RATE 48000
#define FFT_SIZE 65536
//#define FFT_SIZE 1024
#define UART_ACTIVE_HIGH 1
#define START_FRAME_MARKER 47.0f
#define END_FRAME_MARKER 51.0f

extern void blinkLed();

char polarity_map[1] = { UART_ACTIVE_HIGH };

void generate_signal(chanend c_out) {
  timer tmr;
  unsigned time;
  tmr :> time;
  unsigned period = 48000 / SAMPLE_RATE; // 48000 MHz clock

  while (1) {
    for (int i = 0; i < FFT_SIZE; ++i) {
      float sample = sinf(2 * M_PI * 1000.0f * i / SAMPLE_RATE); // 1kHz sine
      c_out <: sample;
      time += period;
      tmr when timerafter(time) :> void;
    }
  }
}

void fft_capture(chanend c_in, chanend c_out) {
  float input[FFT_SIZE];
  int i = 0;
 
  while (1) {
    select {
      case c_in :> input[i]:
        i++;
        if (i == FFT_SIZE) {
          c_out <: START_FRAME_MARKER;
          complex_float_t *result = (complex_float_t *)fft_f32_forward(input, FFT_SIZE);
          for (int j = 0; j < FFT_SIZE / 2; ++j) {
            float mag = sqrtf(result[j].re * result[j].re + result[j].im * result[j].im);
            c_out <: mag; // Push each magnitude as a float
          }
          c_out <: END_FRAME_MARKER;
          i = 0;
        }
        break;
    }
  }
}

void write(uint32_t value, client uart_tx_if tx_if) {
  uint8_t *ptr = (uint8_t *)&value;
  for (size_t i = 0; i < sizeof(uint32_t); i++) {
    tx_if.write(ptr[i]);
  }
}

void fft_transmit(chanend c_in, client uart_tx_if tx_if) {
  const uint32_t FRAME_START = 0xA5A5A5A5;
  const uint32_t FRAME_END   = 0x5A5A5A5A;

  uint32_t frameSize = FFT_SIZE;
  float mag;
  uint8_t *bytes = (uint8_t *)&mag;

  while (1) {
    // Receive one magnitude value
    c_in :> mag;

    if (mag == START_FRAME_MARKER || mag == END_FRAME_MARKER) {
      uint32_t value = mag == START_FRAME_MARKER ? FRAME_START : FRAME_END;
      write(value, tx_if);
      if (mag == START_FRAME_MARKER) {
        write(frameSize, tx_if);
      }
    } else {
      // Send 4 bytes (float) over UART
      for (int i = 0; i < sizeof(float); i++) {
        tx_if.write(bytes[i]);
      }
    }
  }
}

void uart_tx_task(server uart_tx_if tx, client output_gpio_if gpio) {
  uart_tx(tx, null, 115200, UART_PARITY_NONE, 8, 1, gpio);
}

void uart_to_pin(server output_gpio_if gpio_if, out port p) {
  while (1) {
    select {
      case gpio_if.output(unsigned value):
        // printf("sending value to pin: %u…\n", value & 0x1);
        p <: (value & 0x1); // Mask to 0 or 1 before output
        break;
      case gpio_if.output_and_timestamp(unsigned data) -> gpio_time_t ts:
        break;
    }
  }
}

on tile[0]: out port p_uart_tx = XS1_PORT_1A;

int main() {
  chan capture;
  chan transmit;
  interface uart_tx_if tx_if;
  interface output_gpio_if tx_gpio[1];

  par {
    // incoming signal
    on tile[1]: generate_signal(capture);

    // fft processing
    on tile[0]: fft_capture(capture, transmit);
    on tile[0]: fft_transmit(transmit, tx_if);

    // uart
    on tile[0]: uart_to_pin(tx_gpio[0], p_uart_tx); // Direct pin driver
    on tile[1]: uart_tx_task(tx_if, tx_gpio[0]);

    // utils
    on tile[0]: blinkLed();
  }

  return 0;
}

