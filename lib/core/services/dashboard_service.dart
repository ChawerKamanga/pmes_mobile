import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../constants/api_constants.dart';
import '../models/dashboard_overview.dart';
import 'api_exception.dart';

class DashboardService {
  const DashboardService();

  static const Duration _timeout = Duration(seconds: 15);

  Future<DashboardOverviewResponse> getOverview({required String token}) async {
    final Uri uri = Uri.parse(ApiConstants.dashboardOverview);

    late final http.Response response;
    try {
      response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
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

    final Map<String, dynamic> body = response.body.isEmpty
        ? {}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return DashboardOverviewResponse.fromJson(body);
    }

    throw ApiException(
      body['message'] as String? ?? 'Failed to load dashboard overview.',
      statusCode: response.statusCode,
    );
  }

  Future<void> updateProjectGps({
    required String token,
    required String projectId,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    final Uri uri = Uri.parse(ApiConstants.projectGps(projectId));

    late final http.Response response;
    try {
      response = await http
          .put(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'latitude': latitude,
              'longitude': longitude,
              'accuracy': accuracy,
            }),
          )
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

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 202 ||
        response.statusCode == 204) {
      return;
    }

    final Map<String, dynamic> body = response.body.isEmpty
        ? {}
        : jsonDecode(response.body) as Map<String, dynamic>;
    throw ApiException(
      body['message'] as String? ?? 'Failed to update project GPS coordinates.',
      statusCode: response.statusCode,
    );
  }

  Future<void> uploadProjectDocument({
    required String token,
    required String projectId,
    required XFile file,
    required String name,
    required String description,
  }) async {
    if (name.length > 255 || description.length > 500) {
      throw const ApiException(
        'The progress photo details exceed the allowed length.',
      );
    }

    final int fileSize;
    try {
      fileSize = await File(file.path).length();
    } on FileSystemException {
      throw const ApiException('Unable to read the selected photo.');
    }
    if (fileSize > 5120 * 1024) {
      throw const ApiException('Each progress photo must be 5 MB or smaller.');
    }

    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse(ApiConstants.projectDocuments(projectId)),
          )
          ..headers['Accept'] = 'application/json'
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['name'] = name
          ..fields['description'] = description;
    late final http.Response response;
    try {
      request.files.add(
        await http.MultipartFile.fromPath('document_file', file.path),
      );
      final streamedResponse = await request.send().timeout(_timeout);
      response = await http.Response.fromStream(streamedResponse)
          .timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond. Please try again.',
      );
    } on SocketException {
      throw const ApiException(
        'Unable to reach the server. Check your connection.',
      );
    } on FileSystemException {
      throw const ApiException('Unable to read the selected photo.');
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      return;
    }

    final Map<String, dynamic> body;
    try {
      final decoded = response.body.isEmpty ? {} : jsonDecode(response.body);
      body = decoded is Map<String, dynamic> ? decoded : {};
    } on FormatException {
      throw ApiException(
        'Failed to upload the progress photo (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }
    final validationErrors = body['errors'];
    String? validationMessage;
    if (validationErrors is Map) {
      for (final errors in validationErrors.values) {
        if (errors is List && errors.isNotEmpty) {
          validationMessage = errors.first.toString();
          break;
        }
      }
    }
    throw ApiException(
      validationMessage ??
          body['message'] as String? ??
          'Failed to upload the progress photo.',
      statusCode: response.statusCode,
    );
  }
}
