import 'package:flutter/material.dart';
import 'dashboard.dart';
class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.green),
    onPressed: () {
      Navigator.pop(context);
    },
  ),
                title: const Text('Realtime Leaderboard', 
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          // 1. Podium Section (Top 3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTopPlayer('Shyam', '8', 40, false), // 2nd Place
              _buildTopPlayer('Kiran Dhungana', '16', 55, true), // 1st Place
              _buildTopPlayer('Trilok', '4', 35, false), // 3rd Place
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Divider(color: Colors.green, thickness: 1),
          ),

          // 2. Scrollable List Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildListPlayer('Hari'),
                _buildListPlayer('Shyam'),
                _buildListPlayer('Milan'),
                _buildListPlayer('Bijay'),
                _buildListPlayer('Dinesh'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for the circular top 3 players
  Widget _buildTopPlayer(String name, String score, double radius, bool isWinner) {
    return Column(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.green.withOpacity(0.2),
          child: Icon(Icons.person, size: radius, color: Colors.green.shade700),
        ),
        const SizedBox(height: 8),
        if (isWinner) const Icon(Icons.emoji_events, color: Colors.orange, size: 20),
        Text(name, 
          style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        Text(score, style: TextStyle(color: Colors.green.shade800, fontSize: 12)),
      ],
    );
  }

  // Widget for the list items with shadows
  Widget _buildListPlayer(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.2),
              child: const Icon(Icons.person, color: Colors.green),
            ),
            const SizedBox(width: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}