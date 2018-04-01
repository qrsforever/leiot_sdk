#!/bin/bash

# toolchains or ndk path for android
# export PATH=/opt/ndk:$PATH

# debug: ON / OFF (default: OFF)
export ENABLE_DEBUG=ON

# os platform: android/ubuntu/FreeRTOS (default: ubuntu)
export OS_PLATFORM=ubuntu

# loal cloud for debug
# ali, tencent, local
export CLOUD_SERVER="tencent"

# export LOCAL_CLOUD_HOST=10.58.51.144
# export LOCAL_CLOUD_PORT=1883

# Build:
#   0. source env.sh
#   1. mkdir output
#   2. cd output
#   3. cmake ..
#   4. make
