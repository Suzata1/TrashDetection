import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'qr_scanner.dart';
import 'reward.dart';
import 'historyPage.dart';
import 'setting.dart';
import 'login.dart';
import 'services/user_service.dart';
import 'services/auth_service.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String name = "";
  String email = "";
  String phone = "";
  int credits = 0;
  String initials = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final result = await UserService.getMe();

      if (!mounted) return;

      if (result['success'] == true) {
        final user = result['user'];
        setState(() {
          name = user['name'] ?? '';
          email = user['email'] ?? '';
          phone = user['phone'] ?? '';
          credits = user['credits'] ?? 0;
          // Generate initials from name
          final parts = name.split(' ');
          initials = parts.map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

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

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
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
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.green,
                          child: Text(
                            initials.isNotEmpty ? initials : '?',
                            style: const TextStyle(
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
                Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  'Credits: Rs. $credits  🌱',
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // INFO CARDS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      _buildInfoCard(Icons.phone, "Phone", phone.isNotEmpty ? phone : "Not set"),
                      _buildInfoCard(Icons.email, "Email", email),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // MENU OPTIONS
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    children: [
                      _buildMenuItem(Icons.person_outline, "Profile Details", onTap: () {
                        _showEditProfileDialog();
                      }),
                      _buildMenuItem(Icons.settings_outlined, "Settings",
                          onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const SettingsPage()));
                      }),
                      _buildMenuItem(Icons.history, "History", onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => HistoryPage()));
                      }),
                      _buildMenuItem(Icons.logout, "Logout",
                          isDestructive: true, onTap: () async {
                        await AuthService.logout();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      }),
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
                MaterialPageRoute(builder: (_) => const DashboardPage()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const QRScannerPage()));
          } else if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RewardPage()));
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

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Profile"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "Phone Number"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final newName = nameController.text.trim();
                          final newPhone = phoneController.text.trim();

                          if (newName.isEmpty || newPhone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please fill all fields")));
                            return;
                          }

                          setState(() => isSubmitting = true);

                          // Since the user is identified by JWT, we need the user ID. 
                          // Or we can just hit a generic update profile endpoint.
                          // Wait, the API Config has updateUser(String id). 
                          // Let's check how we can get the ID.
                          // UserService.getMe() returns the user with the 'id' field in the 'user' object or we can fetch it again.
                          // Let's see if we have the ID. If not, let's fetch getMe() and then update.
                          
                          final userResult = await UserService.getMe();
                          if (userResult['success'] == true) {
                            final userId = userResult['user']['_id'] ?? userResult['user']['id'];
                            
                            final result = await UserService.updateProfile(userId, {
                              'name': newName,
                              'phone': newPhone,
                            });

                            if (result['success'] == true) {
                              if (!mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Profile updated successfully"), backgroundColor: Colors.green));
                              _loadProfile();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result['message'] ?? 'Update failed'), backgroundColor: Colors.red));
                            }
                          }

                          setState(() => isSubmitting = false);
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
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
      {bool isDestructive = false, VoidCallback? onTap}) {
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