import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/field_progress_log.dart';
import '../repositories/field_log_repository.dart';

class SyncUploadException implements Exception {
  const SyncUploadException(
    this.message, {
    this.statusCode,
    this.isTransient = false,
  });

  final String message;
  final int? statusCode;
  final bool isTransient;

  @override
  String toString() => message;
}

class SyncService extends ChangeNotifier {
  SyncService({required this.repository, http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  static const Duration _requestTimeout = Duration(seconds: 30);

  final FieldLogRepository repository;
  final http.Client _client;
  final bool _ownsClient;

  bool _isOnline = false;
  bool _isSyncing = false;
  bool _syncAgainRequested = false;
  String? _token;
  String? _currentLocalId;
  String? _lastError;
  int _completedCount = 0;
  int _failedCount = 0;
  int _totalCount = 0;

  bool get isSyncing => _isSyncing;
  String? get currentLocalId => _currentLocalId;
  String? get lastError => _lastError;
  int get completedCount => _completedCount;
  int get failedCount => _failedCount;
  int get totalCount => _totalCount;

  void updateDependencies({required bool isOnline, required String? token}) {
    final shouldStartSync =
        isOnline &&
        token != null &&
        token.isNotEmpty &&
        (!_isOnline || token != _token);
    _isOnline = isOnline;
    _token = token;
    if (shouldStartSync) {
      if (_isSyncing) {
        _syncAgainRequested = true;
      } else {
        scheduleMicrotask(() => syncPending());
      }
    }
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;
    if (!_isOnline) {
      _lastError = 'Cannot sync while offline.';
      notifyListeners();
      return;
    }
    final token = _token;
    if (token == null || token.isEmpty) {
      _lastError = 'Sign in before syncing field updates.';
      notifyListeners();
      return;
    }

    _isSyncing = true;
    _lastError = null;
    _currentLocalId = null;
    _completedCount = 0;
    _failedCount = 0;
    _totalCount = 0;
    notifyListeners();

    try {
      final pendingLogs = await repository.getPendingFieldLogs();
      _totalCount = pendingLogs.length;
      notifyListeners();

      for (final log in pendingLogs) {
        if (!_isOnline) {
          _lastError = 'Connection lost. Remaining records are still queued.';
          break;
        }
        if (_token != token) {
          _lastError = 'Your session changed. Sign in again before syncing remaining records.';
          break;
        }
        _currentLocalId = log.localId;
        notifyListeners();

        try {
          await repository.recordFieldLogSyncAttempt(log.localId);
          await _uploadFieldLog(log, token);
          await repository.markFieldLogSynced(log.localId);
          _completedCount++;
        } on Object catch (error) {
          final message = _errorMessage(error);
          _failedCount++;
          try {
            await repository.recordFieldLogSyncFailure(log.localId, message);
          } on Object catch (storageError) {
            _lastError =
                '$message Local error could not be saved: ${_errorMessage(storageError)}';
            debugPrint(
              'Unable to save sync failure for ${log.localId}: $storageError',
            );
            break;
          }
          _lastError = message;
          if (error is SyncUploadException && error.isTransient) break;
        }
        notifyListeners();
      }
    } on Object catch (error) {
      _lastError =
          'Unable to read the pending sync queue: ${_errorMessage(error)}';
      debugPrint('Unable to read pending field updates: $error');
    } finally {
      _currentLocalId = null;
      _isSyncing = false;
      final retryRequested =
          _syncAgainRequested && _isOnline && _token?.isNotEmpty == true;
      _syncAgainRequested = false;
      notifyListeners();
      if (retryRequested) {
        scheduleMicrotask(() => syncPending());
      }
    }
  }

  Future<void> _uploadFieldLog(FieldProgressLog log, String token) async {
    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(ApiConstants.fieldUpdatesSync),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'Idempotency-Key': log.localId,
            },
            body: jsonEncode({
              'local_id': log.localId,
              'project_id': log.projectId,
              'kpis_met': log.kpisMet,
              'notes': log.notes,
              'gps_lat': log.gpsLatitude,
              'gps_lng': log.gpsLongitude,
              'timestamp': log.timestamp.toUtc().toIso8601String(),
            }),
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw const SyncUploadException(
        'The server took too long to respond. The record will retry.',
        isTransient: true,
      );
    } on SocketException {
      throw const SyncUploadException(
        'Unable to reach the server. The record will retry.',
        isTransient: true,
      );
    } on http.ClientException {
      throw const SyncUploadException(
        'Unable to reach the server. The record will retry.',
        isTransient: true,
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) return;

    final message = _responseMessage(response);
    throw SyncUploadException(
      message,
      statusCode: response.statusCode,
      isTransient:
          response.statusCode == 408 ||
          response.statusCode == 429 ||
          response.statusCode >= 500,
    );
  }

  String _responseMessage(http.Response response) {
    if (response.body.isEmpty) {
      return 'Upload failed (HTTP ${response.statusCode}).';
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } on FormatException {
      return 'Upload failed (HTTP ${response.statusCode}).';
    }
    return 'Upload failed (HTTP ${response.statusCode}).';
  }

  String _errorMessage(Object error) => error.toString();

  @override
  void dispose() {
    if (_ownsClient) _client.close();
    super.dispose();
  }
}
