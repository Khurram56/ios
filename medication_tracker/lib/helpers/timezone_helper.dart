import 'package:timezone/data/latest.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;

class TimezoneHelper {
  static void initializeTimezone() {
    tzData.initializeTimeZones();
  }

  static tz.TZDateTime convertToTZ(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}
