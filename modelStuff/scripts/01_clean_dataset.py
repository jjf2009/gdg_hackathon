"""
STEP 1 — Dataset Cleaning
--------------------------
Run this AFTER extracting the PlantVillage ZIP into a folder called `dataset/`
at the project root.

What it does:
  1. Removes images that Pillow cannot open/verify (corrupted files).
  2. Removes images smaller than MIN_SIZE pixels on either side.
  3. Prints a summary of how many images were removed.

Usage:
    python scripts/01_clean_dataset.py
    python scripts/01_clean_dataset.py --dataset_dir dataset --min_size 100
"""

import os
import argparse
from PIL import Image
from tqdm import tqdm

# --------------------------------------------------------------------------- #
# Config defaults (can be overridden via CLI flags)
# --------------------------------------------------------------------------- #
DEFAULT_DATASET_DIR = "dataset"
MIN_SIZE = 100          # Pixels — both width and height must exceed this

VALID_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".tiff", ".webp"}


def count_images(root: str) -> int:
    total = 0
    for _, _, files in os.walk(root):
        for f in files:
            if os.path.splitext(f)[1].lower() in VALID_EXTENSIONS:
                total += 1
    return total


def clean_dataset(dataset_dir: str, min_size: int) -> None:
    print(f"\n{'='*60}")
    print(f"  Cleaning dataset: {dataset_dir}")
    print(f"  Minimum image size: {min_size}x{min_size} pixels")
    print(f"{'='*60}\n")

    before_count = count_images(dataset_dir)
    print(f"[INFO] Found {before_count} images before cleaning.\n")

    corrupted = 0
    too_small = 0
    checked = 0

    all_files = []
    for root, _, files in os.walk(dataset_dir):
        for f in files:
            if os.path.splitext(f)[1].lower() in VALID_EXTENSIONS:
                all_files.append(os.path.join(root, f))

    for fp in tqdm(all_files, desc="Scanning images"):
        checked += 1
        removed = False

        # ---- 1. Check for corruption ----------------------------------------
        try:
            with Image.open(fp) as img:
                img.verify()          # verify() detects truncated/corrupt files
        except Exception as e:
            print(f"  [CORRUPTED] {fp} → {e}")
            os.remove(fp)
            corrupted += 1
            continue

        # ---- 2. Re-open (verify() closes the file) to check dimensions ------
        try:
            with Image.open(fp) as img:
                w, h = img.size
                if w < min_size or h < min_size:
                    print(f"  [TOO SMALL]  {fp} → ({w}x{h})")
                    os.remove(fp)
                    too_small += 1
                    removed = True
        except Exception as e:
            print(f"  [ERROR]      {fp} → {e}")
            os.remove(fp)
            corrupted += 1

    after_count = count_images(dataset_dir)

    print(f"\n{'='*60}")
    print(f"  Cleaning complete!")
    print(f"  Images checked : {checked}")
    print(f"  Corrupted removed  : {corrupted}")
    print(f"  Too-small removed  : {too_small}")
    print(f"  Total removed  : {corrupted + too_small}")
    print(f"  Remaining images   : {after_count}")
    print(f"{'='*60}\n")


def parse_args():
    parser = argparse.ArgumentParser(description="Clean PlantVillage dataset")
    parser.add_argument(
        "--dataset_dir", type=str, default=DEFAULT_DATASET_DIR,
        help=f"Path to raw dataset folder (default: {DEFAULT_DATASET_DIR})"
    )
    parser.add_argument(
        "--min_size", type=int, default=MIN_SIZE,
        help=f"Minimum pixel size for width/height (default: {MIN_SIZE})"
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    if not os.path.isdir(args.dataset_dir):
        print(f"[ERROR] Dataset directory not found: '{args.dataset_dir}'")
        print("  Please extract the PlantVillage ZIP into a folder called 'dataset/' "
              "at the project root, then re-run this script.")
        exit(1)
    clean_dataset(args.dataset_dir, args.min_size)
