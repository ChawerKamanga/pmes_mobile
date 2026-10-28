import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pmes_mobile/core/theme/app_colors.dart';
import 'package:pmes_mobile/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
