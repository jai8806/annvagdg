"""
Annva — EfficientNet-B3 Model Export Script
============================================
Run ONCE from the project root after activating your PyTorch environment:

    python model/export_to_onnx.py

Requirements:
    pip install torch torchvision

Outputs:
    public/annva_model.onnx   ← ONNX model (opset 15)
    public/labels.json        ← class names in training index order
"""

import json
import pathlib
import torch
import torch.nn as nn
import torchvision.models as models
import onnxscript 
# ── Paths ───────────────────────────────────────────────────────────────
PROJECT_ROOT = pathlib.Path(__file__).parent.parent
CHECKPOINT   = PROJECT_ROOT / "model" / "annva_model.pth"

# Web (Vite/Capacitor) assets
OUT_ONNX_WEB     = PROJECT_ROOT / "public" / "annva_model.onnx"
OUT_LABELS_WEB   = PROJECT_ROOT / "public" / "labels.json"

# Flutter assets (for Android ONNX Runtime)
OUT_ONNX_FLUTTER   = PROJECT_ROOT / "assets" / "models" / "annva_model.onnx"
OUT_LABELS_FLUTTER = PROJECT_ROOT / "assets" / "models" / "labels.json"

for p in [OUT_ONNX_WEB.parent, OUT_ONNX_FLUTTER.parent]:
    p.mkdir(parents=True, exist_ok=True)

# ── 1. Load the checkpoint dictionary ─────────────────────────────────────────
print(f"Loading checkpoint: {CHECKPOINT}")
ckpt = torch.load(CHECKPOINT, map_location="cpu")

# Show available keys for debugging
print(f"  Checkpoint keys: {list(ckpt.keys())}")

class_names = ckpt["class_names"]           # list — preserves training order
num_classes = len(class_names)
print(f"  Found {num_classes} classes: {class_names[:5]} ...")

# ── 2. Build EfficientNet-B3 and reconstruct the EXACT training classifier ────
#
# The checkpoint reveals a 2-layer custom head:
#   [0] Dropout
#   [1] Linear(1536 → 512)   ← hidden layer
#   [2] ReLU
#   [3] Dropout
#   [4] Linear(512 → num_classes)  ← output layer
#
# We infer the hidden-layer size from the checkpoint weights.
print("Building EfficientNet-B3 ...")
model = models.efficientnet_b3(weights=None)

in_features   = model.classifier[1].in_features   # 1536 for B3
hidden_weight = ckpt["model_state_dict"]["classifier.1.weight"]
hidden_size   = hidden_weight.shape[0]             # 512 (from checkpoint)

model.classifier = nn.Sequential(
    nn.Dropout(p=0.3, inplace=True),
    nn.Linear(in_features, hidden_size),
    nn.ReLU(),
    nn.Dropout(p=0.2),
    nn.Linear(hidden_size, num_classes),
)
print(f"  Classifier: Linear({in_features}→{hidden_size}) → ReLU → Linear({hidden_size}→{num_classes})")

# ── 3. Load the trained weights ────────────────────────────────────────────────
model.load_state_dict(ckpt["model_state_dict"])
model.eval()
print("  Weights loaded successfully ✓")

# ── 4. Export to ONNX (opset 15) ──────────────────────────────────────────────
# Input: [batch, 3, 300, 300]  — EfficientNet-B3 native resolution
dummy_input = torch.zeros(1, 3, 300, 300)

print(f"Exporting ONNX model ...")
torch.onnx.export(
    model,
    dummy_input,
    str(OUT_ONNX_WEB),
    opset_version=15,
    input_names=["input"],
    output_names=["logits"],
    dynamic_axes={
        "input":  {0: "batch"},
        "logits": {0: "batch"},
    },
    do_constant_folding=True,
)

# Copy to Flutter assets directory
import shutil
shutil.copy(OUT_ONNX_WEB, OUT_ONNX_FLUTTER)
print(f"  Web    → {OUT_ONNX_WEB}  ({OUT_ONNX_WEB.stat().st_size / 1_048_576:.1f} MB) ✓")
print(f"  Flutter→ {OUT_ONNX_FLUTTER} ✓")

# ── 5. Save class labels in exact training index order ─────────────────────
labels_content = json.dumps(class_names, ensure_ascii=False, indent=2)
OUT_LABELS_WEB.write_text(labels_content)
OUT_LABELS_FLUTTER.write_text(labels_content)
print(f"  Labels  → {OUT_LABELS_WEB} ✓")
print(f"  Labels  → {OUT_LABELS_FLUTTER} ✓")

print("\n✅  Export complete!")
print(f"   ONNX  : {OUT_ONNX_FLUTTER}")
print(f"   Labels: {OUT_LABELS_FLUTTER}")
print("\nNext step: run  npm install  then  npm run dev")
