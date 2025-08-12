import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe/models/settings_provider.dart';
import 'package:tic_tac_toe/screens/game_screen.dart';

void main() async {
  // Make main async
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are ready
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer listens to provider changes to rebuild the MaterialApp
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // Use the themeMode from the provider
          themeMode: settings.themeMode,
          // Define the light theme
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.grey[200],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              secondary: Colors.red,
              onSecondary: Colors.white,
              surface: Colors.white, // Cell background
              onSurface: Colors.black, // Text on cells
            ),
          ),
          // Define the dark theme (our original theme)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            colorScheme: const ColorScheme.dark(
              primary: Colors.lightBlueAccent,
              onPrimary: Colors.black,
              secondary: Colors.red,
              onSecondary: Colors.white,
              surface: Color(0xFF1F1F1F), // Cell background
              onSurface: Colors.white, // Text on cells
            ),
          ),
          home: const GameScreen(),
        );
      },
    );
  }
}
