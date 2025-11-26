import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../inference/inference_interface.dart';
import '../inference/native_classifier.dart';
import '../inference/web_classifier.dart';

class ClassifierPage extends StatefulWidget {
  const ClassifierPage({super.key});

  @override
  State<ClassifierPage> createState() => _ClassifierPageState();
}

class _ClassifierPageState extends State<ClassifierPage> {
  IClassifier? _classifier;
  File? _imageFile;
  Uint8List? _webImageBytes;
  String? _label;
  double? _confidence;
  bool _busy = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024);
    if (picked == null) return;
    setState(() {
      _busy = true;
      _label = null;
      _confidence = null;
    });

    // Initialize classifier implementation lazily
    _classifier ??= kIsWeb
        ? WebClassifier(serverUrl: Uri.parse('http://localhost:5000/predict'))
        : NativeClassifier();

    if (kIsWeb) {
      try {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _imageFile = null;
        });
        final res = await _classifier!.predictFromBytes(bytes);
        setState(() {
          _label = res['label'] as String?;
          _confidence = (res['confidence'] as num?)?.toDouble();
        });
      } catch (e) {
        setState(() {
          _label = 'Erreur: ${e.toString()}';
        });
      } finally {
        setState(() => _busy = false);
      }
      return;
    }

    // Native platforms (Android/iOS/desktop)
    setState(() {
      _imageFile = File(picked.path);
    });

    try {
      final bytes = await _imageFile!.readAsBytes();
      final res = await _classifier!.predictFromBytes(bytes);
      setState(() {
        _label = res['label'] as String?;
        _confidence = (res['confidence'] as num?)?.toDouble();
      });
    } catch (e) {
      setState(() {
        _label = 'Erreur: ${e.toString()}';
      });
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _classifier?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Classifier de Fruits'),
          backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: _imageFile == null && _webImageBytes == null
                    ? const Text('Aucune image sélectionnée')
                    : (kIsWeb
                        ? Image.memory(_webImageBytes!)
                        : Image.file(_imageFile!)),
              ),
            ),
            if (_busy) const CircularProgressIndicator(),
            const SizedBox(height: 12),
            if (_label != null)
              Text(
                  'Résultat: $_label\nConfiance: ${(_confidence ?? 0).toStringAsFixed(3)}',
                  textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text('Galerie'),
                ),
                ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Caméra'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
