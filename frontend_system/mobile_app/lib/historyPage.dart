import 'package:flutter/material.dart';
import 'services/waste_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> scans = [];
  int totalPoints = 0;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final statsResult = await WasteService.getStats();
      final historyResult = await WasteService.getHistory();

      if (!mounted) return;

      if (historyResult['success'] == true) {
        setState(() {
          scans = historyResult['scans'] ?? [];
          if (statsResult['success'] == true) {
            totalPoints = statsResult['stats']['totalCreditsEarned'] ?? 0;
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = historyResult['message'] ?? 'Failed to load history';
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

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.toString().split(' ')[0]} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  String _capitalize(String? s) {
    if (s == null || s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1);
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

  Widget buildHistoryList() {
    return ListView.builder(
      itemCount: scans.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final item = scans[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Icon(_getWasteIcon(item['wasteType']), color: Colors.green),
                    ),
                    Container(width: 2, height: 40, color: Colors.grey[300]),
                    const Icon(Icons.check_circle, color: Colors.black),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalize(item['wasteType']),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("Confidence: ${(item['confidence'] * 100).toStringAsFixed(1)}%"),
                      Text(
                        "Time: ${_formatDateTime(item['createdAt'])}",
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "+${item['creditsEarned']} pts",
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Collection History"),
        backgroundColor: Colors.green,
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
                          _loadHistory();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text("Retry", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // POINT CARD
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events, size: 40, color: Colors.green),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Total Points", style: TextStyle(fontSize: 16)),
                              Text(
                                "$totalPoints points",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // HISTORY LIST
                    Expanded(
                      child: scans.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox, size: 60, color: Colors.grey),
                                  SizedBox(height: 10),
                                  Text(
                                    "No scanned history yet",
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadHistory,
                              color: Colors.green,
                              child: buildHistoryList(),
                            ),
                    ),
                  ],
                ),
    );
  }
}
