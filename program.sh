#!/bin/bash

BUILD_DIR=${BUILD_DIR:=build}

nrfutil device program --firmware $BUILD_DIR/zephyr/zephyr.hex
nrfutil device fw-verify --firmware $BUILD_DIR/zephyr/zephyr.hex
nrfutil device reset
