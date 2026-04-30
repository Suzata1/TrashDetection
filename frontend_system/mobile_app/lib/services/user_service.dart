import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

class UserService {
  // ─── GET CURRENT USER PROFILE ───
  static Future<Map<String, dynamic>> getMe() async {
    final headers = await AuthService.authHeaders();

    final response = await http.get(
      Uri.parse(ApiConfig.me),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'user': data['user']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Failed to fetch profile'};
    }
  }

  // ─── UPDATE USER PROFILE ───
  static Future<Map<String, dynamic>> updateProfile(
      String userId, Map<String, dynamic> updates) async {
    final headers = await AuthService.authHeaders();

    final response = await http.put(
      Uri.parse(ApiConfig.updateUser(userId)),
      headers: headers,
      body: jsonEncode(updates),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'user': data['user'], 'message': data['message']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Update failed'};
    }
  }

  // ─── GET LEADERBOARD ───
  static Future<Map<String, dynamic>> getLeaderboard() async {
    final headers = await AuthService.authHeaders();

    final response = await http.get(
      Uri.parse(ApiConfig.leaderboard),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'leaderboard': data['leaderboard']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Failed to fetch leaderboard'};
    }
  }
}
