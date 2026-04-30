import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'services/user_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<dynamic> users = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final result = await UserService.getLeaderboard();
      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          users = result['leaderboard'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Failed to load leaderboard';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Network error. Check your connection.';
        isLoading = false;
      });
    }
  }

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(errorMessage, style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = '';
                          });
                          _loadLeaderboard();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text("Retry", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : users.isEmpty
                  ? const Center(
                      child: Text("No users found", style: TextStyle(color: Colors.black54)),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadLeaderboard,
                      color: Colors.green,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          // 1. Podium Section (Top 3)
                          if (users.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (users.length > 1)
                                  _buildTopPlayer(users[1]['name'] ?? 'User', users[1]['credits'].toString(), 40, false), // 2nd Place
                                if (users.isNotEmpty)
                                  _buildTopPlayer(users[0]['name'] ?? 'User', users[0]['credits'].toString(), 55, true), // 1st Place
                                if (users.length > 2)
                                  _buildTopPlayer(users[2]['name'] ?? 'User', users[2]['credits'].toString(), 35, false), // 3rd Place
                              ],
                            ),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Divider(color: Colors.green, thickness: 1),
                          ),

                          // 2. Scrollable List Section
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: users.length > 3 ? users.length - 3 : 0,
                              itemBuilder: (context, index) {
                                final user = users[index + 3];
                                return _buildListPlayer(user['name'] ?? 'User', user['credits'].toString());
                              },
                            ),
                          ),
                        ],
                      ),
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
        SizedBox(
          width: radius * 2.5,
          child: Text(
            name,
            style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(score, style: TextStyle(color: Colors.green.shade800, fontSize: 12)),
      ],
    );
  }

  // Widget for the list items with shadows
  Widget _buildListPlayer(String name, String score) {
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
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              score,
              style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}