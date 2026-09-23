import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dayMonthYear = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _dayMonth = DateFormat('dd MMM', 'id_ID');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _time = DateFormat('HH:mm', 'id_ID');

  static String formatFull(DateTime date) {
    try {
      return _dayMonthYear.format(date);
    } catch (_) {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  static String formatShort(DateTime date) {
    try {
      return _dayMonth.format(date);
    } catch (_) {
      return DateFormat('dd MMM').format(date);
    }
  }

  static String formatMonthYear(DateTime date) {
    try {
      return _monthYear.format(date);
    } catch (_) {
      return DateFormat('MMMM yyyy').format(date);
    }
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    final diffDays = today.difference(itemDate).inDays;
    if (diffDays == 0) {
      return 'Hari Ini, ${_time.format(date)}';
    } else if (diffDays == 1) {
      return 'Kemarin, ${_time.format(date)}';
    } else {
      return formatFull(date);
    }
  }
}
