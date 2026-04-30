import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'login.dart';
import 'historyPage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool darkMode = false;
  bool locationAccess = true;

  String userName = "";
  String initials = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final result = await UserService.getMe();
      if (!mounted) return;

      if (result['success'] == true) {
        final user = result['user'];
        final name = user['name'] ?? '';
        final parts = name.split(' ');
        setState(() {
          userName = name;
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

  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.green,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : ListView(
              padding: const EdgeInsets.all(15),
              children: [
                // 🔹 PROFILE CARD
                Card(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(initials.isNotEmpty ? initials : "?",
                          style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(userName.isNotEmpty ? userName : "User"),
                    subtitle: const Text("Manage your account settings"),
                    trailing: const Icon(Icons.edit, color: Colors.green),
                  ),
                ),

                const SizedBox(height: 15),

                // 🔔 NOTIFICATIONS
                _buildSwitchTile(
                  icon: Icons.notifications_active,
                  title: "Notifications",
                  subtitle: "Receive app updates & alerts",
                  value: notifications,
                  onChanged: (val) {
                    setState(() => notifications = val);
                  },
                ),

                // 🌙 DARK MODE
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: "Dark Mode",
                  subtitle: "Switch app theme",
                  value: darkMode,
                  onChanged: (val) {
                    setState(() => darkMode = val);
                  },
                ),

                // 📍 LOCATION
                _buildSwitchTile(
                  icon: Icons.location_on,
                  title: "Location Access",
                  subtitle: "Allow scan-based location tracking",
                  value: locationAccess,
                  onChanged: (val) {
                    setState(() => locationAccess = val);
                  },
                ),

                const SizedBox(height: 20),

                // ACCOUNT SECTION
                const Text(
                  "Account",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                _buildMenuTile(Icons.person_outline, "Edit Profile", onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Edit Profile coming soon")),
                  );
                }),
                _buildMenuTile(Icons.lock_outline, "Change Password", onTap: _showChangePasswordDialog),
                _buildMenuTile(Icons.history, "Activity History", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage()));
                }),

                const SizedBox(height: 20),

                // SUPPORT
                const Text(
                  "Support",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                _buildMenuTile(Icons.help_outline, "Help Center", onTap: () {}),
                _buildMenuTile(Icons.info_outline, "About App", onTap: () {}),

                const SizedBox(height: 30),

                // 🔴 LOGOUT BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _logout,
                  child: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Change Password"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Current Password"),
                  ),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "New Password"),
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
                          final currentPw = currentPasswordController.text.trim();
                          final newPw = newPasswordController.text.trim();

                          if (currentPw.isEmpty || newPw.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please fill all fields")));
                            return;
                          }

                          setState(() => isSubmitting = true);

                          final result = await AuthService.changePassword(currentPw, newPw);

                          setState(() => isSubmitting = false);

                          if (result['success'] == true) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result['message']), backgroundColor: Colors.green));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Change", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // 🔹 SWITCH TILE
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        activeColor: Colors.green,
        onChanged: onChanged,
      ),
    );
  }

  // 🔹 MENU TILE
  Widget _buildMenuTile(IconData icon, String title, {VoidCallback? onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}