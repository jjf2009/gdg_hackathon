import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Service for leaf disease segmentation using leafidf.tflite.
/// Produces a binary mask highlighting affected areas on a leaf image.
class SegmentationService {
  static SegmentationService? _instance;
  static SegmentationService get instance => _instance ??= SegmentationService._();
  SegmentationService._();

  Interpreter? _interpreter;
  bool _isLoaded = false;
  int _inputHeight = 256;
  int _inputWidth = 256;
  int _outputHeight = 256;
  int _outputWidth = 256;
  int _outputChannels = 1;

  bool get isAvailable => _isLoaded && _interpreter != null;

  /// Load the segmentation model and inspect tensor shapes.
  Future<void> load() async {
    if (_isLoaded) return;
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/leafidf.tflite');

      // Inspect input shape
      final inputTensor = _interpreter!.getInputTensor(0);
      final inputShape = inputTensor.shape; // e.g. [1, 256, 256, 3]
      debugPrint('[Segmentation] Input shape: $inputShape dtype: ${inputTensor.type}');
      if (inputShape.length == 4) {
        _inputHeight = inputShape[1];
        _inputWidth = inputShape[2];
      }

      // Inspect output shape
      final outputTensor = _interpreter!.getOutputTensor(0);
      final outputShape = outputTensor.shape; // e.g. [1, 256, 256, 1]
      debugPrint('[Segmentation] Output shape: $outputShape dtype: ${outputTensor.type}');
      if (outputShape.length == 4) {
        _outputHeight = outputShape[1];
        _outputWidth = outputShape[2];
        _outputChannels = outputShape[3];
      }

      _isLoaded = true;
      debugPrint('[Segmentation] Model loaded successfully. Input: ${_inputWidth}x$_inputHeight, Output: ${_outputWidth}x$_outputHeight x $_outputChannels');
    } catch (e) {
      debugPrint('[Segmentation] Failed to load model: $e');
      _isLoaded = false;
    }
  }

  /// Run segmentation on an image file.
  /// Returns a mask as an img.Image (grayscale, same size as output tensor).
  /// Pixel value 255 = affected, 0 = healthy.
  Future<SegmentationResult?> segment(String imagePath) async {
    if (!isAvailable) return null;

    try {
      // Load and decode the image
      final imageBytes = await File(imagePath).readAsBytes();
      final original = img.decodeImage(imageBytes);
      if (original == null) return null;

      // Resize to model input size
      final resized = img.copyResize(original, width: _inputWidth, height: _inputHeight);

      // Prepare input tensor [1, H, W, 3] normalized to 0.0–1.0
      final input = List.generate(1, (_) =>
        List.generate(_inputHeight, (y) =>
          List.generate(_inputWidth, (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r.toDouble() / 255.0,
              pixel.g.toDouble() / 255.0,
              pixel.b.toDouble() / 255.0,
            ];
          }),
        ),
      );

      // Prepare output buffer
      final output = List.generate(1, (_) =>
        List.generate(_outputHeight, (_) =>
          List.generate(_outputWidth, (_) =>
            List.filled(_outputChannels, 0.0),
          ),
        ),
      );

      // Run inference
      _interpreter!.run(input, output);

      // Convert output to binary mask image
      final maskImage = img.Image(width: _outputWidth, height: _outputHeight);
      int affectedPixels = 0;
      final totalPixels = _outputWidth * _outputHeight;

      for (int y = 0; y < _outputHeight; y++) {
        for (int x = 0; x < _outputWidth; x++) {
          double value;
          if (_outputChannels == 1) {
            value = output[0][y][x][0];
          } else {
            // Multi-channel: take argmax or use channel 1 as "disease" probability
            value = output[0][y][x][1]; // channel 1 = disease class
          }

          // Apply sigmoid if output is logit (unbounded), skip if already 0–1
          if (value < -10 || value > 10) {
            value = 1.0 / (1.0 + math.exp(-value));
          }

          final isMasked = value > 0.5;
          if (isMasked) affectedPixels++;

          // Red overlay for affected areas
          if (isMasked) {
            maskImage.setPixelRgba(x, y, 220, 38, 38, 160); // semi-transparent red
          } else {
            maskImage.setPixelRgba(x, y, 0, 0, 0, 0); // fully transparent
          }
        }
      }

      final affectedPct = (affectedPixels / totalPixels * 100).clamp(0.0, 100.0);

      debugPrint('[Segmentation] Done. Affected: ${affectedPct.toStringAsFixed(1)}%');

      return SegmentationResult(
        maskImage: maskImage,
        affectedPercentage: affectedPct,
        originalWidth: original.width,
        originalHeight: original.height,
      );
    } catch (e) {
      debugPrint('[Segmentation] Inference error: $e');
      return null;
    }
  }

  /// Convert img.Image mask to PNG bytes for display.
  static Future<Uint8List> maskToPng(img.Image mask) async {
    return Uint8List.fromList(img.encodePng(mask));
  }
}

/// Result of segmentation inference.
class SegmentationResult {
  final img.Image maskImage;
  final double affectedPercentage;
  final int originalWidth;
  final int originalHeight;

  const SegmentationResult({
    required this.maskImage,
    required this.affectedPercentage,
    required this.originalWidth,
    required this.originalHeight,
  });
}

