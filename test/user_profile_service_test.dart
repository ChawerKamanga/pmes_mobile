import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pmes_mobile/core/services/api_exception.dart';
import 'package:pmes_mobile/core/services/user_profile_service.dart';

void main() {
  test(
    'updates profile with the required fields and returns the user',
    () async {
      final service = UserProfileService(
        client: MockClient((request) async {
          expect(request.method, 'PUT');
          expect(request.url.path, endsWith('/api/v1/me/profile'));
          expect(request.headers['accept'], 'application/json');
          expect(request.headers['content-type'], 'application/json');
          expect(request.headers['authorization'], 'Bearer profile-token');
          expect(jsonDecode(request.body), {
            'first_name': 'Pat',
            'last_name': 'Officer',
            'email': 'pat@example.org',
            'current_password': 'current-secret',
            'password': 'new-secret',
            'password_confirmation': 'new-secret',
          });
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'user': {
                  'first_name': 'Pat',
                  'last_name': 'Officer',
                  'full_name': 'Pat Officer',
                  'email': 'pat@example.org',
                },
              },
            }),
            200,
          );
        }),
      );

      final response = await service.updateProfile(
        token: 'profile-token',
        firstName: 'Pat',
        lastName: 'Officer',
        email: 'pat@example.org',
        currentPassword: 'current-secret',
        password: 'new-secret',
        passwordConfirmation: 'new-secret',
      );

      expect(response.success, isTrue);
      expect(response.user.displayName, 'Pat Officer');
      expect(response.user.email, 'pat@example.org');
    },
  );

  test('surfaces profile validation errors', () async {
    final service = UserProfileService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'message': 'The given data was invalid.',
            'errors': {
              'current_password': ['The current password is incorrect.'],
            },
          }),
          422,
        ),
      ),
    );

    await expectLater(
      service.updateProfile(
        token: 'profile-token',
        firstName: 'Pat',
        lastName: 'Officer',
        email: 'pat@example.org',
        currentPassword: 'wrong-secret',
        password: 'new-secret',
        passwordConfirmation: 'new-secret',
      ),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 422)
            .having(
              (error) => error.message,
              'message',
              'The current password is incorrect.',
            ),
      ),
    );
  });
}
