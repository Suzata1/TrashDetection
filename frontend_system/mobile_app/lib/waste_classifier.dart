import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class WasteClassifier {
  static WasteClassifier? _instance;
  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  List<int>? _inputShape;
  List<int>? _outputShape;

  static const List<String> _labels = [
    'cardboard',
    'glass',
    'metal',
    'paper',
    'plastic',
    'trash'
  ];

  static WasteClassifier get instance {
    _instance ??= WasteClassifier._();
    return _instance!;
  }

  WasteClassifier._();

  Future<bool> loadModel(String modelPath) async {
    if (_isModelLoaded) return true;

    try {
      _interpreter = await Interpreter.fromAsset(
        modelPath,
        options: InterpreterOptions()..threads = 2,
      );
      
      _inputShape = _interpreter!.getInputTensor(0).shape;
      _outputShape = _interpreter!.getOutputTensor(0).shape;
      
      _isModelLoaded = true;
      print('✅ WasteClassifier: Model loaded successfully');
      print('   Input shape: $_inputShape');
      print('   Output shape: $_outputShape');
      return true;
    } catch (e) {
      print('❌ WasteClassifier: Failed to load model - $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      return {
        'success': false,
        'error': 'Model not loaded',
        'label': 'Unknown',
        'confidence': 0.0,
      };
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage == null) {
        return {
          'success': false,
          'error': 'Failed to decode image',
          'label': 'Unknown',
          'confidence': 0.0,
        };
      }

      final resizedImage = img.copyResize(
        decodedImage,
        width: 224,
        height: 224,
      );

      final input = _preprocessImage(resizedImage);
      final output = List<double>.filled(6, 0.0);

      _interpreter!.run(input, output);

      final maxIndex = output.indexOf(output.reduce((a, b) => a > b ? a : b));
      final confidence = output[maxIndex];
      final label = _labels[maxIndex];

      print('🎯 Classification: $label (${(confidence * 100).toStringAsFixed(1)}%)');

      return {
        'success': true,
        'label': label,
        'confidence': confidence,
        'allResults': {
          'cardboard': output[0],
          'glass': output[1],
          'metal': output[2],
          'paper': output[3],
          'plastic': output[4],
          'trash': output[5],
        },
      };
    } catch (e) {
      print('❌ WasteClassifier: Classification error - $e');
      return {
        'success': false,
        'error': e.toString(),
        'label': 'Unknown',
        'confidence': 0.0,
      };
    }
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    final input = List.generate(
      224,
      (y) => List.generate(
        224,
        (x) {
          final pixel = image.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        },
      ),
    );
    return [input];
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
  }

  bool get isModelLoaded => _isModelLoaded;
}