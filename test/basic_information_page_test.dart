import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pmes_mobile/core/theme/app_colors.dart';
import 'package:pmes_mobile/pages/basic_information_page.dart';

void main() {
  testWidgets('uses the Account Security app bar style', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BasicInformationPage(
          userName: 'Sam Kamanga',
          userEmail: 'sam@example.org',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, AppColors.primary);
    expect(appBar.foregroundColor, AppColors.card);
    expect(find.text('Basic Information'), findsOneWidget);
    expect(find.byTooltip('Back to Profile'), findsOneWidget);
    expect(find.byTooltip('Notifications'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows only profile details supported by the API', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BasicInformationPage(
          userName: 'Sam Kamanga',
          userEmail: 'sam@example.org',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    for (final unsupportedField in [
      'Phone Number',
      'Date of Birth',
      'Gender',
      'Nationality',
      'Country',
      'City / Town',
      'Physical address',
    ]) {
      expect(find.text(unsupportedField), findsNothing);
    }

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
    for (final unsupportedField in [
      'Phone number',
      'Date of birth',
      'Gender',
      'Nationality',
      'Country',
      'City / Town',
      'Physical address',
    ]) {
      expect(find.text(unsupportedField), findsNothing);
    }
    expect(tester.takeException(), isNull);
  });
}
