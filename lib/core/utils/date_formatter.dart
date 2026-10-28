import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _displayTimeFormat = DateFormat('hh:mm a');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _yearMonthFormat = DateFormat('yyyy-MM');

  static String toDisplayDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '--';
    try {
      final date = DateTime.parse(dateStr);
      return _displayDateFormat.format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String toDisplayTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '--:--';
    try {
      // Handles '2026-10-26 09:30:15' or '09:30:15'
      if (timeStr.contains(' ')) {
        final date = DateTime.parse(timeStr);
        return _displayTimeFormat.format(date);
      }
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final dt = DateTime(2026, 1, 1, h, m);
        return _displayTimeFormat.format(dt);
      }
      return timeStr;
    } catch (_) {
      return timeStr;
    }
  }

  static String toDisplayDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '--';
    try {
      final date = DateTime.parse(dateTimeStr);
      return '${_displayDateFormat.format(date)} ${_displayTimeFormat.format(date)}';
    } catch (_) {
      return dateTimeStr;
    }
  }

  static String formatMonthYear(int month, int year) {
    try {
      final dt = DateTime(year, month);
      return _monthYearFormat.format(dt);
    } catch (_) {
      return '$month/$year';
    }
  }

  static String currentYearMonth() {
    return _yearMonthFormat.format(DateTime.now());
  }

  static String currentDate() {
    return _dateFormat.format(DateTime.now());
  }
}
