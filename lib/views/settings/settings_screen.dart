import 'package:blog_note_android/models/app_theme.dart';
import 'package:blog_note_android/viewmodels/theme_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Modo oscuro ──
          SwitchListTile(
            title: const Text('Modo oscuro'),
            secondary: Icon(
              themeVm.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            value: themeVm.isDarkMode,
            onChanged: (_) => themeVm.toggleDarkMode(),
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Color principal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          // ── Selector de tema ──
          ...AppThemeOption.values.map((theme) {
            final isSelected = themeVm.currentTheme == theme;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.seedColor,
                radius: 14,
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              title: Text(theme.label),
              trailing: isSelected
                  ? Icon(Icons.check, color: theme.seedColor)
                  : null,
              onTap: () => themeVm.setTheme(theme),
            );
          }),
        ],
      ),
    );
  }
}