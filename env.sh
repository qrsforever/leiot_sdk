#!/bin/bash

# toolchains
# export PATH=/opt/ndk/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH
# export CROSS_PREFIX=arm-linux-androideabi-

# debug: ON / OFF (default: OFF)
export ENABLE_DEBUG=ON

# os platform: Android/Linux/FreeRTOS (default: Linux)
export OS_PLATFORM=Linux

# device type: Gateway/Subdev/MiniControl (default: Subdev)
export DEVICE_TYPE=Gateway

# build libraries type: ON/OFF (default: ON)
export ENABLE_STATIC=ON

# Build:
#   1. mkdir output
#   2. cd output
#   3. cmake ..
#   4. make
