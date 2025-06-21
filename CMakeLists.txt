cmake_minimum_required(VERSION 3.21)

# Include XCommon CMake
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)

# Project setup
project(TonerDSP)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Set the sandbox directory (parent of sw_xu316_passthrough)
set(XMOS_SANDBOX_DIR ${CMAKE_CURRENT_LIST_DIR}/lib)

# Set the target hardware
set(APP_HW_TARGET XK-EVK-XU316)

# Compiler flags
set(APP_COMPILER_FLAGS
  -O2
  -g
  -report
  -DBOARD_SUPPORT_BOARD=XK_EVK_XU316
  -Wall
  -Wno-timing
)

set(APP_PCA_ENABLE
  ON
)

# Source files
set(APP_SOURCES
  src/main.xc
)

# Include directories (if needed)
set(APP_INCLUDES
  src
  ${XMOS_SANDBOX_DIR}/lib_i2s/lib_i2s/api
  ${XMOS_SANDBOX_DIR}/lib_i2c/lib_i2c/api
  ${XMOS_SANDBOX_DIR}/lib_board_support/lib_board_support/api
)

# Required libraries for I2S audio
set(APP_DEPENDENT_MODULES
  lib_i2s
  lib_i2c
  lib_xcore_math
  lib_gpio
  lib_logging
  lib_uart
  lib_xassert
  lib_board_support
)

# Create the application
XMOS_REGISTER_APP()
