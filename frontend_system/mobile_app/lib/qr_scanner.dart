import 'dart:io';

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

class _QRScannerPageState extends State<QRScannerPage>
    with TickerProviderStateMixin {
  CameraController? _cameraController;

  // Detection state
  String _liveLabel = "Point at waste item...";
  double _liveConfidence = 0.0;
  bool _isModelReady = false;
  bool _isProcessingFrame = false;
  bool _isStreamActive = false;

  // Capture state
  bool _isCapturing = false;
  String? _capturedLabel;
  double _capturedConfidence = 0.0;

  // Animation controllers
  late AnimationController _shutterAnimController;
  late AnimationController _pulseAnimController;
  late Animation<double> _pulseAnim;

  late Future<CameraController?> _cameraFuture;

  @override
  void initState() {
    super.initState();

    _shutterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _pulseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseAnimController, curve: Curves.easeInOut),
    );

    _cameraFuture = _initCamera();
  }

  Future<CameraController?> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return null;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      print("✅ Camera initialized");

      // Load model after camera is ready
      _loadModel();
      return _cameraController;
    } catch (e) {
      print("❌ Camera init error: $e");
      return null;
    }
  }

  Future<void> _loadModel() async {
    try {
      final classifier = WasteClassifier.instance;
      if (!classifier.isModelLoaded) {
        await classifier.loadModel('assets/waste_model.tflite');
        print("✅ Model loaded");
      }
      if (!mounted) return;
      setState(() {
        _isModelReady = true;
      });

      _startImageStream();
    } catch (e) {
      print("❌ Model error: $e");
      if (mounted) {
        setState(() {
          _liveLabel = "Model failed to load";
        });
      }
    }
  }

  void _startImageStream() {
    if (_isStreamActive || _cameraController == null) return;
    _isStreamActive = true;

    _cameraController!.startImageStream((CameraImage image) {
      if (!_isProcessingFrame && _isModelReady && mounted && !_isCapturing) {
        _processCameraImage(image);
      }
    });
    print("🎥 Image stream started");
  }

  Future<void> _processCameraImage(CameraImage image) async {
    _isProcessingFrame = true;
    try {
      img.Image? converted = convertCameraImage(image);
      if (converted != null) {
        // Camera on most Android phones is rotated 90 degrees
        converted = img.copyRotate(converted, angle: 90);
        final result =
            await WasteClassifier.instance.classifyRawImage(converted);
        if (result['success'] == true && mounted && !_isCapturing) {
          setState(() {
            _liveLabel = result['label'];
            _liveConfidence = result['confidence'];
          });
        }
      }
    } catch (e) {
      print("Process error: $e");
    } finally {
      // Throttle: wait before processing next frame
      await Future.delayed(const Duration(milliseconds: 400));
      _isProcessingFrame = false;
    }
  }

  /// Capture the current detection result with a shutter animation,
  /// then navigate to the results page.
  Future<void> _onCapture() async {
    if (_isCapturing) return;
    if (_liveLabel == "Point at waste item..." || _liveConfidence <= 0) {
      // Nothing detected yet – show a brief snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No waste detected yet. Keep the camera steady."),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCapturing = true;
      _capturedLabel = _liveLabel;
      _capturedConfidence = _liveConfidence;
    });

    // Shutter flash animation
    await _shutterAnimController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _shutterAnimController.reverse();

    // Stop the image stream
    try {
      await _cameraController?.stopImageStream();
      _isStreamActive = false;
    } catch (_) {}

    // Small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    // Navigate to the results page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QrAfterPage(
          wasteType: _capturedLabel!,
          confidence: _capturedConfidence,
        ),
      ),
    );
  }


  @override
  void dispose() {
    _shutterAnimController.dispose();
    _pulseAnimController.dispose();
    try {
      if (_isStreamActive) {
        _cameraController?.stopImageStream().catchError((_) {});
      }
    } catch (_) {}
    _cameraController?.dispose();
    super.dispose();
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return Colors.green;
    if (confidence >= 0.4) return Colors.orange;
    return Colors.red;
  }

  String _getConfidenceLabel(double confidence) {
    if (confidence >= 0.7) return "High";
    if (confidence >= 0.4) return "Medium";
    return "Low";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<CameraController?>(
        future: _cameraFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text("Starting camera...",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            );
          }

          if (snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam_off,
                      color: Colors.white54, size: 60),
                  const SizedBox(height: 16),
                  const Text("Camera not available",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Go Back",
                        style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
            );
          }

          // Camera is ready — build the scanner UI
          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Camera preview (full screen) ──
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              ),

              // ── Semi-transparent overlay ──
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.15)),
              ),

              // ── Top bar (safe area) ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            "Live Waste Scanner",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Model status indicator
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isModelReady
                                ? Colors.green.withValues(alpha: 0.8)
                                : Colors.orange.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isModelReady
                                    ? Icons.check_circle
                                    : Icons.hourglass_top,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isModelReady ? "Ready" : "Loading...",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Scan target box with animated border ──
              Center(
                child: ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _liveConfidence >= 0.5
                            ? Colors.green
                            : Colors.white.withValues(alpha: 0.7),
                        width: _liveConfidence >= 0.5 ? 3 : 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Corner accents
                        ..._buildCornerAccents(),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Detection result label ──
              Positioned(
                bottom: 200,
                left: 20,
                right: 20,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _liveConfidence > 0
                            ? _getConfidenceColor(_liveConfidence)
                                .withValues(alpha: 0.5)
                            : Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _liveConfidence > 0
                              ? _liveLabel.toUpperCase()
                              : _liveLabel,
                          style: TextStyle(
                            color: _liveConfidence > 0
                                ? Colors.white
                                : Colors.white70,
                            fontSize: _liveConfidence > 0 ? 20 : 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (_liveConfidence > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Confidence bar
                              Container(
                                width: 100,
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Colors.white24,
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _liveConfidence.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: _getConfidenceColor(
                                          _liveConfidence),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${(_liveConfidence * 100).toStringAsFixed(1)}%",
                                style: TextStyle(
                                  color:
                                      _getConfidenceColor(_liveConfidence),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getConfidenceColor(_liveConfidence)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getConfidenceLabel(_liveConfidence),
                                  style: TextStyle(
                                    color: _getConfidenceColor(
                                        _liveConfidence),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // ── Bottom controls ──
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Instruction text
                      Text(
                        _liveConfidence >= 0.5
                            ? "Waste detected! Tap capture to confirm."
                            : "Point camera at waste item",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Capture button row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Gallery / placeholder
                          const SizedBox(width: 56),

                          // ── CAPTURE BUTTON ──
                          GestureDetector(
                            onTap: _isModelReady && !_isCapturing
                                ? _onCapture
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isModelReady
                                      ? Colors.white
                                      : Colors.white38,
                                  width: 4,
                                ),
                              ),
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: _isCapturing ? 30 : 62,
                                  height: _isCapturing ? 30 : 62,
                                  decoration: BoxDecoration(
                                    shape: _isCapturing
                                        ? BoxShape.rectangle
                                        : BoxShape.circle,
                                    borderRadius: _isCapturing
                                        ? BorderRadius.circular(8)
                                        : null,
                                    color: _isModelReady
                                        ? (_liveConfidence >= 0.5
                                            ? Colors.green
                                            : Colors.white)
                                        : Colors.white38,
                                  ),
                                  child: _isCapturing
                                      ? const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : (_liveConfidence >= 0.5
                                          ? const Icon(Icons.camera_alt,
                                              color: Colors.white, size: 28)
                                          : null),
                                ),
                              ),
                            ),
                          ),

                          // Retry button (only visible when capture failed / want to re-scan)
                          const SizedBox(width: 56),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Shutter flash overlay ──
              AnimatedBuilder(
                animation: _shutterAnimController,
                builder: (context, child) {
                  return IgnorePointer(
                    child: Container(
                      color: Colors.white
                          .withValues(alpha: _shutterAnimController.value * 0.7),
                    ),
                  );
                },
              ),

              // ── Model loading overlay ──
              if (!_isModelReady)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.green),
                          SizedBox(height: 16),
                          Text(
                            "Loading AI model...",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Build corner accent decorations for the scan box
  List<Widget> _buildCornerAccents() {
    const double size = 24;
    const double thickness = 3;
    final color =
        _liveConfidence >= 0.5 ? Colors.green : Colors.white.withValues(alpha: 0.8);

    return [
      // Top-left
      Positioned(
        top: 0,
        left: 0,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CornerPainter(color, thickness, 0)),
        ),
      ),
      // Top-right
      Positioned(
        top: 0,
        right: 0,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CornerPainter(color, thickness, 1)),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: 0,
        left: 0,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CornerPainter(color, thickness, 2)),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: 0,
        right: 0,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CornerPainter(color, thickness, 3)),
        ),
      ),
    ];
  }
}

/// Custom painter for scan-box corner accents
class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final int corner; // 0=TL, 1=TR, 2=BL, 3=BR

  _CornerPainter(this.color, this.thickness, this.corner);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    switch (corner) {
      case 0: // Top-left
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        break;
      case 1: // Top-right
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case 2: // Bottom-left
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case 3: // Bottom-right
        path.moveTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, 0);
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      color != oldDelegate.color;
}
