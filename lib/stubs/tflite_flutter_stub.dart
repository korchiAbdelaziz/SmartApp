class Interpreter {
  Interpreter._();

  static Future<Interpreter> fromAsset(String assetPath) async {
    throw UnsupportedError('tflite_flutter n\'est pas supporté sur le Web');
  }

  Tensor getInputTensor(int index) {
    throw UnsupportedError('tflite_flutter n\'est pas supporté sur le Web');
  }

  Tensor getOutputTensor(int index) {
    throw UnsupportedError('tflite_flutter n\'est pas supporté sur le Web');
  }

  void run(Object input, Object output) {
    throw UnsupportedError('tflite_flutter n\'est pas supporté sur le Web');
  }

  void close() {}
}

class Tensor {
  List<int> get shape => throw UnsupportedError('tflite_flutter n\'est pas supporté sur le Web');
  TfLiteType get type => throw UnsupportedError('tflite_flutter n\'est pas supporté sur le Web');
}

class TfLiteType {
  final String _name;
  const TfLiteType._(this._name);

  static const TfLiteType float32 = TfLiteType._('float32');
  static const TfLiteType uint8 = TfLiteType._('uint8');
}


