"""
Annva — ONNX Model Test Script
================================
Tests the exported ONNX model directly in Python.
Run this BEFORE touching Flutter to confirm the model works.

Usage:
    pip install onnxruntime numpy pillow
    python test_onnx_model.py --model path/to/annva_model.onnx \
                               --labels path/to/labels.json \
                               --image path/to/any_food_photo.jpg
"""

import argparse
import json
import sys
import numpy as np
from PIL import Image
import onnxruntime as ort

# ── Must match training & Flutter preprocessing exactly ──────────────────────
INPUT_SIZE = 300
MEAN = np.array([0.485, 0.456, 0.406], dtype=np.float32)
STD  = np.array([0.229, 0.224, 0.225], dtype=np.float32)


def preprocess(image_path: str) -> np.ndarray:
    """Resize → center crop → normalize → CHW float32."""
    img = Image.open(image_path).convert("RGB")
    w, h = img.size

    # Step 1: Resize shortest side to INPUT_SIZE
    if w < h:
        new_w = INPUT_SIZE
        new_h = int(h * INPUT_SIZE / w)
    else:
        new_h = INPUT_SIZE
        new_w = int(w * INPUT_SIZE / h)
    img = img.resize((new_w, new_h), Image.BILINEAR)

    # Step 2: Center crop to INPUT_SIZE × INPUT_SIZE
    left = (new_w - INPUT_SIZE) // 2
    top  = (new_h - INPUT_SIZE) // 2
    img = img.crop((left, top, left + INPUT_SIZE, top + INPUT_SIZE))

    # Step 3: To float32, scale to [0, 1]
    arr = np.array(img, dtype=np.float32) / 255.0  # HWC

    # Step 4: ImageNet normalize
    arr = (arr - MEAN) / STD  # HWC

    # Step 5: HWC → CHW, add batch dim → [1, 3, 300, 300]
    arr = arr.transpose(2, 0, 1)
    arr = np.expand_dims(arr, axis=0)
    return arr


def softmax(logits: np.ndarray) -> np.ndarray:
    e = np.exp(logits - logits.max())
    return e / e.sum()


def run_test(model_path: str, labels_path: str, image_path: str):
    print("\n── 1. Loading model ─────────────────────────────────────")
    try:
        session = ort.InferenceSession(model_path)
        print(f"  ✓ Model loaded: {model_path}")
    except Exception as e:
        print(f"  ✗ Failed to load model: {e}")
        sys.exit(1)

    # Print input/output info — useful to debug shape mismatches in Flutter
    for inp in session.get_inputs():
        print(f"  Input  name='{inp.name}'  shape={inp.shape}  type={inp.type}")
    for out in session.get_outputs():
        print(f"  Output name='{out.name}'  shape={out.shape}  type={out.type}")

    print("\n── 2. Loading labels ────────────────────────────────────")
    try:
        with open(labels_path, "r", encoding="utf-8") as f:
            labels = json.load(f)
        print(f"  ✓ {len(labels)} classes loaded")
        print(f"  First 5: {labels[:5]}")
    except Exception as e:
        print(f"  ✗ Failed to load labels: {e}")
        sys.exit(1)

    print("\n── 3. Preprocessing image ───────────────────────────────")
    try:
        tensor = preprocess(image_path)
        print(f"  ✓ Input tensor shape: {tensor.shape}  dtype: {tensor.dtype}")
        print(f"  ✓ Value range: [{tensor.min():.3f}, {tensor.max():.3f}]")
    except Exception as e:
        print(f"  ✗ Failed to preprocess image: {e}")
        sys.exit(1)

    print("\n── 4. Running inference ─────────────────────────────────")
    try:
        input_name = session.get_inputs()[0].name
        outputs = session.run(None, {input_name: tensor})
        logits = outputs[0]  # shape: [1, num_classes]
        print(f"  ✓ Raw output shape: {logits.shape}")
        print(f"  ✓ Logit range: [{logits.min():.3f}, {logits.max():.3f}]")
    except Exception as e:
        print(f"  ✗ Inference failed: {e}")
        sys.exit(1)

    print("\n── 5. Top-5 predictions ─────────────────────────────────")
    probs = softmax(logits[0])
    top5_idx = probs.argsort()[::-1][:5]

    for rank, idx in enumerate(top5_idx, 1):
        label = labels[idx] if idx < len(labels) else f"class_{idx}"
        conf  = probs[idx] * 100
        flag  = " ← AUTO-FILL ✓" if rank == 1 and probs[idx] >= 0.65 else ""
        print(f"  #{rank}  {conf:6.2f}%  {label}{flag}")

    top_conf = probs[top5_idx[0]]
    print("\n── 6. Verdict ───────────────────────────────────────────")
    if top_conf >= 0.65:
        print(f"  ✓ Model will AUTO-FILL '{labels[top5_idx[0]]}' ({top_conf*100:.1f}%)")
    elif top_conf >= 0.1:
        print(f"  ⚠ Confidence too low for auto-fill ({top_conf*100:.1f}% < 65%)")
        print(f"    Flutter will show suggestion chips instead")
    else:
        print(f"  ✗ Model is not recognising this image at all ({top_conf*100:.1f}%)")
        print(f"    Possible causes:")
        print(f"    - Image is not a food item this model was trained on")
        print(f"    - Model weights did not load correctly during export")
        print(f"    - Preprocessing mismatch between training and export")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--model",  required=True, help="Path to annva_model.onnx")
    parser.add_argument("--labels", required=True, help="Path to labels.json")
    parser.add_argument("--image",  required=True, help="Path to a food photo (JPG/PNG)")
    args = parser.parse_args()

    run_test(args.model, args.labels, args.image)