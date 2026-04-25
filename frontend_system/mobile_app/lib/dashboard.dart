import 'package:flutter/material.dart';
import 'package:mobile_app/leaderBoard.dart';
import 'package:mobile_app/setting.dart%20';
import 'login.dart';
import 'qr_scanner.dart';
import 'user_profile.dart';
import 'reward.dart';
import 'itemPage.dart';
import 'historyPage.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const green = Colors.green;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: _bottomNav(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context),
              const SizedBox(height: 20),
              _greeting(),
              const SizedBox(height: 20),

              const Text(
                "Your Activity",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _earnCard(context)),
                  const SizedBox(width: 12),
                  Expanded(child: _recycleCard(context)),
                ],
              ),

              const SizedBox(height: 20),

              const Text("History",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              _historyItem(context),
              _historyItem(context),

              const SizedBox(height: 20),

              const Text("Nearest Vending Machine",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              _locationItem("Butwal"),
              _locationItem("Bhairahawa"),
              _locationItem("Chitwan"),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- TOP BAR ----------------
  Widget _topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: green),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            );
          },
        ),
        IconButton(
          icon:const Icon(Icons.settings, color: green),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            );
            // Handle notifications
          },
         ),
        
      ],
    );
  }

  // ---------------- GREETING ----------------
  Widget _greeting() {
    return const Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 18, color: Colors.black),
        children: [
          TextSpan(text: "Hi, "),
          TextSpan(
            text: "Sujata Pokhrel!\n",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: "Let’s contribute to our earth."),
        ],
      ),
    );
  }

  // ---------------- CARD 1 ----------------
  Widget _earnCard(BuildContext context) {
    return _card(
      color: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Earned",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          const Text("Rs. 12",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 12),

          _buttonWhite(
            text: "Redeem now",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LeaderboardPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------- CARD 2 ----------------
  Widget _recycleCard(BuildContext context) {
    return _card(
      color: Colors.white,
      border: true,
      child: Column(
        children: [
          const Text("Daily ReBoost",
              style: TextStyle(color: Colors.green)),
          const SizedBox(height: 4),
          const Text(
            "View recyclable items",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buttonGreen(
            text: "Recycle item",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ItemListPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------- HISTORY ----------------
  Widget _historyItem(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HistoryPage()),
        );
      },
      child: _card(
        child: Row(
          children: const [
            Icon(Icons.monetization_on, color: Colors.green),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Earned 4 Rupees"),
                Text("Feb 11, 2025",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- LOCATION ----------------
  Widget _locationItem(String name) {
    return _card(
      color: Colors.green,
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(color: Colors.white)),
              const Text("Working condition",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- CARD BASE ----------------
  Widget _card({
    required Widget child,
    Color color = Colors.white,
    bool border = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: border
            ? Border.all(color: Colors.green, width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: child,
    );
  }

  // ---------------- BUTTONS ----------------
  Widget _buttonGreen(
      {required String text, required VoidCallback onTap}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onTap,
      child: Text(text),
    );
  }

  Widget _buttonWhite(
      {required String text, required VoidCallback onTap}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onTap,
      child: Text(text),
    );
  }

  // ---------------- BOTTOM NAV ----------------
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.black,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 1:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => QRScannerPage()));
            break;
          case 2:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => UserProfilePage()));
            break;
          case 3:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => RewardPage()));
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "Scan"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: "Rewards"),
      ],
    );
  }
}