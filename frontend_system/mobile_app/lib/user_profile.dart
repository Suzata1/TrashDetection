import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'qr_scanner.dart';
import 'reward.dart';
import 'historyPage.dart';  
import 'setting.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),

      body: Column(
        children: [
          // 🔥 HEADER
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 160,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),

              // AVATAR CARD
              Positioned(
                bottom: -50,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green,
                    child: Text(
                      'SP',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          // NAME + STATUS
          const Text(
            'Sujata Pokhrel',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'Eco Warrior 🌱',
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // INFO CARDS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                _buildInfoCard(Icons.phone, "Phone", "+977-98989898"),
                _buildInfoCard(Icons.email, "Email", "tester@gmail.com"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // MENU OPTIONS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                _buildMenuItem(Icons.person_outline, "Profile Details"),
                _buildMenuItem(Icons.settings_outlined, "Settings",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
                  }),
                _buildMenuItem(Icons.history, 
                "History",
                  onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => HistoryPage()));
                }),
                _buildMenuItem(Icons.logout, "Logout", isDestructive: true),
              ],
            ),
          ),
        ],
      ),

      // 🔻 BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => DashboardPage()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => QRScannerPage()));
          } else if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => RewardPage()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: ''),
        ],
      ),
    );
  }

  // 🔹 INFO CARD WIDGET
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  // 🔹 MENU ITEM WIDGET
  Widget _buildMenuItem(IconData icon, String title,
      {bool isDestructive = false
      , VoidCallback? onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon,
            color: isDestructive ? Colors.red : Colors.green),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

        onTap: onTap,
      ),
    );
  }
}