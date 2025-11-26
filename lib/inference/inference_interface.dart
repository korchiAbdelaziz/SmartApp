import 'dart:typed_data';

abstract class IClassifier {
  /// Charge le modèle si nécessaire
  Future<void> loadModel();

  /// Prédit depuis des bytes (plateforme agnostique)
  Future<Map<String, dynamic>> predictFromBytes(Uint8List bytes);

  /// Ferme/cleanup
  void close();
}
