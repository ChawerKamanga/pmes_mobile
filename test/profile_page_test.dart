import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pmes_mobile/pages/profile_page.dart';

void main() {
  testWidgets('shows account details and unavailable statistics safely', (
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
    expect(find.text('Pending Tasks'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(4));
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

    expect(find.text('sam@example.org').last, findsOneWidget);
    expect(find.text('Sam Kamanga').last, findsOneWidget);
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
    await tester.tap(find.text('Log Out'));
    expect(logoutRequested, isTrue);
  });
}

void _ignoreLogout() {}
