import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currentTheme = settingsProvider.settings.themeName;
    final lang = settingsProvider.settings.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0288D1),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.get(lang, 'theme'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildThemeItem(context, 'Default', 'Default (Light Blue)', currentTheme, settingsProvider, [const Color(0xFF1976D2), Colors.lightBlue, Colors.white], isDark),
              _buildThemeItem(context, 'Dark', 'Dark (Teal Dark)', currentTheme, settingsProvider, [Colors.teal, Colors.tealAccent, const Color(0xFF121212)], isDark),
              _buildThemeItem(context, 'Blue', 'Deep Blue', currentTheme, settingsProvider, [Colors.blue.shade800, Colors.blue, Colors.white], isDark),
              _buildThemeItem(context, 'Purple', 'Purple Night', currentTheme, settingsProvider, [Colors.deepPurple, Colors.purpleAccent, Colors.white], isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeItem(
    BuildContext context,
    String themeKey,
    String displayName,
    String currentTheme,
    SettingsProvider provider,
    List<Color> previewColors,
    bool isDark,
  ) {
    final isSelected = currentTheme == themeKey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Color(0xFF1976D2), width: 2)
            : BorderSide.none,
      ),
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      child: InkWell(
        onTap: () => provider.setThemeName(themeKey),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Swatches
              Row(
                mainAxisSize: MainAxisSize.min,
                children: previewColors.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF1976D2), size: 24)
              else
                Icon(Icons.radio_button_unchecked, color: isDark ? Colors.white24 : Colors.grey.shade400, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
