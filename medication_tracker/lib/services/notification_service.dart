import 'package:medication_tracker/helpers/notification_helper.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static void scheduleMedicationReminder(
      int id,
      String title,
      String message,
      DateTime time,
      String medicationId
      ) {
    final tz.TZDateTime tzTime = tz.TZDateTime.from(time, tz.local);
    NotificationHelper.scheduleNotification(
      id,
      title,
      message,
      tzTime,
    );
  }

  static void cancelReminder(int id) {
    NotificationHelper.cancelNotification(id);
  }
}
