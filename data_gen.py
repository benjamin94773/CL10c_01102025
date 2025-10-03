#!/usr/bin/env python3
"""
Generate three CSV files (data1.csv, data2.csv, data3.csv) with random values.

Columns: value1, value2, value3

Usage (Windows PowerShell):
  python data_gen.py             # generate default 200_000 rows per file
  python data_gen.py --rows 500000
"""
from __future__ import annotations
import argparse
import csv
import os
import random
from typing import List


def gen_rows(n: int) -> List[List[float]]:
    rnd = random.Random(42)  # fixed seed for reproducibility
    return [[rnd.uniform(0, 100), rnd.uniform(0, 100), rnd.uniform(0, 100)] for _ in range(n)]


def write_csv(path: str, rows: List[List[float]]) -> None:
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["value1", "value2", "value3"])  # header
        w.writerows(rows)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--rows", type=int, default=200_000, help="rows per file (default: 200k)")
    ap.add_argument("--outdir", default=".", help="output directory (default: current dir)")
    args = ap.parse_args()

    for i in (1, 2, 3):
        rows = gen_rows(args.rows)
        write_csv(os.path.join(args.outdir, f"data{i}.csv"), rows)
    print(f"Generated data1.csv, data2.csv, data3.csv in {os.path.abspath(args.outdir)} with {args.rows} rows each.")


if __name__ == "__main__":
    main()
