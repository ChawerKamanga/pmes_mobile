import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

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
      throw const ApiException('The server took too long to respond. Please try again.');
    } on SocketException {
      throw const ApiException('Unable to reach the server. Check your connection.');
    }

    final Map<String, dynamic> body =
        response.body.isEmpty ? {} : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return DashboardOverviewResponse.fromJson(body);
    }

    throw ApiException(
      body['message'] as String? ?? 'Failed to load dashboard overview.',
      statusCode: response.statusCode,
    );
  }
}
