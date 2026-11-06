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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keypad', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0288D1),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
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
                ),
                const SizedBox(height: 16),
                _buildSegment(
                  title: 'Keypad Type',
                  options: const ['Phone', 'Calculator'],
                  selectedValue: settings.keypadType,
                  onChanged: (val) => settingsProvider.setKeypadType(val),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto Confirm'),
                  value: settings.autoConfirm,
                  onChanged: (val) => settingsProvider.setAutoConfirm(val),
                ),
                const Divider(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: KeypadWidget(
              onKeyPress: (v) {},
              onDelete: () {},
              // pass new params if we add them to KeypadWidget
              size: settings.keypadSize,
              type: settings.keypadType,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required String title,
    required List<String> options,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: options.map((option) {
              final isSelected = option == selectedValue;
              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(option),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue : Colors.black87,
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
