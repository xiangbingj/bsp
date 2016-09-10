#!/bin/sh
# post-image.sh

# Copy uEnv.txt to the images directory
cp board/beaglebone/uEnv.txt "${BINARIES_DIR}/uEnv.txt"
