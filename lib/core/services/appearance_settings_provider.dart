import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceSettingsProvider extends ChangeNotifier {
  static const _themeModeKey = 'appearance_theme_mode';
  static const _reduceMotionKey = 'appearance_reduce_motion';
  static const _highContrastKey = 'appearance_high_contrast';

  ThemeMode _themeMode = ThemeMode.system;
  bool _reduceMotion = false;
  bool _highContrast = false;
  String? _loadError;

  ThemeMode get themeMode => _themeMode;
  bool get syncWithSystem => _themeMode == ThemeMode.system;
  bool get reduceMotion => _reduceMotion;
  bool get highContrast => _highContrast;
  String? get loadError => _loadError;

  Future<void> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _themeMode = switch (preferences.getString(_themeModeKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      _reduceMotion = preferences.getBool(_reduceMotionKey) ?? false;
      _highContrast = preferences.getBool(_highContrastKey) ?? false;
      _loadError = null;
    } on Exception {
      _loadError = 'Unable to load saved appearance settings.';
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_themeModeKey, mode.name);
    if (!saved) {
      throw Exception('Unable to save the selected theme.');
    }
    _themeMode = mode;
    _loadError = null;
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setBool(_reduceMotionKey, value);
    if (!saved) {
      throw Exception('Unable to save the reduced motion preference.');
    }
    _reduceMotion = value;
    _loadError = null;
    notifyListeners();
  }

  Future<void> setHighContrast(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setBool(_highContrastKey, value);
    if (!saved) {
      throw Exception('Unable to save the high contrast preference.');
    }
    _highContrast = value;
    _loadError = null;
    notifyListeners();
  }
}
