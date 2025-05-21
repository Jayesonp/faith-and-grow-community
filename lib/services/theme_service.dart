import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode_enabled';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeService() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
      notifyListeners();
    } catch (e) {
      // Default to light mode if there's an error
      _isDarkMode = false;
    }
  }

  Future<void> toggleTheme(bool isDarkMode) async {
    try {
      _isDarkMode = isDarkMode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, isDarkMode);
      notifyListeners();
    } catch (e) {
      // Handle errors (could add error reporting here)
    }
  }
}