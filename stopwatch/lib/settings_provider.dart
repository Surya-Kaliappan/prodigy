import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  bool _useDynamicColors = true;
  int _staticColorIndex = 0;
  bool _showParticles = true;

  // Accessible color list for the light theme
  final List<Color> lightEnergyColors = const [
    Color(0xFF007BFF), // Strong Blue
    Color(0xFFE64A19), // Deep Orange
    Color(0xFF28A745), // Strong Green
    Color(0xFF6F42C1), // Vibrant Purple
    Color(0xFFD81B60), // Hot Pink
    Color(0xFF00ACC1), // Bright Cyan
  ];

  // Vibrant color list for the dark theme
  final List<Color> darkEnergyColors = const [
    Color(0xFF40E0D0), // Turquoise
    Color(0xFFFFD700), // Gold
    Color(0xFFADFF2F), // GreenYellow
    Color(0xFFFF69B4), // HotPink
    Color(0xFF00BFFF), // DeepSkyBlue
    Color(0xFFFF4500), // OrangeRed
  ];

  SettingsProvider() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  bool get useDynamicColors => _useDynamicColors;
  int get staticColorIndex => _staticColorIndex;
  bool get showParticles => _showParticles;

  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveSettings();
    notifyListeners();
  }

  set useDynamicColors(bool value) {
    _useDynamicColors = value;
    _saveSettings();
    notifyListeners();
  }

  set staticColorIndex(int index) {
    _staticColorIndex = index;
    _saveSettings();
    notifyListeners();
  }

  set showParticles(bool value) {
    _showParticles = value;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadSettings() async {
    await _initPrefs();
    _themeMode =
        ThemeMode.values[_prefs?.getInt('themeMode') ?? ThemeMode.system.index];
    _useDynamicColors = _prefs?.getBool('useDynamicColors') ?? true;
    _staticColorIndex = _prefs?.getInt('staticColorIndex') ?? 0;
    _showParticles = _prefs?.getBool('showParticles') ?? true;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    await _initPrefs();
    _prefs?.setInt('themeMode', _themeMode.index);
    _prefs?.setBool('useDynamicColors', _useDynamicColors);
    _prefs?.setInt('staticColorIndex', _staticColorIndex);
    _prefs?.setBool('showParticles', _showParticles);
  }
}
