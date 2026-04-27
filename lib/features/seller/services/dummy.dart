// Dummy ONNX Runtime for web platform
// This file is used when building for web (dart:html)

class OrtEnv {
  static final OrtEnv instance = OrtEnv._();
  OrtEnv._();
  void init() {}
  void release() {}
}

class OrtSessionOptions {}

class OrtSession {
  List<String> get inputNames => [];
  
  static OrtSession fromBuffer(dynamic modelBuffer, OrtSessionOptions options) {
    throw UnsupportedError('ONNX Runtime not supported on web');
  }
  
  List<OrtValue?>? run(OrtRunOptions options, Map<String, dynamic> inputs) {
    throw UnsupportedError('ONNX Runtime not supported on web');
  }
  
  void release() {}
}

class OrtValueTensor {
  static OrtValue createTensorWithDataList(
    dynamic dataList,
    List<int> shape, [
    String? type,
  ]) {
    throw UnsupportedError('ONNX Runtime not supported on web');
  }
}

class OrtRunOptions {
  void release() {}
}

class OrtValue {
  dynamic get value => null;
  void release() {}
}

// Export a nullable list type for the dummy
typedef OrtValueNullableList = List<OrtValue?>?;
}