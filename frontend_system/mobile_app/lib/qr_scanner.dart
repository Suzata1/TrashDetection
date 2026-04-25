import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'waste_classifier.dart';
import 'afterQr.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text(
          "Scan Waste",
          style: TextStyle(color: Colors.green),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Stack(
        children: [
          MobileScanner(
            fit: BoxFit.cover,
            onDetect: (BarcodeCapture? capture) {
              if (capture == null) return;

              for (final barcode in capture.barcodes) {
                final String? code = barcode.displayValue;
                if (code != null) {
                  print("QR Code: $code");
                }
              }
            },
          ),

          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Positioned(
            child: buildCorner(),
            top: 150,
            left: 50,
          ),
          Positioned(
            child: buildCorner(isTop: true, isLeft: false),
            top: 150,
            right: 50,
          ),
          Positioned(
            child: buildCorner(isTop: false, isLeft: true),
            bottom: 150,
            left: 50,
          ),
          Positioned(
            child: buildCorner(isTop: false, isLeft: false),
            bottom: 150,
            right: 50,
          ),

          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.green),
                    SizedBox(height: 16),
                    Text(
                      "Analyzing waste...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _captureAndClassify,
        backgroundColor: _isProcessing ? Colors.grey : Colors.green,
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text(
          "Capture & Classify",
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        color: Colors.grey[200],
        child: const Center(
          child: Text(
            "Point camera at waste item and tap capture",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget buildCorner({bool isTop = true, bool isLeft = true}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          left: isLeft ? BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          right: !isLeft ? BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: Colors.white, width: 4) : BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _captureAndClassify() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      print("📷 Image captured: ${image.path}");

      final classifier = WasteClassifier.instance;

      if (!classifier.isModelLoaded) {
        final loaded = await classifier.loadModel('assets/waste_model.tflite');
        if (!loaded) {
          _showError('Failed to load model');
          return;
        }
      }

      final result = await classifier.classifyImage(File(image.path));

      if (result['success'] == true) {
        final label = result['label'] as String;
        final confidence = result['confidence'] as double;

        print("✅ Classification: $label (${(confidence * 100).toStringAsFixed(1)}%)");

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QrAfterPage(
                wasteType: label,
                confidence: confidence,
              ),
            ),
          );
        }
      } else {
        _showError(result['error'] ?? 'Classification failed');
      }
    } catch (e) {
      print("❌ Error: $e");
      _showError('Failed to process image');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    setState(() {
      _isProcessing = false;
    });
  }
}