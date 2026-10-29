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
      response =
          await (client?.get(
                    Uri.parse(ApiConstants.userProfile),
                    headers: headers,
                  ) ??
                  http.get(
                    Uri.parse(ApiConstants.userProfile),
                    headers: headers,
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

  Future<UserProfileResponse> updateProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String email,
    String? currentPassword,
    String? password,
    String? passwordConfirmation,
  }) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });

    late final http.Response response;
    try {
      response =
          await (client?.put(
                    Uri.parse(ApiConstants.userProfile),
                    headers: headers,
                    body: body,
                  ) ??
                  http.put(
                    Uri.parse(ApiConstants.userProfile),
                    headers: headers,
                    body: body,
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

    final Map<String, dynamic> responseBody;
    try {
      final decoded = response.body.isEmpty ? {} : jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }
      responseBody = decoded;
    } on FormatException {
      throw ApiException(
        'The server returned an invalid profile response (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode == 200) {
      final profile = UserProfileResponse.fromJson(responseBody);
      if (!profile.success) {
        throw const ApiException('The server could not update your profile.');
      }
      return profile;
    }

    final message = response.statusCode == 422
        ? _validationMessage(responseBody)
        : responseBody['message'] as String?;
    throw ApiException(
      response.statusCode == 401
          ? 'Your session has expired. Please sign in again.'
          : message ?? 'Failed to update your profile.',
      statusCode: response.statusCode,
    );
  }

  String? _validationMessage(Map<String, dynamic> body) {
    final errors = body['errors'];
    if (errors is Map<String, dynamic>) {
      for (final error in errors.values) {
        if (error is List && error.isNotEmpty) return error.first.toString();
        if (error is String && error.isNotEmpty) return error;
      }
    }
    return body['message'] as String?;
  }
}
