// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_scan/screens/history_screen.dart';
import 'package:qr_scan/screens/scanner_screen.dart';
import 'package:qr_scan/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // 0: Scan, 1: History, 2: Settings

  final List<Widget> _screens = [
    const ScannerScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // This boolean controls the visibility of the center scan button
    final bool showCenterButton = _currentIndex != 0;

    return Scaffold(
      extendBody: true, // Allows the body to go behind the transparent nav bar
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomAppBar(
        // Set a slightly smaller, more stable height
        height: 80,
        color: Colors.transparent,
        elevation: 0,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // --- Left and Right Floating Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(icon: Icons.history, index: 1),
                const SizedBox(width: 80), // Space for the center button
                _buildNavItem(icon: Icons.settings, index: 2),
              ],
            ),

            // --- Center Floating Action Button (Conditional) ---
            if (showCenterButton)
              Positioned(
                top: 0,
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () => setState(() => _currentIndex = 0),
                  child: const Icon(Icons.qr_code_scanner),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper widget for side navigation items
  Widget _buildNavItem({required IconData icon, required int index}) {
    final bool isSelected = _currentIndex == index;
    // We removed the Column to prevent the overflow
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
        size: 28, // Slightly larger icon for better tap area
      ),
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
