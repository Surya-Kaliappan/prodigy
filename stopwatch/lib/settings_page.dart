import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _SettingsGroup(
            title: 'Appearance',
            children: [
              _ThemeSelector(
                title: 'Theme',
                currentValue: settings.themeMode,
                onChanged: (mode) => settings.themeMode = mode,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsGroup(
            title: 'Animation',
            children: [
              _SwitchTile(
                title: 'Dynamic Color Cycling',
                value: settings.useDynamicColors,
                onChanged: (value) => settings.useDynamicColors = value,
              ),
              AnimatedOpacity(
                opacity: settings.useDynamicColors ? 0.4 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: settings.useDynamicColors,
                  child: _ColorSelector(
                    title: 'Static Color',
                    colors: isDarkMode
                        ? settings.darkEnergyColors
                        : settings.lightEnergyColors,
                    selectedIndex: settings.staticColorIndex,
                    onSelected: (index) => settings.staticColorIndex = index,
                  ),
                ),
              ),
              const Divider(),
              _SwitchTile(
                title: 'Background Particles',
                value: settings.showParticles,
                onChanged: (value) => settings.showParticles = value,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final String title;
  final ThemeMode currentValue;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSelector({
    required this.title,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          // ## FIX: Replaced Text with Icons to prevent overflow ##
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {currentValue},
            onSelectionChanged: (selection) => onChanged(selection.first),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }
}

class _ColorSelector extends StatelessWidget {
  final String title;
  final List<Color> colors;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _ColorSelector({
    required this.title,
    required this.colors,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final color = colors[index];
                final isSelected = index == selectedIndex;
                return GestureDetector(
                  onTap: () => onSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                          )
                        : null,
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 12),
            ),
          ),
        ],
      ),
    );
  }
}
