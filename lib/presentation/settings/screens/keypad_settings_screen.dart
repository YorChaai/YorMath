import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../workout/widgets/keypad_widget.dart';

class KeypadSettingsScreen extends StatelessWidget {
  const KeypadSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Keypad', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFF0288D1),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildSegment(
                      title: 'Keypad Size',
                      options: const ['Normal', 'Large'],
                      selectedValue: settings.keypadSize,
                      onChanged: (val) => settingsProvider.setKeypadSize(val),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                    _buildSegment(
                      title: 'Keypad Type',
                      options: const ['Phone', 'Calculator'],
                      selectedValue: settings.keypadType,
                      onChanged: (val) => settingsProvider.setKeypadType(val),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        'Auto Confirm',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      activeThumbColor: const Color(0xFF0288D1),
                      value: settings.autoConfirm,
                      onChanged: (val) => settingsProvider.setAutoConfirm(val),
                    ),
                    Divider(color: isDark ? Colors.white12 : Colors.grey.shade300),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: KeypadWidget(
                  onKeyPress: (v) {},
                  onDelete: () {},
                  size: settings.keypadSize,
                  type: settings.keypadType,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegment({
    required String title,
    required List<String> options,
    required String selectedValue,
    required Function(String) onChanged,
    required bool isDark,
  }) {
    const activeColor = Color(0xFF0288D1);
    final unselectedColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.white24 : Colors.grey.shade300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: options.map((option) {
              final isSelected = option == selectedValue;
              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(option),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? activeColor.withValues(alpha: 0.2) : activeColor.withValues(alpha: 0.08))
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? activeColor : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isSelected ? activeColor : unselectedColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
