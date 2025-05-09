#!/bin/bash

BUILD_DIR=${BUILD_DIR:=build}

if [ ! -d $BUILD_DIR ]; then
    cmake -B $BUILD_DIR -G Ninja -DBOARD=adafruit_feather_nrf52840 -DUSE_CCACHE=0 .
fi
cmake --build $BUILD_DIR
