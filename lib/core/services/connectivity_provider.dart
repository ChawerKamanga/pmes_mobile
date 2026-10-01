import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider({InternetConnection? connection})
    : _connection = connection ?? InternetConnection() {
    _initialize();
  }

  final InternetConnection _connection;

  StreamSubscription<InternetStatus>? _connectionSubscription;
  bool _isOnline = false;
  bool _isChecking = true;

  bool get isOnline => _isOnline;
  bool get isChecking => _isChecking;

  Future<void> _initialize() async {
    await _checkInternet();

    _connectionSubscription = _connection.onStatusChange.listen((status) {
      final nextIsOnline = status == InternetStatus.connected;
      if (_isOnline != nextIsOnline || _isChecking) {
        _isOnline = nextIsOnline;
        _isChecking = false;
        notifyListeners();
      }
    });
  }

  Future<void> refreshStatus() async {
    await _checkInternet();
  }

  Future<void> _checkInternet() async {
    _isChecking = true;
    notifyListeners();

    try {
      _isOnline = await _connection.hasInternetAccess;
    } catch (_) {
      _isOnline = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
}
