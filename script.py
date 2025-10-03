#!/usr/bin/env python3
"""
Process a CSV file and compute average and median of a chosen column (value1/value2/value3).

Usage (Windows PowerShell):
  python script.py data1.csv --column value2

Outputs a single result line to stdout with: file, column, count, mean, median, seconds
"""
from __future__ import annotations
import argparse
import csv
import statistics
import time
from typing import List


def read_column(path: str, column: str) -> List[float]:
    values: List[float] = []
    with open(path, newline="") as f:
        r = csv.DictReader(f)
        if column not in r.fieldnames:
            raise SystemExit(f"Column '{column}' not found in {path}. Available: {r.fieldnames}")
        for row in r:
            try:
                values.append(float(row[column]))
            except ValueError:
                # skip bad rows
                continue
    return values


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("csv", help="CSV file path")
    ap.add_argument("--column", default="value2", choices=["value1", "value2", "value3"], help="column to analyze")
    args = ap.parse_args()

    t0 = time.perf_counter()
    data = read_column(args.csv, args.column)
    mean = statistics.fmean(data) if data else float("nan")
    median = statistics.median(data) if data else float("nan")
    dt = time.perf_counter() - t0
    print(f"{args.csv}\t{args.column}\t{len(data)}\t{mean:.6f}\t{median:.6f}\t{dt:.3f}")


if __name__ == "__main__":
    main()
