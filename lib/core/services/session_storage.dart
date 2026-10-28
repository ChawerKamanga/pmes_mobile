import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _tokenKey = 'auth_token';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _lastLoginKey = 'last_login';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUserName(String? userName) async {
    final prefs = await SharedPreferences.getInstance();
    if (userName == null || userName.isEmpty) {
      await prefs.remove(_userNameKey);
    } else {
      await prefs.setString(_userNameKey, userName);
    }
  }

  static Future<String?> readUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<void> saveUserEmail(String? userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    if (userEmail == null || userEmail.isEmpty) {
      await prefs.remove(_userEmailKey);
    } else {
      await prefs.setString(_userEmailKey, userEmail);
    }
  }

  static Future<String?> readUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<void> saveLastLogin(DateTime? lastLogin) async {
    final prefs = await SharedPreferences.getInstance();
    if (lastLogin == null) {
      await prefs.remove(_lastLoginKey);
    } else {
      await prefs.setString(_lastLoginKey, lastLogin.toIso8601String());
    }
  }

  static Future<DateTime?> readLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastLoginKey);
    return value == null ? null : DateTime.tryParse(value);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> clearUserName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
  }

  static Future<void> clearUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
  }

  static Future<void> clearLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastLoginKey);
  }
}
