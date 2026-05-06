import 'package:flutter/material.dart';
import 'package:mobile_app/leaderBoard.dart';
import 'package:mobile_app/setting.dart ';
import 'login.dart';
import 'qr_scanner.dart';
import 'user_profile.dart';
import 'reward.dart';
import 'itemPage.dart';
import 'historyPage.dart';
import 'Nearest.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/waste_service.dart';
import 'services/location_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const green = Colors.green;

  String userName = "User";
  int credits = 0;
  int totalScans = 0;
  int totalCo2 = 0;
  List<dynamic> recentHistory = [];
  List<dynamic> locations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Fetch user profile
      final userResult = await UserService.getMe();
      // Fetch scan stats
      final statsResult = await WasteService.getStats();
      // Fetch recent history
      final historyResult = await WasteService.getHistory();
      // Fetch locations
      final locationsResult = await LocationService.getLocations();

      if (!mounted) return;

      setState(() {
        isLoading = false;
        if (userResult['success'] == true) {
          userName = userResult['user']['name'] ?? 'User';
          credits = userResult['user']['credits'] ?? 0;
        }
        if (statsResult['success'] == true) {
          totalScans = statsResult['stats']['totalScans'] ?? 0;
          totalCo2 = statsResult['stats']['totalCo2Saved'] ?? 0;
        }
        if (historyResult['success'] == true) {
          final allScans = historyResult['scans'] as List<dynamic>? ?? [];
          recentHistory = allScans.take(2).toList();
        }
        if (locationsResult['success'] == true) {
          final allLocations = locationsResult['locations'] as List<dynamic>? ?? [];
          locations = allLocations.take(3).toList();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: _bottomNav(context),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.green))
            : RefreshIndicator(
                onRefresh: _loadUserData,
                color: Colors.green,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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

                      if (recentHistory.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              "No history yet.",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        )
                      else
                        ...recentHistory.map((item) => _historyItem(context, item)),

                      const SizedBox(height: 20),

                      const Text("Nearest Vending Machine",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      if (locations.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "No locations available currently.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      else
                        ...locations.map((loc) => _locationItem(
                              loc['vendorName'] ?? 'Unknown Vendor',
                              loc['status'] ?? 'Unknown',
                            )),
                            
                      // See All Locations Button
                      if (locations.isNotEmpty)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NearestPage()),
                              );
                            },
                            child: const Text(
                              "View All Locations",
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
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
          onPressed: () async {
            await AuthService.logout();
            if (!context.mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: green),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          },
        ),
      ],
    );
  }

  // ---------------- GREETING ----------------
  Widget _greeting() {
    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 18, color: Colors.black),
        children: [
          const TextSpan(text: "Hi, "),
          TextSpan(
            text: "$userName!\n",
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: "Let's contribute to our earth."),
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
          Text("Rs. $credits",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 12),

          _buttonWhite(
            text: "Redeem now",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RewardPage()),
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
                MaterialPageRoute(builder: (_) => const ItemListPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------- HISTORY ----------------
  Widget _historyItem(BuildContext context, dynamic item) {
    String dateStr = item['createdAt'] ?? '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      dateStr = '${date.toString().split(' ')[0]}';
    } catch (_) {}

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HistoryPage()),
        );
      },
      child: _card(
        child: Row(
          children: [
            const Icon(Icons.monetization_on, color: Colors.green),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Earned ${item['creditsEarned']} Rupees"),
                Text(dateStr,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- LOCATION ----------------
  Widget _locationItem(String name, String status) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NearestPage()),
        );
      },
      child: _card(
        color: Colors.green,
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Status: $status",
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
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
                MaterialPageRoute(builder: (_) => const QRScannerPage()));
            break;
          case 2:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const UserProfilePage()));
            break;
          case 3:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RewardPage()));
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