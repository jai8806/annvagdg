// Web platform stub for FoodClassifierService
// Uses TensorFlow.js instead of ONNX Runtime (not yet implemented)

library;

export 'dart:typed_data' show Uint8List;
export 'package:image/image.dart' show decodeImage, copyResize, copyCrop, Image, Interpolation;

// ── Minimal ONNX Runtime stub for web ─────────────────────────────────────
class OrtEnv {
  static final OrtEnv instance = OrtEnv._();
  OrtEnv._();
  void init() {}
  void release() {}
}

class OrtSessionOptions {}

class OrtSession {
  List<String> get inputNames => ['input'];
  
  static OrtSession fromBuffer(dynamic modelBuffer, OrtSessionOptions options) {
    throw UnsupportedError('ONNX Runtime not supported on web. Use TensorFlow.js instead.');
  }
  
  List<OrtValue?>? run(OrtRunOptions? options, Map<String, dynamic> inputs) {
    throw UnsupportedError('ONNX Runtime not supported on web. Use TensorFlow.js instead.');
  }
  
  void release() {}
}

class OrtValueTensor {
  static OrtValue createTensorWithDataList(
    dynamic dataList,
    List<int> shape, [
    String? type,
  ]) {
    throw UnsupportedError('ONNX Runtime not supported on web. Use TensorFlow.js instead.');
  }
}

class OrtRunOptions {
  void release() {}
}

class OrtValue {
  dynamic get value => null;
  void release() {}
}