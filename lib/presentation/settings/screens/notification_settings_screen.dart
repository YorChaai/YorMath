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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0288D1),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: 7,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final dayName = _days[index];
          final dayOfWeek = index + 1;
          
          final schedule = notifications.firstWhere(
            (n) => n.dayOfWeek == dayOfWeek,
            orElse: () => NotificationSchedule(dayOfWeek: dayOfWeek, hour: 12, minute: 0, isEnabled: false),
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${schedule.hour.toString().padLeft(2, '0')}:${schedule.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: schedule.isEnabled,
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
    );
  }
}
