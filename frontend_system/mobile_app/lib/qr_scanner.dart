import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // Top App Bar
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: Text(
          "QR Code Scanner",
          style: TextStyle(color: Colors.green),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Column(
        children: [
          // Camera Area
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // MobileScanner widget
                MobileScanner(
                  fit: BoxFit.cover,
                  onDetect: (BarcodeCapture? capture) {
                    if (capture == null) return;

                    for (final barcode in capture.barcodes) {
                      final String? code = barcode.displayValue;
                      if (code != null) {
                        print("QR Code: $code");
                        // You can also navigate or show dialog here
                      }
                    }
                  },
                ),

                // Dark overlay
                Container(
                  color: Colors.black.withOpacity(0.5),
                ),

                // Scan Box
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Corner borders
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
              ],
            ),
          ),

          // Bottom Text
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20),
            color: Colors.grey[200],
            child: Center(
              child: Text(
                "Scan a code",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Corner Widget
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
}