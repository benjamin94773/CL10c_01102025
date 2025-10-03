#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# 1) Create 20 files with random numbers (200 numbers each)
seq 20 | parallel "shuf -i 1-1000 -n 200 > data{}.txt"

# Helper: serial summation function
serial_sum() {
  for f in data*.txt; do
    awk '{s+=$1} END {print FILENAME ": " s}' "$f"
  done | sort -V
}

# 2a) Serial sums with timing
{
  time serial_sum
} 2> serial_time_20.txt | tee serial_sums_20.txt

# 2b) Parallel sums with timing
{
  time parallel "awk '{s+=\$1} END {print \"{}: \" s}' {}" ::: data*.txt | sort -V
} 2> parallel_time_20.txt | tee parallel_sums_20.txt

# Print a short summary of wall clock times
SERIAL_REAL=$(grep -m1 '^real' serial_time_20.txt | awk '{print $2}')
PAR_REAL=$(grep -m1 '^real' parallel_time_20.txt | awk '{print $2}')
echo "Serial real:   ${SERIAL_REAL}"
echo "Parallel real: ${PAR_REAL}"
