import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _cellGlowColor = const Color(0x3DFFFFFF);
  double _boardSizeFactor = 0.75;

  // --- Getters ---
  ThemeMode get themeMode => _themeMode;
  Color get cellGlowColor => _cellGlowColor;
  double get boardSizeFactor => _boardSizeFactor;

  SettingsProvider() {
    _loadSettings(); // Load settings when the app starts
  }

  // --- Setters with Save Logic ---
  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  void setCellGlowColor(Color color) async {
    // We now accept the full color with its alpha value
    _cellGlowColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cellGlowColor', color.value);
  }

  void setBoardSizeFactor(double factor) async {
    _boardSizeFactor = factor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('boardSizeFactor', factor);
  }

  // --- Load Logic ---
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Load theme, default to system if not found
    _themeMode =
        ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.system.index];
    // Load color, default to a semi-transparent white
    _cellGlowColor = Color(prefs.getInt('cellGlowColor') ?? 0x3DFFFFFF);
    // Load board size, default to 75%
    _boardSizeFactor = prefs.getDouble('boardSizeFactor') ?? 0.75;
    notifyListeners();
  }
}
