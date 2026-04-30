import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

class WasteService {
  // ─── REPORT A SCAN (earn credits) ───
  static Future<Map<String, dynamic>> reportScan(
      String wasteType, double confidence) async {
    final headers = await AuthService.authHeaders();

    final response = await http.post(
      Uri.parse(ApiConfig.scanWaste),
      headers: headers,
      body: jsonEncode({
        'wasteType': wasteType,
        'confidence': confidence,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {
        'success': true,
        'message': data['message'],
        'creditsEarned': data['scan']['creditsEarned'],
        'updatedCredits': data['updatedCredits'],
      };
    } else {
      return {'success': false, 'message': data['message'] ?? 'Scan failed'};
    }
  }

  // ─── GET SCAN HISTORY ───
  static Future<Map<String, dynamic>> getHistory() async {
    final headers = await AuthService.authHeaders();

    final response = await http.get(
      Uri.parse(ApiConfig.scanHistory),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'scans': data['scans']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Failed to fetch history'};
    }
  }

  // ─── GET SCAN STATS ───
  static Future<Map<String, dynamic>> getStats() async {
    final headers = await AuthService.authHeaders();

    final response = await http.get(
      Uri.parse(ApiConfig.scanStats),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'stats': data['stats']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Failed to fetch stats'};
    }
  }
}
