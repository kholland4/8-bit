#!/bin/bash
python3 assembler.py "$1" > 8-bit_prgm/data.h
python3 "sim v5.py" 8-bit_prgm/data.h
