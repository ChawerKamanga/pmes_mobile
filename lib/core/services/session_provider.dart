import 'package:flutter/foundation.dart';

import 'session_storage.dart';

class SessionProvider extends ChangeNotifier {
  String? _token;
  String? _userName;
  String? _userEmail;
  bool _isLoading = true;

  String? get token => _token;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  Future<void> restoreSession() async {
    _token = await SessionStorage.readToken();
    _userName = await SessionStorage.readUserName();
    _userEmail = await SessionStorage.readUserEmail();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(
    String token, {
    String? userName,
    String? userEmail,
  }) async {
    await SessionStorage.saveToken(token);
    await SessionStorage.saveUserName(userName);
    await SessionStorage.saveUserEmail(userEmail);
    _token = token;
    _userName = userName;
    _userEmail = userEmail;
    notifyListeners();
  }

  Future<void> signOut() async {
    await SessionStorage.clearToken();
    await SessionStorage.clearUserName();
    await SessionStorage.clearUserEmail();
    _token = null;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }

  Future<void> updateUserName(String userName) async {
    await SessionStorage.saveUserName(userName);
    _userName = userName;
    notifyListeners();
  }
}
