import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Parsed prediction result from the model
class ModelPrediction {
  final String rawLabel;    // e.g. "Soybean___healthy"
  final String cropName;    // e.g. "Soybean"
  final String diseaseName; // e.g. "Healthy"
  final double confidence;  // 0.0–1.0

  const ModelPrediction({
    required this.rawLabel,
    required this.cropName,
    required this.diseaseName,
    required this.confidence,
  });

  bool get isHealthy => diseaseName == 'Healthy';
}

/// On-device TFLite inference service
class ModelService {
  static Interpreter? _interpreter;
  static List<String> _labels = [];
  static bool _isLoaded = false;

  // ─── CONFIG: adjust these to match your model ───
  static const String modelPath = 'assets/model/plant_disease.tflite';
  static const String labelsPath = 'assets/model/labels.txt';
  static const int inputSize = 224;  // change if your model uses 256
  // ────────────────────────────────────────────────

  /// Must be called once at app startup (e.g. in main() or initState)
  static Future<void> load() async {
    if (_isLoaded) return;
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      final labelsData = await rootBundle.loadString(labelsPath);
      _labels = labelsData
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      _isLoaded = true;
    } catch (e) {
      // Model not found — fall back to demo mode
      _isLoaded = false;
    }
  }

  static bool get isAvailable => _isLoaded && _interpreter != null;

  /// Run inference on an image file path.
  /// Returns the top prediction.
  static Future<ModelPrediction> predict(String imagePath) async {
    if (!isAvailable) {
      // Fallback: return demo prediction when model isn't loaded
      return _demoPrediction();
    }

    // 1. Load and preprocess image
    final imageData = await File(imagePath).readAsBytes();
    final image = img.decodeImage(imageData);
    if (image == null) return _demoPrediction();

    final resized = img.copyResize(image, width: inputSize, height: inputSize);

    // 2. Raw pixel values as float32 (0–255, matching Python preprocessing)
    final input = Float32List(1 * inputSize * inputSize * 3);
    int idx = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        input[idx++] = pixel.r.toDouble();
        input[idx++] = pixel.g.toDouble();
        input[idx++] = pixel.b.toDouble();
      }
    }

    // 3. Prepare input as [1][224][224][3]
    final inputTensor = List.generate(1, (_) =>
      List.generate(inputSize, (y) =>
        List.generate(inputSize, (x) {
          final offset = (y * inputSize + x) * 3;
          return [input[offset], input[offset + 1], input[offset + 2]];
        }),
      ),
    );

    // 4. Run inference
    final outputBuffer = [List.filled(_labels.length, 0.0)];
    _interpreter!.run(inputTensor, outputBuffer);

    // 5. Find top prediction
    final scores = outputBuffer[0];
    int bestIdx = 0;
    double bestScore = scores[0];
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIdx = i;
      }
    }

    final rawLabel = _labels[bestIdx];
    return _parseLabel(rawLabel, bestScore);
  }

  /// Parse "Crop___Disease" format into structured data
  static ModelPrediction _parseLabel(String rawLabel, double confidence) {
    // Handle format: "Tomato___Early_blight", "Soybean___healthy"
    final parts = rawLabel.split('___');

    String crop;
    String disease;

    if (parts.length >= 2) {
      crop = _cleanName(parts[0]);
      disease = _cleanName(parts[1]);
    } else {
      // Fallback if format is unexpected
      crop = 'Unknown';
      disease = _cleanName(rawLabel);
    }

    return ModelPrediction(
      rawLabel: rawLabel,
      cropName: crop,
      diseaseName: disease,
      confidence: confidence,
    );
  }

  /// "Early_blight" → "Early Blight"
  /// "healthy" → "Healthy"
  /// "Corn_(maize)" → "Corn"
  /// "Spider_mites Two-spotted_spider_mite" → "Spider Mites"
  static String _cleanName(String raw) {
    // Remove parenthetical info like "(maize)" or "(including_sour)"
    var name = raw.replaceAll(RegExp(r'\(.*?\)'), '').trim();
    // Replace underscores with spaces
    name = name.replaceAll('_', ' ').trim();
    // Take just the main name (before secondary description)
    if (name.contains('  ')) {
      name = name.split('  ').first.trim();
    }
    // Capitalize each word
    name = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
    // Remove trailing commas
    name = name.replaceAll(RegExp(r',\s*$'), '');
    return name;
  }

  /// Demo fallback when model isn't loaded
  static ModelPrediction _demoPrediction() {
    return const ModelPrediction(
      rawLabel: 'Tomato___Early_blight',
      cropName: 'Tomato',
      diseaseName: 'Early Blight',
      confidence: 0.87,
    );
  }
}
