import 'package:flutter/material.dart';
import 'dart:async';
import 'services/auth_service.dart';
import 'home_page.dart';
import 'dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.5, end: 1.2).animate(_controller);

    _controller.forward();

    // Check login status after splash animation
    Timer(const Duration(seconds: 3), () async {
      final isLoggedIn = await AuthService.isLoggedIn();

      if (!mounted) return;

      if (isLoggedIn) {
        // User has a saved token — go straight to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        // No token — show the welcome / login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: FadeTransition(
        opacity: _controller,
        child: ScaleTransition(
          scale: _animation,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
