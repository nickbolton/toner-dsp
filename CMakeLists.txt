cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)

# Name your project
project(main C CXX)

set(APP_HW_TARGET XK-EVK-XU316)

# ✅ This is the only xscope config needed
set(XSCOPE_IO XSCOPE_IO_BASIC)

##################### lib_xcore_math ##########################
# Glob everything in lib_xcore_math/src/
file(GLOB_RECURSE XMATH_SRC CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/xcore_math/lib_xcore_math/src/scalar/*.[cS]
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/xcore_math/lib_xcore_math/src/fft/*.[cS]
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/xcore_math/lib_xcore_math/src/arch/xs3/*.[cS]
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/xcore_math/lib_xcore_math/src/arch/ref/*.[cS]
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/xcore_math/lib_xcore_math/src/vect/*.[cS]
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/xcore_math/lib_xcore_math/src/etc/*.[cS]
)
add_library(xcore_math STATIC ${XMATH_SRC})
target_compile_definitions(xcore_math PRIVATE __XS3A__)
target_compile_options(xcore_math PRIVATE -target=XK-EVK-XU316 -mcmodel=large)

target_include_directories(xcore_math PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/xcore_math/lib_xcore_math/api
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/xcore_math/lib_xcore_math/src/vect
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/xcore_math/lib_xcore_math/src/etc/xmath_fft_lut
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/xcore_math/lib_xcore_math/src/arch/xs3
)

##################### lib_logging ##########################
# Glob everything in lib_logging/src/
file(GLOB_RECURSE LOGGING_SRC CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_logging/lib_logging/src/*.c
)
add_library(lib_logging STATIC ${LOGGING_SRC})
target_compile_options(lib_logging PRIVATE -target=XK-EVK-XU316 -mcmodel=large)

target_include_directories(lib_logging PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_logging/lib_logging/api
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_logging/lib_logging/src
)

##################### lib_xassert ##########################
# Glob everything in lib_xassert/src/
file(GLOB_RECURSE XASSERT_SRC CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_xassert/lib_xassert/src/*.xc
)
add_library(lib_xassert STATIC ${XASSERT_SRC})
target_compile_options(lib_xassert PRIVATE -target=XK-EVK-XU316 -mcmodel=large)

target_include_directories(lib_xassert PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_xassert/lib_xassert/api
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_xassert/lib_xassert/src
)

##################### lib_gpio ##########################
# Glob everything in lib_gpio/src/
file(GLOB_RECURSE GPIO_SRC CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_gpio/lib_gpio/src/*.xc
)
add_library(lib_gpio STATIC ${GPIO_SRC})
target_compile_options(lib_gpio PRIVATE -target=XK-EVK-XU316 -mcmodel=large)

target_include_directories(lib_gpio PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_xassert/lib_xassert/api
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_gpio/lib_gpio/api
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_gpio/lib_gpio/src
)

##################### lib_uart ##########################
# Glob everything in lib_uart/src/
file(GLOB_RECURSE UART_SRC CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_uart/lib_uart/src/*.xc
)
add_library(lib_uart STATIC ${UART_SRC})
target_compile_options(lib_uart PRIVATE -target=XK-EVK-XU316 -mcmodel=large)

target_include_directories(lib_uart PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_logging/lib_logging/api
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_xassert/lib_xassert/api
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_gpio/lib_gpio/api
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_uart/lib_uart/api
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_uart/lib_uart/src
)

# Glob everything in src/
file(GLOB_RECURSE SRC_FILES CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/src/*
)

add_definitions(-DUART_TX_VALUE=0 -DUART_RX_VALUE=0)

# Register app
XMOS_REGISTER_APP(main
  SRCS
    ${SRC_FILES}
    ${XMATH_SRC}
    ${UART_SRC}
  INCLUDES
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/xcore_math/lib_xcore_math/api
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_logging/lib_logging/api
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_xassert/lib_xassert/api
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_gpio/lib_gpio/api
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_uart/lib_uart/api
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_uart/lib_uart/src
)

target_include_directories(main PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/xcore_math/lib_xcore_math/api
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_logging/lib_logging/api
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_xassert/lib_xassert/api
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_gpio/lib_gpio/api
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_uart/lib_uart/api
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib_uart/lib_uart/src
)

target_compile_options(main PRIVATE -mcmodel=large)

target_link_options(main PRIVATE -mcmodel=large -fxscope)
target_link_libraries(main PUBLIC xscope xcore_math lib_logging lib_xassert lib_gpio lib_uart)

