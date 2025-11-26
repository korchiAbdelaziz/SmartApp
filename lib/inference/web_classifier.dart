import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'inference_interface.dart';

/// Implémentation Web qui envoie l'image à une API REST pour l'inférence.
/// Configurez `serverUrl` pour pointer vers votre serveur (ex: Cloud Function, Flask API...)
class WebClassifier implements IClassifier {
  final Uri serverUrl;

  WebClassifier({required this.serverUrl});

  @override
  Future<void> loadModel() async {
    // Rien à charger côté client pour l'approche serveur
    return;
  }

  @override
  Future<Map<String, dynamic>> predictFromBytes(Uint8List bytes) async {
    final request = http.MultipartRequest('POST', serverUrl);
    request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: 'upload.jpg'));
    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode != 200) {
      throw Exception(
          'Erreur serveur: ${resp.statusCode} ${resp.reasonPhrase}');
    }
    // Le serveur doit renvoyer un JSON avec au moins {label, confidence, index}
    return Map<String, dynamic>.from(jsonDecode(resp.body) as Map);
  }

  @override
  void close() {}
}
