import 'package:flutter/foundation.dart';

import 'session_storage.dart';

class SessionProvider extends ChangeNotifier {
  String? _token;
  bool _isLoading = true;

  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  Future<void> restoreSession() async {
    _token = await SessionStorage.readToken();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String token) async {
    await SessionStorage.saveToken(token);
    _token = token;
    notifyListeners();
  }

  Future<void> signOut() async {
    await SessionStorage.clearToken();
    _token = null;
    notifyListeners();
  }
}
