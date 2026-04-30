import 'package:flutter/material.dart';
import 'dashboard.dart';

class QrAfterPage extends StatefulWidget {
  final String wasteType;
  final double confidence;

  const QrAfterPage({
    super.key,
    required this.wasteType,
    required this.confidence,
  });

  @override
  State<QrAfterPage> createState() => _QrAfterPageState();
}

class _QrAfterPageState extends State<QrAfterPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _isVisible = true);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getMaterialName(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'cardboard':
        return 'Cardboard';
      case 'glass':
        return 'Glass';
      case 'metal':
        return 'Metal';
      case 'paper':
        return 'Paper';
      case 'plastic':
        return 'Plastic';
      case 'trash':
        return 'General Waste';
      default:
        return wasteType;
    }
  }

  IconData _getMaterialIcon(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'cardboard':
        return Icons.inventory_2;
      case 'glass':
        return Icons.local_drink;
      case 'metal':
        return Icons.hardware;
      case 'paper':
        return Icons.description;
      case 'plastic':
        return Icons.water_drop;
      case 'trash':
        return Icons.delete;
      default:
        return Icons.eco;
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidencePercent = (widget.confidence * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Classification Result',
          style: TextStyle(color: Colors.green),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),

          ScaleTransition(
            scale: _scaleAnimation,
            child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
          ),

          const SizedBox(height: 20),
          const Text(
            'Waste Identified!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 40),

          SlideTransition(
            position: _slideAnimation,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _isVisible ? 1.0 : 0.0,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, double val, child) => Transform.scale(scale: val, child: child),
                        child: Icon(
                          _getMaterialIcon(widget.wasteType),
                          color: Colors.green,
                          size: 100,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Material: ",
                            style: TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                          Text(
                            _getMaterialName(widget.wasteType),
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Confidence: ",
                            style: TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                          Text(
                            "$confidencePercent%",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),

                      const Text(
                        "Contribution: You helped reduce 100-200g of CO2",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(140, 50),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
                (route) => false,
              );
            },
            child: const Text(
              "Done",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 94),

          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            height: _isVisible ? 60 : 0,
            width: double.infinity,
            color: Colors.green.shade700,
            alignment: Alignment.center,
            child: Text(
              "${_getMaterialName(widget.wasteType)} recycled successfully",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
