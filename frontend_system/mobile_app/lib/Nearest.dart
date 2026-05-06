import 'package:flutter/material.dart';
import 'services/location_service.dart';

class NearestPage extends StatefulWidget {
  const NearestPage({super.key});

  @override
  State<NearestPage> createState() => _NearestPageState();
}

class _NearestPageState extends State<NearestPage> {
  List<dynamic> locations = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final result = await LocationService.getLocations();
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        setState(() {
          locations = result['locations'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Failed to load locations';
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Nearest Vending Machines'),
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
                          _loadLocations();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text("Retry", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : locations.isEmpty
                  ? const Center(
                      child: Text("No locations found", style: TextStyle(color: Colors.black54)),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadLocations,
                      color: Colors.green,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          final loc = locations[index];
                          final isActive = loc['status'] == 'Active';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isActive ? Colors.green[100] : Colors.red[100],
                                child: Icon(
                                  Icons.location_on,
                                  color: isActive ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(
                                loc['vendorName'] ?? 'Unknown Vendor',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(loc['vendorAddress'] ?? 'No address'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  loc['status'] ?? 'Unknown',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
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
