# 🌿 Plant Disease Detection — EfficientNet-B0
### Step-by-step execution guide

---

## Project Structure

```
gdg-plant-ai/
├── scripts/
│   ├── 01_clean_dataset.py    ← remove corrupted / tiny images
│   ├── 02_split_dataset.py    ← train / val / test split
│   ├── 03_train.py            ← two-phase transfer learning
│   ├── 04_evaluate.py         ← test-set metrics + confusion matrix
│   ├── 05_export_tflite.py    ← float16 TFLite export
│   ├── 06_test_tflite.py      ← verify .tflite on one image
│   └── predict.py             ← quick Keras inference helper
├── dataset/                   ← ⬅ YOU create this (see Step 1)
├── data_split/                ← auto-created by step 2
├── models/                    ← auto-created by step 3
├── logs/                      ← auto-created by step 3
├── requirements.txt
└── README.md
```

---

## Step 0 — Setup virtual env & install deps

```bash
cd gdg-plant-ai
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate

pip install -r requirements.txt
```

---

## Step 1 — Download PlantVillage dataset

**Option A — Kaggle (recommended, ~2 GB):**

1. Go to → https://www.kaggle.com/datasets/abdallahalidev/plantvillage-dataset
2. Download the ZIP
3. Extract so the folder structure looks like:

```
gdg-plant-ai/
└── dataset/
    ├── Apple___Apple_scab/
    │   ├── image001.jpg
    │   └── ...
    ├── Apple___Black_rot/
    ├── Apple___healthy/
    ├── Tomato___Early_blight/
    └── ...  (38 classes total)
```

> Each subfolder = one class. The folder name IS the label.

**Option B — GitHub mirror (no Kaggle account needed):**

```bash
# ~1 GB segmented dataset
git clone https://github.com/spMohanty/PlantVillage-Dataset.git tmp_pv
cp -r tmp_pv/raw/color dataset
rm -rf tmp_pv
```

---

## Step 2 — Clean the dataset

Removes corrupted files and images smaller than 100×100 px.

```bash
python scripts/01_clean_dataset.py
```

Expected output:
```
[INFO] Found ~54,000 images before cleaning.
[INFO] Cleaning complete! Corrupted: 0, Too-small: ~20
```

---

## Step 3 — Split into train / val / test

```bash
python scripts/02_split_dataset.py
```

Creates `data_split/train/`, `data_split/val/`, `data_split/test/`  
Split ratio: **70% train | 20% val | 10% test**

Prints a per-class distribution table so you can verify balance.

---

## Step 4 — Train the model

```bash
python scripts/03_train.py
```

**What happens:**
- Phase 1 (10 epochs) — EfficientNet-B0 backbone frozen, only classification head trains
- Phase 2 (5 epochs) — Last 20 backbone layers unfrozen, fine-tuned at lower LR

**Outputs:**
- `models/crop_model_phase1/` — checkpoint after phase 1
- `models/crop_model_final/`  — final fine-tuned model
- `logs/training_history.png` — accuracy & loss curves
- `logs/class_names.json`     — class index → label mapping

**Time estimates (rough):**
| Hardware | Phase 1 | Phase 2 |
|----------|---------|---------|
| GPU (T4) | ~8 min  | ~4 min  |
| CPU only | ~2–3 hr | ~1 hr   |

> Tip: Add `--epochs1 5 --epochs2 3` to reduce time during testing.

---

## Step 5 — Evaluate on test set

```bash
python scripts/04_evaluate.py
```

**Outputs:**
- Console: overall accuracy + loss
- `logs/classification_report.txt` — per-class precision, recall, F1
- `logs/confusion_matrix.png`      — normalised heatmap
- `logs/misclassified.png`         — sample of wrong predictions

Expected accuracy: **85–93%** on PlantVillage test set.

---

## Step 6 — Export to TFLite (for Android)

```bash
python scripts/05_export_tflite.py
```

Outputs `models/model.tflite` (~15–20 MB with float16 quantisation).

---

## Step 7 — Test the .tflite model on one image

```bash
python scripts/06_test_tflite.py --image dataset/Apple___Black_rot/image001.jpg
```

Shows top-5 predictions with confidence bars:
```
#1   Apple___Black_rot                         94.21%  ██████████████████████████████
#2   Apple___Apple_scab                          3.12%  █
```

---

## Quick Keras inference (no TFLite)

```bash
python scripts/predict.py --image path/to/leaf.jpg
```

---

## Flags cheat-sheet

| Script | Key flags | Default |
|--------|-----------|---------|
| `01_clean_dataset.py` | `--dataset_dir`, `--min_size` | `dataset`, `100` |
| `02_split_dataset.py` | `--dataset_dir`, `--output`, `--ratio` | `dataset`, `data_split`, `0.7 0.2 0.1` |
| `03_train.py` | `--epochs1`, `--epochs2`, `--batch_size`, `--finetune` | `10`, `5`, `32`, `20` |
| `04_evaluate.py` | `--model_dir` | `models/crop_model_final` |
| `05_export_tflite.py` | `--model_dir`, `--output` | `models/crop_model_final`, `models/model.tflite` |
| `06_test_tflite.py` | `--image`, `--top_k` | required, `5` |

---

## What you get at the end

| File | Purpose |
|------|---------|
| `models/crop_model_final/` | Full Keras model (use in Python) |
| `models/model.tflite` | Android-ready model |
| `logs/class_names.json` | Label index mapping |
| `logs/training_history.png` | Training curves |
| `logs/confusion_matrix.png` | Error analysis |
