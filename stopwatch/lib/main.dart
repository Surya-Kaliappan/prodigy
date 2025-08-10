import 'package:flutter/material.dart';
import 'stopwatch_page.dart';

// --- MAIN APP INITIALIZATION ---
void main() {
  runApp(const StopwatchApp());
}

// --- THEME DEFINITIONS ---
final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
    primary: Colors.blue.shade600,
    surface: Colors.grey.shade100,
    surfaceVariant: Colors.white,
    onSurfaceVariant: Colors.grey.shade800,
  ),
  useMaterial3: true,
);

final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.dark,
    primary: Colors.teal.shade300,
    surface: const Color(0xFF121212),
    surfaceVariant: const Color(0xFF1E1E1E),
    onSurfaceVariant: Colors.grey.shade400,
  ),
  useMaterial3: true,
);

// --- ROOT APP WIDGET ---
class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: const StopwatchPage(),
    );
  }
}
