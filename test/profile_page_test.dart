import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pmes_mobile/core/theme/app_colors.dart';
import 'package:pmes_mobile/pages/profile_page.dart';
import 'package:pmes_mobile/core/services/user_profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('loads profile and organization details from the API', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = UserProfileService(
      client: MockClient((request) async {
        expect(request.url.path, endsWith('/api/v1/me/profile'));
        expect(request.headers['authorization'], 'Bearer profile-token');
        return httpResponse({
          'success': true,
          'data': {
            'user': {
              'id': 42,
              'first_name': 'API',
              'last_name': 'Officer',
              'full_name': 'API Officer',
              'email': 'api@example.org',
              'roles': [
                {'name': 'Field Officer', 'relations': []},
              ],
              'account_status': 'active',
              'last_login': '2026-10-28T08:30:00Z',
              'department': {
                'id': 'dept-1',
                'name': 'Field Operations',
                'code': 'FO',
                'description': 'Field projects',
                'head_of_department': {
                  'id': 3,
                  'full_name': 'Department Head',
                  'email': 'head@example.org',
                  'roles': [],
                },
                'colleagues': [
                  {
                    'id': 4,
                    'full_name': 'Team Member',
                    'email': 'team@example.org',
                    'roles': [
                      {'name': 'Coordinator', 'relations': []},
                    ],
                  },
                ],
              },
              'additional_departments': 'Planning',
            },
          },
        });
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfilePage(
            token: 'profile-token',
            userName: 'Cached Name',
            userEmail: 'cached@example.org',
            overview: null,
            onLogout: _ignoreLogout,
            profileService: service,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('API Officer'), findsOneWidget);
    expect(find.text('api@example.org'), findsOneWidget);
    expect(find.text('Field Officer • Field Operations'), findsOneWidget);

    await tester.ensureVisible(find.text('My Organization'));
    await tester.tap(find.text('My Organization'));
    await tester.pumpAndSettle();
    expect(find.text('Organization details'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Department Head'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Department Head'), findsOneWidget);
    expect(find.text('Planning'), findsOneWidget);
    await tester.tapAt(const Offset(20, 10));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Team Members'));
    await tester.tap(find.text('Team Members'));
    await tester.pumpAndSettle();
    expect(find.text('Team Member'), findsOneWidget);
    expect(find.text('team@example.org • Coordinator'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows account details safely on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfilePage(
            userName: 'A very long profile name that should wrap naturally',
            userEmail: 'officer@example.org',
            overview: null,
            onLogout: _ignoreLogout,
          ),
        ),
      ),
    );

    expect(
      find.text('A very long profile name that should wrap naturally'),
      findsOneWidget,
    );
    expect(find.text('officer@example.org'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lays out the profile on a wide screen without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    expect(tester.takeException(), isNull);
  });

  testWidgets('basic information opens with the signed-in user details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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

    await tester.ensureVisible(find.text('Basic Information'));
    await tester.tap(find.text('Basic Information'));
    await tester.pumpAndSettle();

    expect(find.text('Basic Information'), findsOneWidget);
    expect(find.text('Your personal and account details.'), findsOneWidget);
    expect(find.text('sam@example.org').last, findsOneWidget);
    expect(find.text('Sam Kamanga').last, findsOneWidget);
    expect(find.text('PERSONAL DETAILS'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('LOCATION'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('LOCATION'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('ACCOUNT SECURITY'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('ACCOUNT SECURITY'), findsOneWidget);
    expect(find.text('••••••••'), findsOneWidget);
    await tester.tap(find.text('••••••••'));
    await tester.pumpAndSettle();
    expect(find.text('Password').last, findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('edit form validates and saves updated profile details', (
    tester,
  ) async {
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

    await tester.tap(find.text('Basic Information'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final nameField = find.byType(TextFormField).first;
    await tester.enterText(nameField, '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your full name.'), findsOneWidget);

    await tester.enterText(nameField, 'Taylor Kamanga');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Taylor Kamanga').last, findsOneWidget);
    expect(
      find.text('Your personal details have been saved on this device.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('appearance menu opens the appearance settings callback', (
    tester,
  ) async {
    var appearanceOpened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfilePage(
            userName: 'Sam Kamanga',
            userEmail: 'sam@example.org',
            overview: null,
            onLogout: _ignoreLogout,
            onAppearance: () => appearanceOpened = true,
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Appearance'));
    await tester.tap(find.text('Appearance'));

    expect(appearanceOpened, isTrue);
  });

  testWidgets('profile photo control offers local photo sources', (
    tester,
  ) async {
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

    await tester.tap(find.byTooltip('Change profile photo'));
    await tester.pumpAndSettle();

    expect(find.text('Choose from gallery'), findsOneWidget);
    expect(find.text('Take a photo'), findsOneWidget);
  });

  testWidgets('logout menu delegates to the existing logout workflow', (
    tester,
  ) async {
    var logoutRequested = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfilePage(
            userName: 'Sam Kamanga',
            userEmail: 'sam@example.org',
            overview: null,
            onLogout: () => logoutRequested = true,
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Log Out'));
    final logoutTile = find.ancestor(
      of: find.text('Log Out'),
      matching: find.byType(InkWell),
    );
    expect(
      find.descendant(
        of: logoutTile,
        matching: find.byIcon(Icons.chevron_right_rounded),
      ),
      findsNothing,
    );
    expect(
      tester.widget<Text>(find.text('Log Out')).style?.color,
      AppColors.primary,
    );

    await tester.tap(find.text('Log Out'));
    expect(logoutRequested, isTrue);
  });
}

void _ignoreLogout() {}

http.Response httpResponse(Map<String, dynamic> body) =>
    http.Response(jsonEncode(body), 200);
