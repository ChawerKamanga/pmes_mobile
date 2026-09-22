import 'user.dart';

class AuthResult {
  final User? user;
  final String token;

  const AuthResult({required this.user, required this.token});
}
