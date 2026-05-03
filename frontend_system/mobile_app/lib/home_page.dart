import 'package:flutter/material.dart';
import 'package:mobile_app/login.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "Trash\nDetection",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15),

              // App Name
              Text(
                "TrashDetection",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              // Tagline
              Text(
                "Return. Recycle. Reward",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              SizedBox(height: 80),

              // Welcome text
              Text(
                "WELCOME TO TRASH DETECTION APP",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 80),

              // Get Started Button
              SizedBox(
                width: 180,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to next screen (Login or Home)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Get Started",
                    style: TextStyle(fontSize: 16 , color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}