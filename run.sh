#!/bin/bash

BUILD_DIR=build
TARGET_XE=bin/main.xe

function build() {
  cmake -B ${BUILD_DIR} -DCMAKE_EXPORT_COMPILE_COMMANDS=1
  cmake --build ${BUILD_DIR} --target main
}

function flash() {
  if [ ! -f ${TARGET_XE} ]; then
    echo "Binary not found. Building first..."
    build
  fi
  xflash ${TARGET_XE}
}

function run() {
  if [ ! -f ${TARGET_XE} ]; then
    echo "Binary not found. Building first..."
    build
  fi
  xrun ${TARGET_XE}
}

function monitor() {
  xrun --xscope ${TARGET_XE}
}

function build_flash_monitor() {
  build && flash && monitor
}

function build_flash_run() {
  build && flash && run
}

function sim() {
  xsim --xscope "-offline -" ${TARGET_XE}
}

function clean() {
  rm -rf ${BUILD_DIR}
  echo "Build directory cleaned."
}

function watch() {
  echo "Watching for changes in src/, include/, config/, and CMakeLists.txt..."
  if ! command -v fswatch &> /dev/null; then
    echo "fswatch could not be found. Install it with: brew install fswatch"
    exit 1
  fi

  fswatch -o src include config CMakeLists.txt | while read; do
    echo "Change detected. Rebuilding..."
    build
  done
}

case "$1" in
  build)
    build
    ;;
  flash)
    flash
    ;;
  run)
    build_flash_run
    ;;
  monitor)
    build_flash_monitor
    ;;
  sim)
    sim
    ;;
  clean)
    clean
    ;;
  watch)
    watch
    ;;
  *)
    echo "Usage: $0 {build|flash|run|monitor|clean|watch}"
    ;;
esac
