/// API base URL and endpoint constants.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://6f90-105-234-177-7.ngrok-free.app/api/v1';

  static const String login = '$baseUrl/login';

  static const String logout = '$baseUrl/logout';

  static const String dashboardOverview = '$baseUrl/dashboard/overview';

  static String projectGps(String projectId) => '$baseUrl/projects/$projectId/gps';
}
