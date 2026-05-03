import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  CameraController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );

      await _controller!.initialize();
      print("✅ Camera initialized, isInitialized=${_controller!.value.isInitialized}");

      if (mounted) {
        setState(() {
          _initialized = true;
        });
        print("✅ setState called, _initialized=$_initialized");
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("BUILD: _initialized=$_initialized, controller=${_controller != null}, initialized=${_controller?.value.isInitialized}");

    if (!_initialized || _controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text("Test Camera")),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 16),
              Text("Loading camera...", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    // Camera is ready - use UniqueKey to force rebuild
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Test Camera")),
      body: Container(
        color: Colors.black,
        child: Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!, key: UniqueKey()),
          ),
        ),
      ),
    );
  }
}
