#include <platform.h>
#include <syscall.h>
#include <print.h>

port out p_leds = PORT_LEDS;

int main() {
    printstrln("Hello World!");

    if (!_is_simulation()) {
        // If running on hardware, flash the LEDs
        while (1) {
            p_leds <: 0x0;
            delay_milliseconds(250);
            p_leds <: 0xf;
            delay_milliseconds(250);
        }
    }

    return 0;
}
