import 'dart:io';
// import 'package:tflite_flutter/tflite_flutter.dart';  // Not available on web
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Image Detection Service using TFLite (NSFW Detection)
/// On web, provides mock detection
class DetectionService {
  dynamic _interpreter;
  bool _isInitialized = false;

  /// Initialize TFLite model
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Load model from assets (you'll need to add the model file)
      // For now, we'll simulate the detection
      // In production, load actual TFLite model:
      // final modelPath = await _loadModel();
      // _interpreter = Interpreter.fromAsset(modelPath);
      
      _isInitialized = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Detect NSFW content in image
  /// Returns: (isNsfw: bool, confidence: double)
  Future<Map<String, dynamic>> detectImage(String imagePath, {double threshold = 0.8}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      List<int> imageBytes;
      
      if (kIsWeb) {
        // On web, imagePath is a data URL or blob URL
        // For web, we need to fetch the image differently
        // For now, return a basic detection result
        print('Web detection: Analyzing image at $imagePath');
        // On web, image picker returns a path that we can't directly read
        // We'll need to handle this differently - for now return safe result
        return {
          'isNsfw': false,
          'confidence': 0.2, // Low confidence, safe by default
          'error': 'Web detection limited - image analysis not fully implemented',
        };
      } else {
        // Native platforms
        final imageFile = File(imagePath);
        if (!await imageFile.exists()) {
          return {'isNsfw': false, 'confidence': 0.0, 'error': 'Image not found'};
        }
        imageBytes = await imageFile.readAsBytes();
      }

      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        return {'isNsfw': false, 'confidence': 0.0, 'error': 'Failed to decode image'};
      }

      // Resize image to model input size (typically 224x224 or 299x299)
      final resized = img.copyResize(image, width: 224, height: 224);
      
      // Convert to float array (normalize to 0-1)
      final input = _imageToFloatList(resized);
      
      // Run inference
      // In production with actual model:
      // final output = List.filled(1, 0.0).reshape([1, 1]);
      // _interpreter!.run(input, output);
      // final confidence = output[0][0];
      
      // Simulated detection (replace with actual model inference)
      final confidence = _simulateDetection(input);
      final isNsfw = confidence >= threshold;

      return {
        'isNsfw': isNsfw,
        'confidence': confidence,
        'error': null,
      };
    } catch (e) {
      print('Detection error: $e');
      return {
        'isNsfw': false,
        'confidence': 0.0,
        'error': e.toString(),
      };
    }
  }

  /// Convert image to float list for model input
  List<List<List<List<double>>>> _imageToFloatList(img.Image image) {
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (_) => List.generate(
          224,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;
        
        input[0][y][x][0] = r;
        input[0][y][x][1] = g;
        input[0][y][x][2] = b;
      }
    }

    return input;
  }

  /// Simulate detection (replace with actual model)
  double _simulateDetection(List<List<List<List<double>>>> input) {
    // This is a placeholder - replace with actual TFLite model inference
    // For now, return a random value for testing
    return 0.3; // Simulated low confidence (not NSFW)
  }

  /// Load model from assets
  Future<String> _loadModel() async {
    // Copy model from assets to temporary directory
    final directory = await getTemporaryDirectory();
    final modelPath = '${directory.path}/nsfw_model.tflite';
    
    // In production, load from assets:
    // final data = await rootBundle.load('assets/nsfw_model.tflite');
    // final bytes = data.buffer.asUint8List();
    // await File(modelPath).writeAsBytes(bytes);
    
    return modelPath;
  }

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
