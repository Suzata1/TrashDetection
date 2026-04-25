


import 'package:flutter/material.dart';

class RewardPage extends StatelessWidget {
  const RewardPage({super.key});

  // Dummy reward data (later replace with API/Firebase)
  final List<Map<String, String>> rewards = const [
    {
      "material": "Bottles",
      "co2": "100-200g CO2 reduced",
      "date": "18 Apr 2026"
    },
    {
      "material": "Plastic Bags",
      "co2": "50-100g CO2 reduced",
      "date": "17 Apr 2026"
    },
    {
      "material": "Paper",
      "co2": "30-60g CO2 reduced",
      "date": "15 Apr 2026"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text("Reward History"),
        backgroundColor: Colors.green,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: rewards.length,
        itemBuilder: (context, index) {
          final item = rewards[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.emoji_events,
                color: Colors.orange,
                size: 40,
              ),

              title: Text(
                item["material"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                item["co2"]!,
              ),

              trailing: Text(
                item["date"]!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}