import 'dart:io';
import 'dart:typed_data';
import 'inference_interface.dart';
import 'classifier.dart';

class NativeClassifier implements IClassifier {
  final Classifier _c = Classifier();
  bool _loaded = false;

  @override
  Future<void> loadModel() async {
    if (!_loaded) {
      await _c.loadModel();
      _loaded = true;
    }
  }

  @override
  Future<Map<String, dynamic>> predictFromBytes(Uint8List bytes) async {
    await loadModel();
    // write to temp file and call native classifier
    final dir = Directory.systemTemp;
    final file = File(
        '${dir.path}${Platform.pathSeparator}tmp_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(bytes);
    try {
      return await _c.predict(file);
    } finally {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  @override
  void close() => _c.close();
}
