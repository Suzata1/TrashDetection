import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class LocationService {
  // ─── GET ALL LOCATIONS ───
  static Future<Map<String, dynamic>> getLocations() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.locations),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'locations': data['locations']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to fetch locations'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }
}
