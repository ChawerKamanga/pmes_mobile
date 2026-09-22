import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/auth_result.dart';
import '../models/user.dart';
import 'api_exception.dart';

class AuthService {
  const AuthService();

  Future<AuthResult> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    final Uri uri = Uri.parse(ApiConstants.login);

    late final http.Response response;
    try {
      response = await http.post(
        uri,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_name': deviceName,
        }),
      );
    } on SocketException {
      throw const ApiException('Unable to reach the server. Check your connection.');
    }

    final Map<String, dynamic> body =
        response.body.isEmpty ? {} : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final userJson = body['user'] as Map<String, dynamic>?;
      return AuthResult(
        user: userJson == null ? null : User.fromJson(userJson),
        token: body['token'] as String,
      );
    }

    if (response.statusCode == 422) {
      final errors = body['errors'] as Map<String, dynamic>?;
      final firstError = errors?.values.first;
      final message = firstError is List && firstError.isNotEmpty
          ? firstError.first.toString()
          : (body['message'] as String? ?? 'Invalid email or password.');
      throw ApiException(message, statusCode: 422);
    }

    throw ApiException(
      body['message'] as String? ?? 'Login failed. Please try again.',
      statusCode: response.statusCode,
    );
  }
}
