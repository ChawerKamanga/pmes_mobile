import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/user_profile.dart';
import 'api_exception.dart';

class UserProfileService {
  const UserProfileService({this.client});

  static const Duration _timeout = Duration(seconds: 15);

  final http.Client? client;

  Future<UserProfileResponse> getProfile({required String token}) async {
    late final http.Response response;
    try {
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      response = await (client?.get(
                Uri.parse(ApiConstants.userProfile),
                headers: headers,
              ) ??
              http.get(Uri.parse(ApiConstants.userProfile), headers: headers))
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
        'The server returned an invalid profile response (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode == 200) {
      final profile = UserProfileResponse.fromJson(body);
      if (!profile.success) {
        throw const ApiException('The server could not load your profile.');
      }
      return profile;
    }

    throw ApiException(
      response.statusCode == 401
          ? 'Your session has expired. Please sign in again.'
          : body['message'] as String? ?? 'Failed to load your profile.',
      statusCode: response.statusCode,
    );
  }
}
