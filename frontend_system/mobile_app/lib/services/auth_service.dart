import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AuthService {
  // ─── LOGIN ───
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Persist the JWT token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user', jsonEncode(data['user']));
      return {'success': true, 'user': data['user'], 'message': data['message']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    }
  }

  // ─── REGISTER ───
  static Future<Map<String, dynamic>> register(
      String name, String email, String phone, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {'success': true, 'message': data['message']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Registration failed'};
    }
  }

  // ─── CHANGE PASSWORD ───
  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final headers = await authHeaders();

    final response = await http.post(
      Uri.parse(ApiConfig.changePassword),
      headers: headers,
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'message': data['message']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Failed to change password'};
    }
  }

  // ─── GET SAVED TOKEN ───
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ─── GET SAVED USER ───
  static Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr == null) return null;
    return jsonDecode(userStr);
  }

  // ─── CHECK IF LOGGED IN ───
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ─── LOGOUT ───
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // ─── HELPER: Auth headers ───
  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
