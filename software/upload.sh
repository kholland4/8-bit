#!/bin/bash
python3 assembler.py "$1" > 8-bit_prgm/data.h
cd 8-bit_prgm
~/arduino-1.8.5/arduino --upload --board arduino:avr:mega --port /dev/ttyACM0 8-bit_prgm.ino
