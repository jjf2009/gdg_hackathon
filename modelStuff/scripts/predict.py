"""
Quick Predict Utility
----------------------
Lets you classify a single image using the KERAS model (not TFLite).
Useful for quick sanity checks during or after training.

Usage:
    python scripts/predict.py --image path/to/leaf.jpg
"""

import os
import json
import argparse
import numpy as np
from PIL import Image
import tensorflow as tf

DEFAULT_MODEL_DIR = os.path.join("models", "crop_model_final.keras")
DEFAULT_CLASSES   = os.path.join("logs", "class_names.json")
DEFAULT_IMG_SIZE  = 224
DEFAULT_TOP_K     = 5


def predict(args):
    if not os.path.exists(args.image):
        print(f"[ERROR] Image not found: {args.image}"); exit(1)
    if not os.path.exists(args.model_dir):
        print(f"[ERROR] Model not found: {args.model_dir}"); exit(1)
    if not os.path.exists(args.classes):
        print(f"[ERROR] Class names file not found: {args.classes}"); exit(1)

    with open(args.classes) as f:
        class_names = json.load(f)

    print(f"[INFO] Loading model …")
    model = tf.keras.models.load_model(args.model_dir)

    img = Image.open(args.image).convert("RGB").resize(
        (args.img_size, args.img_size))
    arr = np.array(img, dtype=np.float32)
    arr = np.expand_dims(arr, axis=0)

    probs = model.predict(arr, verbose=0)[0]
    top_k = np.argsort(probs)[::-1][:args.top_k]

    print(f"\n{'='*55}")
    print(f"  Keras Inference — {os.path.basename(args.image)}")
    print(f"{'='*55}")
    for rank, idx in enumerate(top_k, 1):
        bar = "█" * int(probs[idx] * 30)
        print(f"  #{rank}  {class_names[idx]:<40}  {probs[idx]*100:6.2f}%  {bar}")
    print(f"\n  ✓ Top Prediction: {class_names[top_k[0]]}")
    print(f"{'='*55}\n")


def parse_args():
    parser = argparse.ArgumentParser(description="Quick image prediction with Keras model")
    parser.add_argument("--image",     type=str, required=True)
    parser.add_argument("--model_dir", type=str, default=DEFAULT_MODEL_DIR)
    parser.add_argument("--classes",   type=str, default=DEFAULT_CLASSES)
    parser.add_argument("--img_size",  type=int, default=DEFAULT_IMG_SIZE)
    parser.add_argument("--top_k",     type=int, default=DEFAULT_TOP_K)
    return parser.parse_args()


if __name__ == "__main__":
    predict(parse_args())
