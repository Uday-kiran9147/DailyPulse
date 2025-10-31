import 'package:dailyplus/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {

  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme =>
      _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;

  SharedPreferences? _prefs;

  /// Initialize theme mode from shared preferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool('isDarkMode') ?? true;
    notifyListeners();
  }

  /// Toggles theme mode and persists the preference
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _saveThemePreference();
  }

  /// Save theme preference locally
  Future<void> _saveThemePreference() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool('isDarkMode', _isDarkMode);
  }
}
