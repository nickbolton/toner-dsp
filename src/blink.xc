#include <platform.h>
#include <syscall.h>
#include <print.h>
#include <stdint.h>

port out p_leds = PORT_LEDS;

void blinkLed() {

  uint32_t led = 0;
  uint32_t last;
  asm("gettime %0" : "=r"(last));

  while (1) {
    uint32_t now;
    asm("gettime %0" : "=r"(now));

    if (now - last > 100000000) {
      led ^= 0xf;
      p_leds <: led;
      last = now;
    }
  }
}
