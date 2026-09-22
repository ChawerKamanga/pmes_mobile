/// Thrown when the API rejects a request with a user-facing error message.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
