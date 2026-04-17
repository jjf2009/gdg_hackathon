"""
STEP 6 — Test TFLite Model on a Single Image
----------------------------------------------
Run AFTER 05_export_tflite.py to verify the .tflite model gives the
same prediction as the Keras model.

Usage:
    python scripts/06_test_tflite.py --image path/to/leaf.jpg
    python scripts/06_test_tflite.py --image path/to/leaf.jpg --tflite models/model.tflite --top_k 5
"""

import os
import json
import argparse
import numpy as np
from PIL import Image
import tensorflow as tf

DEFAULT_TFLITE    = os.path.join("models", "model.tflite")
DEFAULT_CLASSES   = os.path.join("logs", "class_names.json")
DEFAULT_IMG_SIZE  = 224
DEFAULT_TOP_K     = 5


def load_class_names(path: str) -> list[str]:
    with open(path) as f:
        return json.load(f)


def preprocess(image_path: str, img_size: int) -> np.ndarray:
    img = Image.open(image_path).convert("RGB").resize((img_size, img_size))
    arr = np.array(img, dtype=np.float32)
    return np.expand_dims(arr, axis=0)          # shape: (1, H, W, 3)


def run_inference(args):
    # ----- Validate inputs --------------------------------------------------
    if not os.path.exists(args.image):
        print(f"[ERROR] Image not found: {args.image}")
        exit(1)
    if not os.path.exists(args.tflite):
        print(f"[ERROR] TFLite model not found: {args.tflite}")
        exit(1)
    if not os.path.exists(args.classes):
        print(f"[ERROR] Class names file not found: {args.classes}")
        exit(1)

    class_names = load_class_names(args.classes)
    print(f"\n[INFO] {len(class_names)} classes loaded.")

    # ----- Load interpreter -------------------------------------------------
    interpreter = tf.lite.Interpreter(model_path=args.tflite)
    interpreter.allocate_tensors()

    input_details  = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    # ----- Preprocess image -------------------------------------------------
    inp = preprocess(args.image, args.img_size)

    # Cast to expected dtype (float32)
    inp = inp.astype(input_details[0]["dtype"])

    # ----- Inference --------------------------------------------------------
    interpreter.set_tensor(input_details[0]["index"], inp)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]["index"])[0]   # shape: (num_classes,)

    # ----- Top-K results ----------------------------------------------------
    top_k_idx   = np.argsort(output)[::-1][:args.top_k]
    top_k_probs = output[top_k_idx]

    print(f"\n{'='*55}")
    print(f"  TFLite Inference Result")
    print(f"  Image : {args.image}")
    print(f"{'='*55}")
    print(f"  Rank  {'Class':<40}  Confidence")
    print(f"  {'-'*50}")
    for rank, (idx, prob) in enumerate(zip(top_k_idx, top_k_probs), 1):
        bar = "█" * int(prob * 30)
        print(f"  #{rank:<4} {class_names[idx]:<40}  {prob*100:6.2f}%  {bar}")

    print(f"\n  ✓ Top Prediction: {class_names[top_k_idx[0]]}  "
          f"({top_k_probs[0]*100:.2f}% confidence)")
    print(f"{'='*55}\n")


def parse_args():
    parser = argparse.ArgumentParser(description="Test TFLite model on a single image")
    parser.add_argument("--image",    type=str, required=True,
                        help="Path to the leaf image to classify")
    parser.add_argument("--tflite",   type=str, default=DEFAULT_TFLITE)
    parser.add_argument("--classes",  type=str, default=DEFAULT_CLASSES)
    parser.add_argument("--img_size", type=int, default=DEFAULT_IMG_SIZE)
    parser.add_argument("--top_k",    type=int, default=DEFAULT_TOP_K)
    return parser.parse_args()


if __name__ == "__main__":
    run_inference(parse_args())
