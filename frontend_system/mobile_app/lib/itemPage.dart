import 'package:flutter/material.dart';
import 'package:mobile_app/dashboard.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      //////////////////////////////////////////////////////
      /// CUSTOM APP BAR
      //////////////////////////////////////////////////////
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            // Using pushReplacement to go back to Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          },
        ),
        title: const Text(
          "Item List",
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      //////////////////////////////////////////////////////
      /// BODY
      //////////////////////////////////////////////////////
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // First Row: Aluminum Cans & Plastic Bottles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildItemCard(
                  "Aluminum Cans",
                  "assets/cans.webp", // Fixed extension from screenshot
                ),
                buildItemCard(
                  "Plastic Bottles",
                  "assets/water.png", // Cleaned path
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Second Row: Glass Bottle & Paper Bottle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildItemCard(
                  "Glass Bottle",
                  "assets/beer.png", // Removed leading "/"
                ),
                buildItemCard(
                  "Paper Bottle",
                  "assets/paper.webp", // Fixed extension from screenshot
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// CARD WIDGET
  //////////////////////////////////////////////////////
  Widget buildItemCard(String title, String imagePath) {
    // We use Expanded or a specific width to ensure they fit side-by-side
    return Container(
      width: MediaQuery.of(context).size.width * 0.42, // Responsive width
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF6E9B3A), // Your brand green
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForTitle(title),
            color: Colors.white,
            size: 60,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    if (title.contains("Aluminum") || title.contains("Cans")) {
      return Icons.local_drink;
    } else if (title.contains("Plastic") || title.contains("Bottle")) {
      return Icons.water_drop;
    } else if (title.contains("Glass")) {
      return Icons.wine_bar;
    } else if (title.contains("Paper")) {
      return Icons.article;
    }
    return Icons.delete;
  }
}