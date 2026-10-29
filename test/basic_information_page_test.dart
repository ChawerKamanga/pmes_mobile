import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pmes_mobile/core/theme/app_colors.dart';
import 'package:pmes_mobile/pages/basic_information_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('uses the Account Security app bar style', (tester) async {
    SharedPreferences.setMockInitialValues({});
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
}
