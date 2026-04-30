import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'waste_classifier.dart';
import 'afterQr.dart';
import 'camera_image_converter.dart';
import 'package:image/image.dart' as img;

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isProcessingFrame = false;

  String _liveLabel = "Scanning...";
  double _liveConfidence = 0.0;
  bool _isCameraInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle — dispose camera when backgrounded
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = "No cameras found on this device.");
        return;
      }

      print("📷 Found ${cameras.length} cameras. Using: ${cameras.first.name}");

      // Load TFLite model
      final classifier = WasteClassifier.instance;
      if (!classifier.isModelLoaded) {
        final loaded = await classifier.loadModel('assets/waste_model.tflite');
        print("🧠 Model loaded: $loaded");
        if (!loaded) {
          setState(() => _errorMessage = "Failed to load waste classification model.");
          return;
        }
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      print("✅ Camera initialized successfully");

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _errorMessage = null;
        });

        // Start live frame processing
        await _cameraController!.startImageStream((CameraImage image) {
          if (!_isProcessingFrame) {
            _processCameraImage(image);
          }
        });
        print("🎥 Image stream started");
      }
    } catch (e) {
      print("❌ Camera init error: $e");
      setState(() {
        _errorMessage = "Camera error: $e";
      });
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessingFrame || !mounted) return;

    _isProcessingFrame = true;

    try {
      img.Image? convertedImage = convertCameraImage(image);

      if (convertedImage != null) {
        convertedImage = img.copyRotate(convertedImage, angle: 90);

        final result =
            await WasteClassifier.instance.classifyRawImage(convertedImage);

        if (result['success'] == true && mounted) {
          setState(() {
            _liveLabel = result['label'];
            _liveConfidence = result['confidence'];
          });
        }
      }
    } catch (e) {
      print("Live processing error: $e");
    } finally {
      // Throttle: wait 500ms before processing the next frame
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _isProcessingFrame = false;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.stopImageStream().catchError((_) {});
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text(
          "Live Waste Scanner",
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
          // Live Camera Preview
          if (_isCameraInitialized && _cameraController != null)
            SizedBox.expand(
              child: CameraPreview(_cameraController!),
            )
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                          _isCameraInitialized = false;
                        });
                        _initializeCamera();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("Retry", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
          else
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    "Starting camera...",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

          // Semi-transparent overlay
          if (_isCameraInitialized)
            Container(color: Colors.black.withOpacity(0.2)),

          // Scan box
          if (_isCameraInitialized)
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

          // Live classification label
          if (_isCameraInitialized)
            Positioned(
              bottom: 140,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _liveConfidence > 0
                        ? "$_liveLabel (${(_liveConfidence * 100).toStringAsFixed(1)}%)"
                        : _liveLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      // Confirm button — Always active for testing
      floatingActionButton: _isCameraInitialized
          ? FloatingActionButton.extended(
              onPressed: _confirmClassification,
              backgroundColor: Colors.green,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                "Capture & Confirm",
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,

      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        color: Colors.grey[200],
        child: const Center(
          child: Text(
            "Point camera at waste item and confirm",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ),
    );
  }

  void _confirmClassification() {
    _cameraController?.stopImageStream().catchError((_) {});
    
    // Provide a fallback label if the model hasn't predicted anything yet
    String labelToPass = _liveLabel;
    double confidenceToPass = _liveConfidence;
    
    if (labelToPass == "Scanning..." || confidenceToPass == 0) {
      labelToPass = "Plastic"; // Fallback dummy data for testing
      confidenceToPass = 0.85;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QrAfterPage(
          wasteType: labelToPass,
          confidence: confidenceToPass,
        ),
      ),
    );
  }
}