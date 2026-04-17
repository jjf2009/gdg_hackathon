"""
STEP 4 — Model Evaluation
--------------------------
Run AFTER 03_train.py.

Evaluates the final Keras model on the held-out test set and outputs:
  • Overall accuracy & loss
  • Per-class precision, recall, F1 (classification report)
  • Confusion matrix image  → logs/confusion_matrix.png
  • Top-5 misclassified samples → logs/misclassified.png

Usage:
    python scripts/04_evaluate.py
    python scripts/04_evaluate.py --model_dir models/crop_model_final --data_dir data_split
"""

import os
import json
import argparse
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import seaborn as sns
import tensorflow as tf
from sklearn.metrics import classification_report, confusion_matrix

DEFAULT_MODEL_DIR = os.path.join("models", "crop_model_final.keras")
DEFAULT_DATA_DIR  = "data_split"
DEFAULT_IMG_SIZE  = 224
DEFAULT_BATCH     = 32
LOGS_DIR          = "logs"


def load_class_names(data_dir: str, logs_dir: str) -> list[str]:
    # Prefer class names saved by the training script
    json_path = os.path.join(logs_dir, "class_names.json")
    if os.path.exists(json_path):
        with open(json_path) as f:
            return json.load(f)
    # Fall back: infer from test directory
    test_dir = os.path.join(data_dir, "test")
    return sorted([d for d in os.listdir(test_dir)
                   if os.path.isdir(os.path.join(test_dir, d))])


def evaluate(args):
    os.makedirs(LOGS_DIR, exist_ok=True)

    # ----- Load model -------------------------------------------------------
    print(f"\n[INFO] Loading model from: {args.model_dir}")
    if not os.path.exists(args.model_dir):
        print(f"[ERROR] Model dir not found: {args.model_dir}")
        exit(1)
    model = tf.keras.models.load_model(args.model_dir)

    class_names = load_class_names(args.data_dir, LOGS_DIR)
    num_classes = len(class_names)
    print(f"[INFO] {num_classes} classes loaded.")

    # ----- Test dataset -----------------------------------------------------
    test_dir = os.path.join(args.data_dir, "test")
    test_ds  = tf.keras.preprocessing.image_dataset_from_directory(
        test_dir,
        image_size=(args.img_size, args.img_size),
        batch_size=args.batch_size,
        shuffle=False,
        label_mode="int"
    )

    # Normalize (must match training exactly — DO NOT divide by 255.0 for EfficientNet)
    test_ds_norm = (test_ds
                    .map(lambda x, y: (tf.cast(x, tf.float32), y))
                    .prefetch(tf.data.AUTOTUNE))

    # ----- Overall metrics --------------------------------------------------
    print("\n[INFO] Running model.evaluate …")
    loss, acc = model.evaluate(test_ds_norm, verbose=1)
    print(f"\n  Test Loss     : {loss:.4f}")
    print(f"  Test Accuracy : {acc*100:.2f}%\n")

    # ----- Predictions for per-class report ---------------------------------
    print("[INFO] Generating predictions …")
    y_true, y_pred = [], []
    image_batches = []

    for images, labels in test_ds_norm:
        preds = model.predict(images, verbose=0)
        y_true.extend(labels.numpy())
        y_pred.extend(np.argmax(preds, axis=1))
        image_batches.append((images.numpy(), labels.numpy(), preds))

    y_true = np.array(y_true)
    y_pred = np.array(y_pred)

    # ----- Classification report --------------------------------------------
    report = classification_report(y_true, y_pred, target_names=class_names)
    print("\nClassification Report:")
    print(report)
    report_path = os.path.join(LOGS_DIR, "classification_report.txt")
    with open(report_path, "w") as f:
        f.write(report)
    print(f"[INFO] Report saved → {report_path}")

    # ----- Confusion matrix -------------------------------------------------
    print("[INFO] Plotting confusion matrix …")
    cm = confusion_matrix(y_true, y_pred)

    # Normalize for readability when there are many classes
    cm_norm = cm.astype(float) / cm.sum(axis=1, keepdims=True)

    fig_size = max(10, num_classes // 3)
    fig, ax = plt.subplots(figsize=(fig_size, fig_size))
    sns.heatmap(
        cm_norm, annot=(num_classes <= 20),
        fmt=".2f" if num_classes <= 20 else "",
        cmap="Blues",
        xticklabels=class_names if num_classes <= 30 else False,
        yticklabels=class_names if num_classes <= 30 else False,
        ax=ax
    )
    ax.set_xlabel("Predicted", fontsize=12)
    ax.set_ylabel("True",      fontsize=12)
    ax.set_title("Confusion Matrix (normalised)", fontsize=14)
    fig.tight_layout()
    cm_path = os.path.join(LOGS_DIR, "confusion_matrix.png")
    fig.savefig(cm_path, dpi=120)
    plt.close(fig)
    print(f"[INFO] Confusion matrix saved → {cm_path}")

    # ----- Misclassified samples --------------------------------------------
    print("[INFO] Collecting misclassified samples …")
    wrong_idxs   = np.where(y_true != y_pred)[0]
    n_show       = min(15, len(wrong_idxs))

    if n_show > 0:
        all_images = []
        all_labels = []
        all_preds  = []
        for imgs, lbls, pr in image_batches:
            for img, lbl, p in zip(imgs, lbls, pr):
                all_images.append(img)
                all_labels.append(lbl)
                all_preds.append(p)

        fig, axes = plt.subplots(3, 5, figsize=(20, 12))
        axes = axes.flatten()

        for i, idx in enumerate(wrong_idxs[:n_show]):
            img = all_images[idx]
            ax  = axes[i]
            ax.imshow(img)
            ax.axis("off")
            ax.set_title(
                f"True: {class_names[all_labels[idx]]}\n"
                f"Pred: {class_names[all_preds[idx].argmax()]}",
                fontsize=7
            )

        for j in range(n_show, len(axes)):
            axes[j].axis("off")

        fig.suptitle(f"Misclassified Samples (showing {n_show})", fontsize=14)
        fig.tight_layout()
        misc_path = os.path.join(LOGS_DIR, "misclassified.png")
        fig.savefig(misc_path, dpi=100)
        plt.close(fig)
        print(f"[INFO] Misclassified samples saved → {misc_path}")
    else:
        print("[INFO] No misclassified samples found — perfect test set score!")

    print(f"\n{'='*60}")
    print(f"  Evaluation complete!")
    print(f"  Accuracy  : {acc*100:.2f}%")
    print(f"  Loss      : {loss:.4f}")
    print(f"  Reports   : {LOGS_DIR}/")
    print(f"{'='*60}\n")
    print("[DONE] Run 05_export_tflite.py next.\n")


def parse_args():
    parser = argparse.ArgumentParser(description="Evaluate trained model on test set")
    parser.add_argument("--model_dir", type=str, default=DEFAULT_MODEL_DIR)
    parser.add_argument("--data_dir",  type=str, default=DEFAULT_DATA_DIR)
    parser.add_argument("--img_size",  type=int, default=DEFAULT_IMG_SIZE)
    parser.add_argument("--batch_size",type=int, default=DEFAULT_BATCH)
    return parser.parse_args()


if __name__ == "__main__":
    evaluate(parse_args())
