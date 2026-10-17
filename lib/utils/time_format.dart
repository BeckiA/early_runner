import 'package:flutter/material.dart';

String formatMinutesAsTime(int minutesAfterMidnight) {
  final h = minutesAfterMidnight ~/ 60;
  final m = minutesAfterMidnight % 60;
  final period = h >= 12 ? 'PM' : 'AM';
  final hour12 = h % 12 == 0 ? 12 : h % 12;
  return '${hour12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
}

String formatTimeOfDay24ish(TimeOfDay t) {
  final period = t.period == DayPeriod.am ? 'AM' : 'PM';
  final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  return '${hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $period';
}

String formatKm(double v) => '${v.toStringAsFixed(1)} km';

String formatSignedKm(double v) =>
    '${v >= 0 ? '+' : '-'}${v.abs().toStringAsFixed(1)} km';

String formatPace(double minPerKm) {
  var m = minPerKm.floor();
  var s = ((minPerKm - m) * 60).round();
  if (s == 60) {
    m += 1;
    s = 0;
  }
  return "$m:${s.toString().padLeft(2, '0')} /km";
}

String formatShortDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}';
}

String formatWeekdayDate(DateTime d) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${days[d.weekday - 1]}, ${formatShortDate(d)}';
}
