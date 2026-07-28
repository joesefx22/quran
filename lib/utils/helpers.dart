import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd('ar').format(date);
  }

  static DateTime getWeekStart(DateTime date) {
    // عدد الأيام من السبت الماضي (بإزاحة دائرية)
    final daysSinceSaturday = (date.weekday - DateTime.saturday + 7) % 7;
    return date.subtract(Duration(days: daysSinceSaturday));
  }

  static bool isHalaqaDay(DateTime date) {
    return [DateTime.saturday, DateTime.sunday, DateTime.monday,
            DateTime.tuesday, DateTime.wednesday].contains(date.weekday);
  }
}