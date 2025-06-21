// Copyright 2014-2024 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>
#include <xs1.h>
#include "i2s.h"
#include "xk_evk_xu316/board.h"

#define SAMPLE_FREQUENCY        (48000)
#define MASTER_CLOCK_FREQUENCY  (24576000)
#define DATA_BITS               (32)
#define CHANS_PER_FRAME         (2)
#define NUM_I2S_LINES           (1)

// I2S resources
on tile[1]: in port p_mclk =                                PORT_MCLK_IN;
on tile[1]: buffered out port:32 p_lrclk =                  PORT_I2S_LRCLK;
on tile[1]: out port p_bclk =                               PORT_I2S_BCLK;
on tile[1]: buffered out port:32 p_dac[NUM_I2S_LINES] =     {PORT_I2S_DAC_DATA};
on tile[1]: buffered in port:32 p_adc[NUM_I2S_LINES] =      {PORT_I2S_ADC_DATA};
on tile[1]: clock bclk =                                    XS1_CLKBLK_1;

// Board configuration from lib_board_support
static const xk_evk_xu316_config_t hw_config = {
        MASTER_CLOCK_FREQUENCY, // default_mclk
};


[[distributable]]

void i2s_loopback(server i2s_frame_callback_if i2s, chanend c)
{
  int32_t samples[NUM_I2S_LINES * CHANS_PER_FRAME] = {0};

  xk_evk_xu316_AudioHwChanInit(c);
  xk_evk_xu316_AudioHwInit(hw_config);
  xk_evk_xu316_AudioHwConfig(SAMPLE_FREQUENCY, MASTER_CLOCK_FREQUENCY, 0, DATA_BITS, DATA_BITS);

  while (1) {
    select {
      case i2s.init(i2s_config_t &?i2s_config, tdm_config_t &?tdm_config):
        i2s_config.mode = I2S_MODE_I2S;
        i2s_config.mclk_bclk_ratio = (MASTER_CLOCK_FREQUENCY/(SAMPLE_FREQUENCY * CHANS_PER_FRAME * DATA_BITS));

        xk_evk_xu316_AudioHwConfig(SAMPLE_FREQUENCY, MASTER_CLOCK_FREQUENCY, 0, DATA_BITS, DATA_BITS);
        break;

      case i2s.receive(size_t num_chan_in, int32_t sample[num_chan_in]):
        for (size_t i=0; i<num_chan_in; i++) {
          samples[i] = sample[i];
        }
        break;

      case i2s.send(size_t num_chan_out, int32_t sample[num_chan_out]):
        for (size_t i=0; i<num_chan_out; i++){
          sample[i] = samples[i];
        }
        break;

      case i2s.restart_check() -> i2s_restart_t restart:
        restart = I2S_NO_RESTART;
        break;
    }
  }
}

int main(void)
{
  // Channel for communication between tiles for I2C
  chan c;

  par {
    on tile[0]: {
        // Startup a remote I2C master server task
        xk_evk_xu316_AudioHwRemote(c);
    }

    on tile[1]: {
        interface i2s_frame_callback_if i_i2s;

        par {
            // The application - loopback the I2S samples - note callbacks are inlined so does not take a thread
            [[distribute]] i2s_loopback(i_i2s, c);
            i2s_frame_master(i_i2s, p_dac, NUM_I2S_LINES, p_adc, NUM_I2S_LINES, DATA_BITS, p_bclk, p_lrclk, p_mclk, bclk);
        }
    }
  }
  return 0;
}
