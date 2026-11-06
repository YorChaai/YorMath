import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../data/models/app_settings.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  final List<String> _days = const [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final notifications = settingsProvider.settings.notifications;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
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
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: 7,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? Colors.white12 : Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final dayName = _days[index];
              final dayOfWeek = index + 1;
              
              final schedule = notifications.firstWhere(
                (n) => n.dayOfWeek == dayOfWeek,
                orElse: () => NotificationSchedule(dayOfWeek: dayOfWeek, hour: 12, minute: 0, isEnabled: false),
              );

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: schedule.hour, minute: schedule.minute),
                            );
                            if (time != null) {
                              settingsProvider.updateNotification(NotificationSchedule(
                                dayOfWeek: schedule.dayOfWeek,
                                hour: time.hour,
                                minute: time.minute,
                                isEnabled: schedule.isEnabled,
                              ));
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                              border: Border.all(
                                color: isDark ? const Color(0xFF0288D1) : const Color(0xFF1976D2),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${schedule.hour.toString().padLeft(2, '0')}:${schedule.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF80D8FF) : const Color(0xFF1976D2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: schedule.isEnabled,
                      activeThumbColor: const Color(0xFF0288D1),
                      onChanged: (val) {
                        settingsProvider.updateNotification(NotificationSchedule(
                          dayOfWeek: schedule.dayOfWeek,
                          hour: schedule.hour,
                          minute: schedule.minute,
                          isEnabled: val,
                        ));
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
