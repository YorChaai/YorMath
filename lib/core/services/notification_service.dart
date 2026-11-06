import '../../data/models/app_settings.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // Notifications are temporarily disabled
  }

  Future<void> scheduleWeeklyNotification(NotificationSchedule schedule) async {
    // Notifications are temporarily disabled
  }

  Future<void> updateAllSchedules(List<NotificationSchedule> schedules) async {
    // Notifications are temporarily disabled
  }
}
