"""
STEP 3 — Training  (EfficientNet-B0, two-phase transfer learning)
------------------------------------------------------------------
Run AFTER 02_split_dataset.py.

GPU notes (RTX 3050 6 GB / 95 W TGP):
  • GPU memory growth is ALWAYS enabled → TF only grabs what it needs.
  • Mixed-precision float16 is enabled by default → ~2× faster on Tensor
    Cores, uses ~50% less VRAM. Disable with --no_mixed_precision if you
    get NaN losses.
  • Default batch = 32 (safe for B0 @ 224px on 6 GB). If you still OOM,
    drop to --batch_size 16.

Phase 1  → Train top layers only (backbone frozen), 10 epochs
Phase 2  → Fine-tune last 20 backbone layers, 5 more epochs

Outputs:
  models/crop_model_phase1/    — Keras SavedModel after phase 1
  models/crop_model_final/     — Keras SavedModel after fine-tuning
  logs/training_history.png    — Accuracy & loss curves for both phases

Usage:
    python scripts/03_train.py
    python scripts/03_train.py --epochs1 10 --epochs2 5 --batch_size 32
    python scripts/03_train.py --no_mixed_precision   # if NaN losses appear
    python scripts/03_train.py --batch_size 16         # if GPU OOM
"""

import os
import argparse
import json
import numpy as np
import matplotlib
matplotlib.use("Agg")           # headless — no display needed
import matplotlib.pyplot as plt

# ---- GPU config MUST happen before any other TF import uses the GPU ----
# This block is intentionally placed before `import tensorflow as tf`
os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")   # suppress C++ spam

import tensorflow as tf


def configure_cpu() -> None:
    """
    Force CPU training.
    """
    os.environ["CUDA_VISIBLE_DEVICES"] = "-1"
    os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"
    print("[INFO] Forced CPU training (CUDA_VISIBLE_DEVICES=-1).")

# --------------------------------------------------------------------------- #
# Defaults
# --------------------------------------------------------------------------- #
DEFAULT_DATA_DIR  = "data_split"
DEFAULT_IMG_SIZE  = 224
DEFAULT_BATCH     = 32
DEFAULT_EPOCHS1   = 10          # Phase 1: frozen backbone
DEFAULT_EPOCHS2   = 5           # Phase 2: fine-tune
DEFAULT_FINETUNE  = 20          # how many backbone layers to unfreeze from end
MODEL_DIR_P1      = os.path.join("models", "crop_model_phase1.keras")
MODEL_DIR_FINAL   = os.path.join("models", "crop_model_final.keras")
LOGS_DIR          = "logs"


# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #
def build_dataset(split_dir: str, img_size: int, batch_size: int,
                  shuffle: bool = False) -> tf.data.Dataset:
    # shuffle=False — we apply .shuffle() manually with a controlled buffer
    return tf.keras.preprocessing.image_dataset_from_directory(
        split_dir,
        image_size=(img_size, img_size),
        batch_size=batch_size,
        shuffle=shuffle,
        label_mode="int"
    )


# --- Per-image helpers (used in .map() without .cache()) -------------------

_augment_layer = tf.keras.Sequential([
    tf.keras.layers.RandomFlip("horizontal"),
    tf.keras.layers.RandomRotation(0.15),
    tf.keras.layers.RandomZoom(0.10),
    tf.keras.layers.RandomContrast(0.10),
], name="augmentation")


def normalize_single(image):
    """
    EfficientNet models in Keras expect inputs in the [0, 255] range
    because they include an internal Rescaling layer. 
    Do NOT divide by 255.0 here.
    """
    return tf.cast(image, tf.float32)


def augment_single(image):
    """Apply random augmentations to a batch of images."""
    return _augment_layer(image, training=True)


def build_model(num_classes: int, img_size: int) -> tuple:
    """Return (model, base_model) with frozen backbone.

    The final Dense (softmax) is cast to float32 explicitly so it works
    correctly under mixed-precision (float16 activations, float32 output).
    """
    base_model = tf.keras.applications.EfficientNetB0(
        input_shape=(img_size, img_size, 3),
        include_top=False,
        weights="imagenet"
    )
    base_model.trainable = False

    inputs  = tf.keras.Input(shape=(img_size, img_size, 3))
    x       = base_model(inputs, training=False)
    x       = tf.keras.layers.GlobalAveragePooling2D()(x)
    x       = tf.keras.layers.BatchNormalization()(x)
    x       = tf.keras.layers.Dense(256, activation="relu")(x)
    x       = tf.keras.layers.Dropout(0.3)(x)
    outputs = tf.keras.layers.Dense(num_classes, activation="softmax")(x)

    model = tf.keras.Model(inputs, outputs)
    return model, base_model


def compile_model(model, lr=1e-3):
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=lr),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"]
    )


def plot_history(histories: list[dict], labels: list[str], out_path: str) -> None:
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    colors = ["steelblue", "tomato"]

    for i, (hist, label) in enumerate(zip(histories, labels)):
        offset = sum(len(h["accuracy"]) for h in histories[:i])
        epochs = range(offset + 1, offset + len(hist["accuracy"]) + 1)

        axes[0].plot(epochs, hist["accuracy"],     color=colors[i], label=f"{label} train")
        axes[0].plot(epochs, hist["val_accuracy"], color=colors[i], linestyle="--",
                     label=f"{label} val")

        axes[1].plot(epochs, hist["loss"],         color=colors[i], label=f"{label} train")
        axes[1].plot(epochs, hist["val_loss"],     color=colors[i], linestyle="--",
                     label=f"{label} val")

    for ax, title in zip(axes, ["Accuracy", "Loss"]):
        ax.set_title(title);  ax.set_xlabel("Epoch");  ax.legend()

    fig.tight_layout()
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    fig.savefig(out_path, dpi=120)
    print(f"[INFO] Training curves saved → {out_path}")
    plt.close(fig)


def get_callbacks(phase: int) -> list:
    return [
        tf.keras.callbacks.EarlyStopping(
            monitor="val_loss", patience=3, restore_best_weights=True,
            verbose=1
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor="val_loss", factor=0.5, patience=2, min_lr=1e-7, verbose=1
        ),
    ]


# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #
def train(args):
    # ----- Force CPU setup ---------------------------------------
    configure_cpu()

    # ----- Paths -----------------------------------------------------------
    train_dir = os.path.join(args.data_dir, "train")
    val_dir   = os.path.join(args.data_dir, "val")

    for d in [train_dir, val_dir]:
        if not os.path.isdir(d):
            print(f"[ERROR] Directory not found: {d}")
            exit(1)

    os.makedirs("models", exist_ok=True)
    os.makedirs(LOGS_DIR, exist_ok=True)

    # ----- Data pipeline ---------------------------------------------------
    print("\n[INFO] Loading datasets …")
    train_ds_raw = build_dataset(train_dir, args.img_size, args.batch_size, shuffle=True)
    val_ds_raw   = build_dataset(val_dir,   args.img_size, args.batch_size, shuffle=False)

    class_names  = train_ds_raw.class_names
    num_classes  = len(class_names)
    print(f"[INFO] {num_classes} classes detected.")

    # Save class names
    with open(os.path.join(LOGS_DIR, "class_names.json"), "w") as f:
        json.dump(class_names, f, indent=2)
    print(f"[INFO] Class names saved → {LOGS_DIR}/class_names.json")

    # Normalize + augment — NO .cache() here!
    SHUFFLE_BUF = 256   # Reduced buffer size so Epoch 1 starts faster on CPU
    print(f"[INFO] Initializing dataset pipeline (filling shuffle buffer of {SHUFFLE_BUF} images)...")
    train_ds = (train_ds_raw
                .shuffle(SHUFFLE_BUF, reshuffle_each_iteration=True)
                .map(lambda x, y: (normalize_single(x), y),
                     num_parallel_calls=tf.data.AUTOTUNE)
                .map(lambda x, y: (augment_single(x), y),
                     num_parallel_calls=tf.data.AUTOTUNE)
                .prefetch(tf.data.AUTOTUNE))
    val_ds   = (val_ds_raw
                .map(lambda x, y: (normalize_single(x), y),
                     num_parallel_calls=tf.data.AUTOTUNE)
                .prefetch(tf.data.AUTOTUNE))

    # ----- Build model -----------------------------------------------------
    model, base_model = build_model(num_classes, args.img_size)
    compile_model(model, lr=1e-3)
    model.summary()

    # ===================================================================== #
    # Phase 1 — Frozen backbone                                             #
    # ===================================================================== #
    print(f"\n{'='*60}")
    print(f"  Phase 1 — Training top layers only ({args.epochs1} epochs max)")
    print(f"{'='*60}\n")

    h1 = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=args.epochs1,
        callbacks=get_callbacks(1)
    )

    model.save(MODEL_DIR_P1)
    print(f"\n[INFO] Phase-1 model saved → {MODEL_DIR_P1}")

    # ===================================================================== #
    # Phase 2 — Fine-tune last N backbone layers                            #
    # ===================================================================== #
    print(f"\n{'='*60}")
    print(f"  Phase 2 — Fine-tuning last {args.finetune} backbone layers "
          f"({args.epochs2} epochs max)")
    print(f"{'='*60}\n")

    base_model.trainable = True
    for layer in base_model.layers[:-args.finetune]:
        layer.trainable = False

    trainable = sum(1 for l in model.layers if l.trainable)
    print(f"[INFO] {trainable} trainable layers active.")

    # Lower LR for fine-tuning to avoid destroying pretrained weights
    compile_model(model, lr=1e-4)

    h2 = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=args.epochs2,
        callbacks=get_callbacks(2)
    )

    model.save(MODEL_DIR_FINAL)
    print(f"\n[INFO] Final model saved → {MODEL_DIR_FINAL}")

    # ----- Save history ----------------------------------------------------
    histories = [h1.history, h2.history]
    labels    = ["Phase-1", "Phase-2"]
    plot_history(histories, labels, os.path.join(LOGS_DIR, "training_history.png"))

    with open(os.path.join(LOGS_DIR, "training_history.json"), "w") as f:
        json.dump({"phase1": h1.history, "phase2": h2.history}, f,
                  default=lambda x: float(x) if hasattr(x, "__float__") else x)
    print(f"[INFO] Training history saved → {LOGS_DIR}/training_history.json")

    # ----- Final val accuracy ----------------------------------------------
    final_val_acc = h2.history["val_accuracy"][-1]
    print(f"\n[RESULT] Final validation accuracy : {final_val_acc*100:.2f}%")
    print("[DONE] Training complete. Run 04_evaluate.py next.\n")


def parse_args():
    parser = argparse.ArgumentParser(description="Train EfficientNet-B0 on PlantVillage")
    parser.add_argument("--data_dir",   type=str, default=DEFAULT_DATA_DIR)
    parser.add_argument("--img_size",   type=int, default=DEFAULT_IMG_SIZE)
    parser.add_argument("--batch_size", type=int, default=DEFAULT_BATCH,
                        help="Batch size. 32 is safe for 6 GB VRAM. Drop to 16 if OOM.")
    parser.add_argument("--epochs1",    type=int, default=DEFAULT_EPOCHS1,
                        help="Epochs for phase-1 (frozen backbone)")
    parser.add_argument("--epochs2",    type=int, default=DEFAULT_EPOCHS2,
                        help="Epochs for phase-2 (fine-tuning)")
    parser.add_argument("--finetune",   type=int, default=DEFAULT_FINETUNE,
                        help="Number of backbone layers to unfreeze from end")
    return parser.parse_args()


if __name__ == "__main__":
    train(parse_args())
