"""
STEP 2 — Dataset Splitting
---------------------------
Run AFTER 01_clean_dataset.py.

Splits `dataset/` into train / val / test subsets and writes them to
`data_split/` using the split-folders library (pip install split-folders).

Default split: 70% train | 20% val | 10% test

Usage:
    python scripts/02_split_dataset.py
    python scripts/02_split_dataset.py --dataset_dir dataset --output data_split --ratio 0.7 0.2 0.1
"""

import os
import argparse
import shutil
import splitfolders
from collections import defaultdict

# --------------------------------------------------------------------------- #
# Defaults
# --------------------------------------------------------------------------- #
DEFAULT_INPUT  = "dataset"
DEFAULT_OUTPUT = "data_split"
DEFAULT_RATIO  = (0.7, 0.2, 0.1)
SEED = 42


def print_distribution(output_dir: str) -> None:
    """Print per-class image counts for each split."""
    splits = [d for d in os.listdir(output_dir)
              if os.path.isdir(os.path.join(output_dir, d))]
    splits.sort()

    all_classes = set()
    counts: dict[str, dict[str, int]] = defaultdict(dict)

    for split in splits:
        split_path = os.path.join(output_dir, split)
        for cls in os.listdir(split_path):
            cls_path = os.path.join(split_path, cls)
            if os.path.isdir(cls_path):
                n = len([f for f in os.listdir(cls_path)
                         if os.path.isfile(os.path.join(cls_path, f))])
                counts[split][cls] = n
                all_classes.add(cls)

    all_classes = sorted(all_classes)

    # Header
    header = f"{'Class':<40}" + "".join(f"{s:>10}" for s in splits) + f"{'Total':>10}"
    print(f"\n{'-'*len(header)}")
    print(header)
    print(f"{'-'*len(header)}")

    grand_total = defaultdict(int)
    for cls in all_classes:
        row_vals = [counts[s].get(cls, 0) for s in splits]
        total = sum(row_vals)
        row = f"{cls:<40}" + "".join(f"{v:>10}" for v in row_vals) + f"{total:>10}"
        print(row)
        for s, v in zip(splits, row_vals):
            grand_total[s] += v

    print(f"{'-'*len(header)}")
    totals_row = (f"{'TOTAL':<40}"
                  + "".join(f"{grand_total[s]:>10}" for s in splits)
                  + f"{sum(grand_total.values()):>10}")
    print(totals_row)
    print(f"{'-'*len(header)}\n")


def split_dataset(input_dir: str, output_dir: str, ratio: tuple, seed: int) -> None:
    print(f"\n{'='*60}")
    print(f"  Splitting dataset")
    print(f"  Input  : {input_dir}")
    print(f"  Output : {output_dir}")
    print(f"  Ratio  : train={ratio[0]} | val={ratio[1]} | test={ratio[2]}")
    print(f"{'='*60}\n")

    if os.path.exists(output_dir):
        print(f"[WARN] Output directory '{output_dir}' already exists.")
        choice = input("  Delete and recreate? [y/N]: ").strip().lower()
        if choice == "y":
            shutil.rmtree(output_dir)
            print(f"  Deleted '{output_dir}'.")
        else:
            print("  Aborted. Remove or rename the existing directory and retry.")
            exit(0)

    splitfolders.ratio(
        input_dir,
        output=output_dir,
        seed=seed,
        ratio=ratio,
        group_prefix=None,
        move=False   # copy — keep original dataset intact
    )

    print(f"\n[SUCCESS] Split complete → '{output_dir}/'")
    print_distribution(output_dir)

    # Save class names to a text file for reference
    classes_file = os.path.join(output_dir, "class_names.txt")
    train_dir = os.path.join(output_dir, "train")
    if os.path.isdir(train_dir):
        class_names = sorted([
            d for d in os.listdir(train_dir)
            if os.path.isdir(os.path.join(train_dir, d))
        ])
        with open(classes_file, "w") as f:
            f.write("\n".join(class_names))
        print(f"[INFO] {len(class_names)} classes saved to '{classes_file}'")


def parse_args():
    parser = argparse.ArgumentParser(description="Split cleaned dataset into train/val/test")
    parser.add_argument("--dataset_dir", type=str, default=DEFAULT_INPUT)
    parser.add_argument("--output",      type=str, default=DEFAULT_OUTPUT)
    parser.add_argument("--ratio",       type=float, nargs=3,
                        default=list(DEFAULT_RATIO),
                        metavar=("TRAIN", "VAL", "TEST"))
    parser.add_argument("--seed",        type=int, default=SEED)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    if not os.path.isdir(args.dataset_dir):
        print(f"[ERROR] Input directory not found: '{args.dataset_dir}'")
        exit(1)
    ratio = tuple(args.ratio)
    if abs(sum(ratio) - 1.0) > 1e-6:
        print("[ERROR] Ratios must sum to 1.0")
        exit(1)
    split_dataset(args.dataset_dir, args.output, ratio, args.seed)
