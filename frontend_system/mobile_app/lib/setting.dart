import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool darkMode = false;
  bool locationAccess = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.green,
      ),

      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          // 🔹 PROFILE CARD
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Text("SP", style: TextStyle(color: Colors.white)),
              ),
              title: const Text("Sujata Pokhrel"),
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

          _buildMenuTile(Icons.person_outline, "Edit Profile"),
          _buildMenuTile(Icons.lock_outline, "Change Password"),
          _buildMenuTile(Icons.history, "Activity History"),

          const SizedBox(height: 20),

          // SUPPORT
          const Text(
            "Support",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          _buildMenuTile(Icons.help_outline, "Help Center"),
          _buildMenuTile(Icons.info_outline, "About App"),

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
            onPressed: () {},
            child: const Text(
              "Logout",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
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
  Widget _buildMenuTile(IconData icon, String title) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}