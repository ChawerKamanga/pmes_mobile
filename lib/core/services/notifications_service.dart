import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/notification.dart';
import 'api_exception.dart';

class NotificationsService {
  const NotificationsService({this.client});

  static const Duration _timeout = Duration(seconds: 15);

  final http.Client? client;

  Future<NotificationsResponse> getNotifications({
    required String token,
    int page = 1,
  }) async {
    final uri = Uri.parse(ApiConstants.notifications)
        .replace(queryParameters: {'page': '$page'});
    late final http.Response response;
    try {
      response =
          await (client?.get(
                    uri,
                    headers: {
                      'Accept': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                  ) ??
                  http.get(
                    uri,
                    headers: {
                      'Accept': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                  ))
              .timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond. Please try again.',
      );
    } on SocketException {
      throw const ApiException(
        'Unable to reach the server. Check your connection.',
      );
    }

    final Map<String, dynamic> body;
    try {
      final decoded = response.body.isEmpty ? {} : jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }
      body = decoded;
    } on FormatException {
      throw ApiException(
        'The server returned an invalid notifications response (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode == 200) {
      try {
        return NotificationsResponse.fromJson(body);
      } on FormatException {
        throw const ApiException(
          'The server returned an invalid notifications response.',
        );
      }
    }

    throw ApiException(
      response.statusCode == 401
          ? 'Your session has expired. Please sign in again.'
          : body['message'] as String? ?? 'Failed to load notifications.',
      statusCode: response.statusCode,
    );
  }
}
