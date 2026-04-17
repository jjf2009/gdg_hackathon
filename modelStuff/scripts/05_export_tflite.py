"""
STEP 5 — Export to TensorFlow Lite
------------------------------------
Run AFTER 04_evaluate.py (or at least after 03_train.py).

Converts the Keras SavedModel to a float16-quantised .tflite file suitable
for Android deployment.

Outputs:
  models/model.tflite

Usage:
    python scripts/05_export_tflite.py
    python scripts/05_export_tflite.py --model_dir models/crop_model_final --output models/model.tflite
"""

import os
import argparse
import tensorflow as tf

DEFAULT_MODEL_DIR = os.path.join("models", "crop_model_final.keras")
DEFAULT_OUTPUT    = os.path.join("models", "model.tflite")


def export(args):
    if not os.path.exists(args.model_dir):
        print(f"[ERROR] Model directory not found: {args.model_dir}")
        exit(1)

    print(f"\n[INFO] Loading model from: {args.model_dir}")
    model = tf.keras.models.load_model(args.model_dir)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)

    # ---- Optimisations -------------------------------------------------------
    # DEFAULT applies post-training quantisation strategies automatically.
    converter.optimizations = [tf.lite.Optimize.DEFAULT]

    # Float16 keeps reasonable accuracy with ~50% size reduction
    converter.target_spec.supported_types = [tf.float16]

    # Allow TF ops that TFLite doesn't natively support (safe for most models)
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS,
        tf.lite.OpsSet.SELECT_TF_OPS,
    ]
    converter._experimental_lower_tensor_list_ops = False

    print("[INFO] Converting …  (this can take a minute)")
    tflite_model = converter.convert()

    os.makedirs(os.path.dirname(args.output), exist_ok=True)
    with open(args.output, "wb") as f:
        f.write(tflite_model)

    size_mb = os.path.getsize(args.output) / (1024 * 1024)
    print(f"\n[SUCCESS] TFLite model saved → {args.output}")
    print(f"          File size: {size_mb:.2f} MB")
    print("[DONE] Run 06_test_tflite.py to verify the .tflite model.\n")


def parse_args():
    parser = argparse.ArgumentParser(description="Convert Keras model to TFLite")
    parser.add_argument("--model_dir", type=str, default=DEFAULT_MODEL_DIR)
    parser.add_argument("--output",    type=str, default=DEFAULT_OUTPUT)
    return parser.parse_args()


if __name__ == "__main__":
    export(parse_args())
