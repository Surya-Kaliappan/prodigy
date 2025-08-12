import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe/models/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isWideScreen = MediaQuery.of(context).size.width > 650;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Mode Setting
          _buildSectionTitle(context, 'Theme'),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('Auto')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (newSelection) {
              settings.setThemeMode(newSelection.first);
            },
          ),
          const Divider(height: 40),

          // Color Picker Setting
          _buildSectionTitle(context, 'Cell Glow Color'),
          ListTile(
            title: const Text('Glow Color'),
            // New subtitle to inform the user
            subtitle: const Text('Tap to change color and transparency'),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: settings.cellGlowColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: settings.cellGlowColor, blurRadius: 5),
                ],
              ),
            ),
            onTap: () => _showColorPicker(context, settings),
          ),
          const Divider(height: 40),

          // Board Size Slider (only shows on wide screens)
          if (isWideScreen) ...[
            _buildSectionTitle(context, 'Board Size (Wide Screen)'),
            Slider(
              value: settings.boardSizeFactor,
              min: 0.5,
              max: 1.0,
              divisions: 5,
              label: "${(settings.boardSizeFactor * 100).toInt()}%",
              onChanged: (value) {
                settings.setBoardSizeFactor(value);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showColorPicker(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: settings.cellGlowColor,
            onColorChanged: (color) => settings.setCellGlowColor(color),
            // This enables the opacity slider
            enableAlpha: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Done'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
