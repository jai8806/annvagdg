/// FoodClassifierService
///
/// Runs EfficientNet-B3 ONNX inference on a food image using ONNX Runtime
/// for Flutter (Android).
library;

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

// Fixed: Removed 'hide OrtEnv' so the class is accessible
import 'package:onnxruntime/onnxruntime.dart'
    if (dart.library.html) 'food_classifier_service_web.dart'
    if (dart.library.js_util) 'food_classifier_service_web.dart'
    as ort;

// ── Constants ────────────────────────────────────────────────────────────────
const int _inputSize = 300;
const List<double> _mean = [0.485, 0.456, 0.406];
const List<double> _std  = [0.229, 0.224, 0.225];
const double _autoFillThreshold = 0.65; 

class FoodPrediction {
  final String label;
  final double confidence;

  const FoodPrediction({required this.label, required this.confidence});

  String get displayName => label
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

class ClassifyResult {
  final FoodPrediction top;
  final List<FoodPrediction> top3;

  // Threshold logic stays here for the "✓ AI identified" badge
  bool get shouldAutoFill => top.confidence >= _autoFillThreshold;

  const ClassifyResult({required this.top, required this.top3});
}

class FoodClassifierService {
  ort.OrtSession? _session;
  List<String>? _labels;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    if (kIsWeb) {
      throw UnsupportedError('ONNX Runtime not supported on web.');
    }

    try {
      // 1. Initialize ORT environment (Synchronous)
      ort.OrtEnv.instance.init();

      // 2. Load Model
      final modelBytes = await rootBundle.load('assets/models/annva_model.onnx');
      final modelBuffer = modelBytes.buffer.asUint8List();
      final sessionOptions = ort.OrtSessionOptions();
      _session = ort.OrtSession.fromBuffer(modelBuffer, sessionOptions);

      // 3. Robust Label Loading
      final labelsJson = await rootBundle.loadString('assets/models/labels.json');
      final List<dynamic> decoded = jsonDecode(labelsJson);
      _labels = decoded.map((e) => e.toString().trim()).toList();

      _initialized = true;
    } catch (e) {
      debugPrint('Service Init Error: $e');
      rethrow;
    }
  }

  Future<ClassifyResult?> classify(Uint8List imageBytes) async {
    if (kIsWeb || !_initialized || _session == null || _labels == null) return null;

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) return null;

    // Preprocessing: Resize & Crop
    final img.Image resized = (decoded.width < decoded.height)
        ? img.copyResize(decoded, width: _inputSize, interpolation: img.Interpolation.linear)
        : img.copyResize(decoded, height: _inputSize, interpolation: img.Interpolation.linear);

    final cropped = img.copyCrop(
      resized,
      x: (resized.width - _inputSize) ~/ 2,
      y: (resized.height - _inputSize) ~/ 2,
      width: _inputSize,
      height: _inputSize,
    );

    // Normalization & Tensor Build
    const pixelCount = _inputSize * _inputSize;
    final tensorData = Float32List(3 * pixelCount);

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = cropped.getPixel(x, y);
        final idx = y * _inputSize + x;
        tensorData[idx] = ((pixel.r / 255.0) - _mean[0]) / _std[0];
        tensorData[idx + pixelCount] = ((pixel.g / 255.0) - _mean[1]) / _std[1];
        tensorData[idx + 2 * pixelCount] = ((pixel.b / 255.0) - _mean[2]) / _std[2];
      }
    }

    final inputTensor = ort.OrtValueTensor.createTensorWithDataList(tensorData, [1, 3, _inputSize, _inputSize]);
    final runOptions = ort.OrtRunOptions();

    try {
      final outputs = _session!.run(runOptions, {_session!.inputNames.first: inputTensor});
      if (outputs.isEmpty || outputs.first?.value == null) return null;

      final rawOutput = outputs.first!.value as List<dynamic>;
      final List<double> logitList = (rawOutput.first as List<dynamic>).map((v) => (v as num).toDouble()).toList();

      // Softmax
      final maxLogit = logitList.reduce(max);
      final exps = logitList.map((v) => exp(v - maxLogit)).toList();
      final sumExp = exps.reduce((a, b) => a + b);
      final probs = exps.map((e) => e / sumExp).toList();

      for (var out in outputs) { out?.release(); }

      final indexed = List<FoodPrediction>.generate(probs.length, (i) => FoodPrediction(
        label: i < _labels!.length ? _labels![i] : 'class_$i',
        confidence: probs[i],
      ))..sort((a, b) => b.confidence.compareTo(a.confidence));

      return ClassifyResult(top: indexed.first, top3: indexed.take(3).toList());
    } finally {
      inputTensor.release();
      runOptions.release();
    }
  }

  void dispose() {
    _session?.release();
    _session = null;
    _initialized = false;
  }
}