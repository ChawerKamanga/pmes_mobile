import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pmes_mobile/core/services/appearance_settings_provider.dart';
import 'package:pmes_mobile/pages/appearance_settings_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders theme choices and display preferences', (tester) async {
    final settings = AppearanceSettingsProvider();
    await settings.load();

    await tester.pumpWidget(_buildPage(settings));

    expect(find.text('Appearance'), findsOneWidget);
    expect(
      find.text('Customize how PMES looks on your device.'),
      findsOneWidget,
    );
    expect(find.text('Light Theme'), findsOneWidget);
    expect(find.text('Dark Theme'), findsOneWidget);
    expect(find.text('System Default'), findsOneWidget);
    expect(find.text('Sync with system theme'), findsOneWidget);
    expect(find.text('Reduced motion'), findsOneWidget);
    expect(find.text('High contrast'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saves selected theme and display preferences', (tester) async {
    final settings = AppearanceSettingsProvider();
    await settings.load();

    await tester.pumpWidget(_buildPage(settings));
    await tester.tap(find.byKey(const ValueKey('theme-option-dark')));
    await tester.pumpAndSettle();

    expect(settings.themeMode, ThemeMode.dark);
    var preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('appearance_theme_mode'), 'dark');

    await tester.ensureVisible(find.text('Reduced motion'));
    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();

    expect(settings.reduceMotion, isTrue);
    preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('appearance_reduce_motion'), isTrue);

    await tester.ensureVisible(find.text('High contrast'));
    await tester.tap(find.byType(Switch).at(2));
    await tester.pumpAndSettle();

    expect(settings.highContrast, isTrue);
    preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('appearance_high_contrast'), isTrue);
  });
}

Widget _buildPage(AppearanceSettingsProvider settings) {
  return ChangeNotifierProvider.value(
    value: settings,
    child: MaterialApp(
      home: Scaffold(body: AppearanceSettingsPage(onBack: _ignoreBack)),
    ),
  );
}

void _ignoreBack() {}
