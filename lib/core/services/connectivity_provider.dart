import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider({
    InternetConnection? connection,
    Connectivity? connectivity,
  }) : _connection = connection ?? InternetConnection(),
       _connectivity = connectivity ?? Connectivity() {
    _initialize();
  }

  final InternetConnection _connection;
  final Connectivity _connectivity;

  StreamSubscription<InternetStatus>? _connectionSubscription;
  StreamSubscription<List<ConnectivityResult>>? _networkSubscription;
  bool _hasNetworkTransport = false;
  bool _isOnline = false;
  bool _isChecking = true;

  bool get isOnline => _isOnline;
  bool get isChecking => _isChecking;

  void _initialize() {
    _networkSubscription = _connectivity.onConnectivityChanged.listen(
      _onNetworkChanged,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Connectivity stream failed: $error');
        _setOffline();
      },
    );
    _connectionSubscription = _connection.onStatusChange.listen(
      _onInternetStatusChanged,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Internet status stream failed: $error');
        _setOffline();
      },
    );
    unawaited(_refreshNetworkStatus());
  }

  Future<void> refreshStatus() async {
    await _refreshNetworkStatus();
  }

  Future<void> _refreshNetworkStatus() async {
    _isChecking = true;
    notifyListeners();

    try {
      final connectivity = await _connectivity.checkConnectivity();
      _hasNetworkTransport = _hasTransport(connectivity);
      if (_hasNetworkTransport) {
        _isOnline = await _connection.hasInternetAccess;
      } else {
        _isOnline = false;
      }
    } catch (error) {
      debugPrint('Unable to check network status: $error');
      _hasNetworkTransport = false;
      _isOnline = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  void _onNetworkChanged(List<ConnectivityResult> results) {
    _hasNetworkTransport = _hasTransport(results);
    if (!_hasNetworkTransport) {
      _isOnline = false;
      _isChecking = false;
      notifyListeners();
      return;
    }
    unawaited(_checkInternetAccess());
  }

  void _onInternetStatusChanged(InternetStatus status) {
    final nextIsOnline =
        _hasNetworkTransport && status == InternetStatus.connected;
    if (_isOnline != nextIsOnline || _isChecking) {
      _isOnline = nextIsOnline;
      _isChecking = false;
      notifyListeners();
    }
  }

  Future<void> _checkInternetAccess() async {
    _isChecking = true;
    notifyListeners();
    try {
      _isOnline = _hasNetworkTransport && await _connection.hasInternetAccess;
    } catch (error) {
      debugPrint('Unable to verify internet access: $error');
      _isOnline = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  bool _hasTransport(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);

  void _setOffline() {
    _hasNetworkTransport = false;
    _isOnline = false;
    _isChecking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _networkSubscription?.cancel();
    super.dispose();
  }
}
