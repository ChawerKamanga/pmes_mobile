import 'package:flutter/foundation.dart';

import 'session_storage.dart';

class SessionProvider extends ChangeNotifier {
  String? _token;
  String? _userName;
  bool _isLoading = true;

  String? get token => _token;
  String? get userName => _userName;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  Future<void> restoreSession() async {
    _token = await SessionStorage.readToken();
    _userName = await SessionStorage.readUserName();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String token, {String? userName}) async {
    await SessionStorage.saveToken(token);
    await SessionStorage.saveUserName(userName);
    _token = token;
    _userName = userName;
    notifyListeners();
  }

  Future<void> signOut() async {
    await SessionStorage.clearToken();
    await SessionStorage.clearUserName();
    _token = null;
    _userName = null;
    notifyListeners();
  }
}
