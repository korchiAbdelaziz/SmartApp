import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'package:tflite_flutter/tflite_flutter.dart'
    if (dart.library.html) '../stubs/tflite_flutter_stub.dart' as tflite;

class Classifier {
  tflite.Interpreter? _interpreter;
  List<String> _labels = [];
  int inputWidth = 224;
  int inputHeight = 224;
  int inputChannels = 3;
  bool _isInitialized = false;

  Future<void> loadModel(
      {String modelPath = 'assets/model/model.tflite',
      String labelsPath = 'assets/model/labels.txt'}) async {
    if (_isInitialized) return;

    _interpreter = await tflite.Interpreter.fromAsset(modelPath);

    final labelsData = await rootBundle.loadString(labelsPath);
    _labels = labelsData
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final inputTensor = _interpreter!.getInputTensor(0);
    final shape = inputTensor.shape; // usually [1, height, width, channels]
    if (shape.length >= 4) {
      inputHeight = shape[1];
      inputWidth = shape[2];
      inputChannels = shape[3];
    }

    _isInitialized = true;
  }

  Future<Map<String, dynamic>> predict(File imageFile) async {
    if (!_isInitialized) await loadModel();
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Impossible de décoder l\'image');

    final resized =
        img.copyResize(image, width: inputWidth, height: inputHeight);

    final inputTensor = _interpreter!.getInputTensor(0);
    final tType = inputTensor.type;
    final tTypeStr = tType.toString().toLowerCase();

    // Prepare input as nested Lists: [1][h][w][c]
    final input = List.generate(1, (_) {
      return List.generate(inputHeight, (y) {
        return List.generate(inputWidth, (x) {
          return List.generate(inputChannels, (c) {
            final pixel = resized.getPixel(x, y);
            final r = pixel.r.toInt();
            final g = pixel.g.toInt();
            final b = pixel.b.toInt();
            if (tTypeStr.contains('uint')) {
              // models expecting uint8 use raw 0-255 values
              if (c == 0) return r;
              if (c == 1) return g;
              return b;
            } else {
              // float32: normalize to 0..1 (user can adjust to [-1,1] if needed)
              if (c == 0) return r / 255.0;
              if (c == 1) return g / 255.0;
              return b / 255.0;
            }
          });
        });
      });
    });

    // Prepare output buffer. Many models output shape [1, numLabels]
    final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));

    _interpreter!.run(input, output);

    final results = output[0].asMap();
    int bestIdx = 0;
    double bestScore = -double.maxFinite;
    results.forEach((idx, score) {
      final s = (score as num).toDouble();
      if (s > bestScore) {
        bestScore = s;
        bestIdx = idx;
      }
    });

    final label = (bestIdx >= 0 && bestIdx < _labels.length)
        ? _labels[bestIdx]
        : 'Unknown';

    return {
      'label': label,
      'index': bestIdx,
      'confidence': bestScore,
    };
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
