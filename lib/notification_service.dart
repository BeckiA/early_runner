import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'models.dart';

/// Thin wrapper around flutter_local_notifications.
///
/// Reminders are scheduled one-by-one for each remaining day of the challenge
/// (instead of a repeating daily alarm). That lets us skip tonight's check-in
/// reminder when you've already completed the day.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _morningChannel = AndroidNotificationDetails(
    'morning_reminders',
    'Morning reminders',
    channelDescription: 'Wake-up and run reminder',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _eveningChannel = AndroidNotificationDetails(
    'evening_checkin',
    'Evening check-in',
    channelDescription: 'Reminder to log your daily progress',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // Falls back to UTC if the device timezone can't be resolved.
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
    );
  }

  /// Asks the OS for notification permission. Returns true if granted.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final androidGranted = await android?.requestNotificationsPermission();
    final iosGranted =
        await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return androidGranted ?? iosGranted ?? false;
  }

  Future<void> showTest() {
    return _plugin.show(
      9999,
      'Reminders are working ✅',
      'You\'ll get a wake-up nudge and an evening check-in.',
      const NotificationDetails(
        android: _eveningChannel,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Clears everything and re-schedules reminders for the remaining days.
  Future<void> syncReminders(HabitState s) async {
    await _plugin.cancelAll();

    final start = s.startDate;
    if (start == null || !s.remindersEnabled) return;

    final now = tz.TZDateTime.now(tz.local);

    for (var day = 1; day <= kHabitDays; day++) {
      // TZDateTime normalises day overflow and is DST-safe.
      final morning = tz.TZDateTime(
        tz.local,
        start.year,
        start.month,
        start.day + day - 1,
        s.wakeTargetMinutes ~/ 60,
        s.wakeTargetMinutes % 60,
      );
      final evening = tz.TZDateTime(
        tz.local,
        start.year,
        start.month,
        start.day + day - 1,
        s.eveningReminderMinutes ~/ 60,
        s.eveningReminderMinutes % 60,
      );

      if (morning.isAfter(now)) {
        await _schedule(
          id: day,
          title: 'Rise and run 🌅',
          body: 'Day $day of $kHabitDays: time to lace up and get moving.',
          when: morning,
          details: _morningChannel,
        );
      }

      if (evening.isAfter(now) && !s.entryFor(day).isComplete) {
        await _schedule(
          id: 100 + day,
          title: 'Log your Day $day progress 📝',
          body: 'Did you wake early and run? Record your distance and time.',
          when: evening,
          details: _eveningChannel,
        );
      }
    }
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    required AndroidNotificationDetails details,
  }) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      NotificationDetails(android: details, iOS: const DarwinNotificationDetails()),
      // Inexact scheduling needs no special exact-alarm permission on Android.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
