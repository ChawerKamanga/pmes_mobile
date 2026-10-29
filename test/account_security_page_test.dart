import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pmes_mobile/core/services/user_profile_service.dart';
import 'package:pmes_mobile/pages/account_security_page.dart';
import 'package:pmes_mobile/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final size in [const Size(320, 800), const Size(900, 1000)]) {
    testWidgets('shows account data and password form at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: AccountSecurityPage(
            userName: null,
            userEmail: 'officer@example.org',
            lastLogin: DateTime.utc(2026, 3, 5, 14, 30),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account Security'), findsOneWidget);
      expect(
        find.text('Manage your password and protect your account.'),
        findsOneWidget,
      );
      expect(find.text('Login Information'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Not provided'), findsOneWidget);
      expect(find.text('officer@example.org'), findsOneWidget);
      expect(find.text('Last Login'), findsOneWidget);
      expect(find.textContaining('March 5, 2026'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Two-Factor Authentication (2FA)'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Current Password'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm New Password'), findsOneWidget);
      expect(find.text('Update Password'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
      expect(find.text('Cancel'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Recent Login Activity'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Recent Login Activity'), findsOneWidget);
      expect(
        find.text(
          'Login history and session management are not available yet.',
        ),
        findsOneWidget,
      );
      expect(find.byType(Switch), findsNothing);

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('password visibility controls and cancel work', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final service = UserProfileService(
      client: MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, endsWith('/api/v1/me/profile'));
        expect(request.headers['authorization'], 'Bearer test-token');
        expect(jsonDecode(request.body), {
          'first_name': 'Sam',
          'last_name': 'Kamanga',
          'email': 'sam@example.org',
          'current_password': 'old-secret',
          'password': 'new-secret',
          'password_confirmation': 'new-secret',
        });
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'user': {
                'first_name': 'Sam',
                'last_name': 'Kamanga',
                'full_name': 'Sam Kamanga',
                'email': 'sam@example.org',
              },
            },
          }),
          200,
        );
      }),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: AccountSecurityPage(
          userName: 'Sam Kamanga',
          userEmail: 'sam@example.org',
          lastLogin: null,
          firstName: 'Sam',
          lastName: 'Kamanga',
          token: 'test-token',
          profileService: service,
        ),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('Current Password'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'old-secret');
    await tester.enterText(fields.at(1), 'new-secret');
    await tester.enterText(fields.at(2), 'different-secret');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match.'), findsOneWidget);

    await tester.tap(find.byTooltip('Show Current Password'));
    await tester.pumpAndSettle();
    final firstInput = find.descendant(
      of: fields.at(0),
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(firstInput).obscureText, isFalse);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    for (var index = 0; index < fields.evaluate().length; index++) {
      final field = tester.widget<TextFormField>(fields.at(index));
      expect(field.controller?.text, isEmpty);
      final input = find.descendant(
        of: fields.at(index),
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(input).obscureText, isTrue);
    }
    expect(find.text('Passwords do not match.'), findsNothing);

    await tester.enterText(fields.at(0), 'old-secret');
    await tester.enterText(fields.at(1), 'new-secret');
    await tester.enterText(fields.at(2), 'new-secret');
    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();
    expect(find.text('Your password has been updated.'), findsOneWidget);
    expect(
      find.textContaining('Password updates are unavailable'),
      findsNothing,
    );
    for (var index = 0; index < fields.evaluate().length; index++) {
      expect(
        tester.widget<TextFormField>(fields.at(index)).controller?.text,
        isEmpty,
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Account Security opens from the Profile menu', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfilePage(
            userName: 'Sam Kamanga',
            userEmail: 'sam@example.org',
            overview: null,
            onLogout: _ignoreLogout,
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Account Security'));
    await tester.tap(find.text('Account Security'));
    await tester.pumpAndSettle();

    expect(
      find.text('Manage your password and protect your account.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

void _ignoreLogout() {}
