import 'package:blog_note_android/data/local/preferences_dao.dart';
import 'package:blog_note_android/models/app_theme.dart';
import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  final PreferencesDao _dao;
  AppThemeOption _currentTheme = AppThemeOption.indigo;
  bool _isDarkMode = false;
  bool _isLoaded = false;

  AppThemeOption get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;
  bool get isLoaded => _isLoaded;

  ThemeViewModel(this._dao);

  ThemeData get themeData => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _currentTheme.seedColor,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    ),
    useMaterial3: true,
  );

  Future<void> init() async {
    final themeName = await _dao.getString('theme') ?? 'indigo';
    final darkMode = await _dao.getString('dark_mode') ?? 'false';
    _isDarkMode = darkMode == 'true';
    _currentTheme = AppThemeOption.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => AppThemeOption.indigo,
    );
    notifyListeners();
  }

  Future<void> setTheme(AppThemeOption theme) async {
    _currentTheme = theme;
    await _dao.setString('theme', theme.name);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _dao.setString('dark_mode', _isDarkMode.toString());
    notifyListeners();
  }
}
