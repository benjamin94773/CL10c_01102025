#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# 1) Create several files with random numbers (100 numbers between 1 and 1000 per file)
#    Files: data1.txt ... data5.txt
seq 5 | parallel "shuf -i 1-1000 -n 100 > data{}.txt"

# 2) Calculate the sum for each file
#    Output format: dataX.txt: <sum>
parallel "awk '{s+=\$1} END {print \"{}: \" s}' {}" ::: data*.txt | sort -V | tee sums.txt

echo "Generated $(ls -1 data*.txt | wc -l) files. Sums saved to sums.txt"