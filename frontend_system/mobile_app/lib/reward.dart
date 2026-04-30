import 'package:flutter/material.dart';
import 'services/waste_service.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  List<dynamic> scans = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final result = await WasteService.getHistory();

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          scans = result['scans'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Failed to load history';
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  IconData _getWasteIcon(String? wasteType) {
    switch (wasteType?.toLowerCase()) {
      case 'cardboard':
        return Icons.inventory_2;
      case 'glass':
        return Icons.local_drink;
      case 'metal':
        return Icons.hardware;
      case 'paper':
        return Icons.description;
      case 'plastic':
        return Icons.water_drop;
      case 'trash':
        return Icons.delete;
      default:
        return Icons.eco;
    }
  }

  String _capitalize(String? s) {
    if (s == null || s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text("Reward History"),
        backgroundColor: Colors.green,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(errorMessage,
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = '';
                          });
                          _loadHistory();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text("Retry",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : scans.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emoji_events_outlined,
                              color: Colors.grey, size: 64),
                          SizedBox(height: 12),
                          Text("No scans yet. Start recycling!",
                              style: TextStyle(color: Colors.black54, fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      color: Colors.green,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: scans.length,
                        itemBuilder: (context, index) {
                          final scan = scans[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Icon(
                                _getWasteIcon(scan['wasteType']),
                                color: Colors.green,
                                size: 40,
                              ),
                              title: Text(
                                _capitalize(scan['wasteType']),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "+Rs. ${scan['creditsEarned']} • ${scan['co2Saved']}g CO2 saved",
                              ),
                              trailing: Text(
                                _formatDate(scan['createdAt']),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}