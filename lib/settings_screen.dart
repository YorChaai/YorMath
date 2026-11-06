import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/settings_provider.dart';
import 'data/models/app_settings.dart';
import 'presentation/custom_difficulty/screens/custom_difficulty_screen.dart';
import 'core/localization/app_localizations.dart';
import 'presentation/settings/screens/keypad_settings_screen.dart';
import 'presentation/settings/screens/notification_settings_screen.dart';
import 'presentation/settings/screens/theme_settings_screen.dart';
import 'presentation/progress/screens/progress_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    if (!provider.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    final settings = provider.settings;
    final lang = settings.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFF0288D1),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.get(lang, 'settings'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                _buildSwitchTile(AppLocalizations.get(lang, 'sounds'), settings.isSoundEnabled, (val) => provider.setSounds(val)),
                _buildDivider(),
                _buildDropdownTile(
                    AppLocalizations.get(lang, 'difficulty'),
                    settings.difficulty,
                    ['Easy', 'Medium', 'Hard', 'Challenging', 'Expert', 'Custom'],
                    (val) {
                      if (val != null) {
                        provider.setDifficulty(val);
                        if (val == 'Custom') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CustomDifficultyScreen()),
                          );
                        }
                      }
                    },
                    lang
                ),
                _buildDivider(),
                _buildQuestionsAndDurationSegment(context, settings, provider, lang),
                _buildDivider(),
                _buildLanguageTile(context, provider, lang),
                _buildDivider(),
                _buildNavigationTile(context, AppLocalizations.get(lang, 'theme'), Icons.palette_outlined, const ThemeSettingsScreen()),
                _buildNavigationTile(context, AppLocalizations.get(lang, 'notifications'), Icons.notifications_none, const NotificationSettingsScreen()),
                _buildNavigationTile(context, AppLocalizations.get(lang, 'keypad'), Icons.dialpad, const KeypadSettingsScreen()),
                _buildSwitchTile(AppLocalizations.get(lang, 'display_time'), settings.isDisplayTimeEnabled, (val) => provider.setDisplayTime(val)),
                _buildSwitchTile(AppLocalizations.get(lang, 'negative_numbers'), settings.isNegativeNumbersEnabled, (val) => provider.toggleNegativeNumbers(val)),
                _buildDivider(),
                _buildNavigationTile(context, lang == 'Indonesian' ? 'Progress Keseluruhan' : 'Overall Progress', Icons.bar_chart_rounded, const ProgressScreen()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF1976D2),
    );
  }

  Widget _buildDropdownTile(String title, String value, List<String> options, ValueChanged<String?> onChanged, String lang) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: DropdownButton<String>(
        value: options.contains(value) ? value : options.first,
        icon: const Icon(Icons.arrow_drop_down),
        underline: const SizedBox(),
        items: options.map((e) {
          // If option is a difficulty, try to translate it if possible
          String display = ['Easy', 'Medium', 'Hard', 'Challenging', 'Expert', 'Extreme', 'Custom'].contains(e) 
            ? AppLocalizations.get(lang, e.toLowerCase()) 
            : e;
          return DropdownMenuItem(value: e, child: Text(display));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, SettingsProvider provider, String currentLang) {
    return ListTile(
      title: Text(AppLocalizations.get(currentLang, 'language'), style: const TextStyle(fontSize: 16)),
      trailing: DropdownButton<String>(
        value: currentLang == 'Indonesian' ? 'Indonesian' : 'English',
        icon: const Icon(Icons.arrow_drop_down),
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'English', child: Text('English')),
          DropdownMenuItem(value: 'Indonesian', child: Text('Indonesia')),
        ],
        onChanged: (val) {
          if (val != null) {
            provider.setLanguage(val);
          }
        },
      ),
    );
  }

  Widget _buildNavigationTile(BuildContext context, String title, IconData icon, Widget targetScreen) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: Icon(icon, color: Theme.of(context).primaryColor),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen));
      },
    );
  }

  Widget _buildQuestionsAndDurationSegment(BuildContext context, AppSettings settings, SettingsProvider provider, String lang) {
    int activeQuestionValue = settings.isDurationMode ? -1 : settings.questionCount;
    int activeDurationValue = settings.isDurationMode ? settings.durationMinutes : -1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.get(lang, 'questions'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          _buildSegmentCore(
            context,
            'Questions',
            activeQuestionValue,
            settings.questionCount,
            [4, 10, 20, 40],
            (val) => provider.setQuestionsCount(val),
            lang,
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.get(lang, 'duration_minutes'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          _buildSegmentCore(
            context,
            'Duration (Minutes)',
            activeDurationValue,
            settings.durationMinutes,
            [5, 10, 15, 20],
            (val) => provider.setDurationMinutes(val),
            lang,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentCore(
    BuildContext context, 
    String title, 
    int activeValue, 
    int fallbackValue,
    List<int> standardOptions, 
    ValueChanged<int> onChanged,
    String lang
  ) {
    bool isCustomActive = activeValue != -1 && !standardOptions.contains(activeValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.white24 : Colors.grey.shade300;
    const activeColor = Color(0xFF0288D1);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ...standardOptions.map((count) {
            final isSelected = activeValue == count;
            return Expanded(
              child: InkWell(
                onTap: () => onChanged(count),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? activeColor : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isSelected ? activeColor : unselectedColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          Expanded(
            child: InkWell(
              onTap: () {
                // If it's a standard value, start with an empty field in the custom dialog
                int? dialogInitialValue = standardOptions.contains(fallbackValue) ? null : fallbackValue;
                _showCustomInputDialog(context, title, dialogInitialValue, onChanged);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isCustomActive ? activeColor : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    isCustomActive ? 'Cus ($activeValue)' : AppLocalizations.get(lang, 'custom'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isCustomActive ? activeColor : unselectedColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomInputDialog(BuildContext context, String title, int? initialValue, ValueChanged<int> onChanged) {
    final controller = TextEditingController(text: initialValue?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Custom $title', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Masukkan angka',
              border: const OutlineInputBorder(),
              suffixText: title.contains('Minutes') ? 'menit' : 'soal',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final val = int.tryParse(controller.text);
                if (val != null && val > 0) {
                  int finalVal = val;
                  // Max limit validation
                  if (title.contains('Minutes') && finalVal > 360) finalVal = 360;
                  if (title.contains('Questions') && finalVal > 1000) finalVal = 1000;
                  
                  onChanged(finalVal);
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE));
  }
}
