/// Central API configuration for the mobile app.
/// 
/// IMPORTANT: Change [baseUrl] to your computer's local IP when testing
/// on a physical device (e.g., 192.168.1.5).
/// For Android Emulator, use 10.0.2.2 instead.
class ApiConfig {
  // ─── Change this to your machine's IP ───
  static const String _host = '192.168.3.225';
  static const int _port = 4000;

  static const String baseUrl = 'http://$_host:$_port/api';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String changePassword = '$baseUrl/auth/change-password';

  // User endpoints
  static const String me = '$baseUrl/users/me';
  static const String leaderboard = '$baseUrl/users/leaderboard';
  static String updateUser(String id) => '$baseUrl/users/$id';

  // Waste endpoints
  static const String scanWaste = '$baseUrl/waste/scan';
  static const String scanHistory = '$baseUrl/waste/history';
  static const String scanStats = '$baseUrl/waste/stats';
}
