import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'notification_service.dart';

/// Overridden in main() with the real instances.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) =>
      throw UnimplementedError('notificationServiceProvider must be overridden'),
);

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class HabitNotifier extends Notifier<HabitState> {
  static const _key = 'habit_state_v1';

  @override
  HabitState build() {
    var loaded = const HabitState();
    final raw = ref.watch(sharedPrefsProvider).getString(_key);
    if (raw != null) {
      try {
        loaded = HabitState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        // Corrupt data: start fresh.
      }
    }
    // Re-schedule on launch so the reminder window always starts from today.
    Future.microtask(() => _syncReminders(loaded));
    return loaded;
  }

  void _syncReminders(HabitState s) {
    unawaited(
      ref
          .read(notificationServiceProvider)
          .syncReminders(s)
          .catchError((Object _) {}),
    );
  }

  void _set(HabitState next, {bool resync = false}) {
    state = next;
    ref.read(sharedPrefsProvider).setString(_key, jsonEncode(next.toJson()));
    if (resync) _syncReminders(next);
  }

  void startChallenge() => _set(
        state.copyWith(startDate: _dateOnly(DateTime.now()), entries: {}),
        resync: true,
      );

  void reset() {
    state = const HabitState();
    ref.read(sharedPrefsProvider).remove(_key);
    // Clears every scheduled reminder.
    _syncReminders(const HabitState());
  }

  void setWakeTarget(int minutes) =>
      _set(state.copyWith(wakeTargetMinutes: minutes), resync: true);

  void setEveningTime(int minutes) =>
      _set(state.copyWith(eveningReminderMinutes: minutes), resync: true);

  void setRemindersEnabled(bool enabled) =>
      _set(state.copyWith(remindersEnabled: enabled), resync: true);

  void updateDay(int day, DayEntry Function(DayEntry current) update) {
    final before = state.entryFor(day);
    final after = update(before);
    final next = Map<int, DayEntry>.from(state.entries)..[day] = after;
    // Only touch the scheduler when completion flips (not on slider drags).
    _set(
      state.copyWith(entries: next),
      resync: before.isComplete != after.isComplete,
    );
  }
}

final habitProvider =
    NotifierProvider<HabitNotifier, HabitState>(HabitNotifier.new);

/// Which day of the challenge today is (1-based). 0 if not started.
/// Can exceed 21 once the challenge window has passed.
final currentDayProvider = Provider<int>((ref) {
  final start = ref.watch(habitProvider.select((s) => s.startDate));
  if (start == null) return 0;
  return _dateOnly(DateTime.now()).difference(_dateOnly(start)).inDays + 1;
});

final dayStatusProvider = Provider.family<DayStatus, int>((ref, day) {
  final current = ref.watch(currentDayProvider);
  final entry = ref.watch(habitProvider.select((s) => s.entryFor(day)));
  if (day > current) return DayStatus.locked;
  if (entry.isComplete) return DayStatus.done;
  if (entry.isPartial) return DayStatus.partial;
  if (day == current) return DayStatus.today;
  return DayStatus.missed;
});

final completedCountProvider = Provider<int>((ref) {
  final entries = ref.watch(habitProvider.select((s) => s.entries));
  return List.generate(kHabitDays, (i) => i + 1)
      .where((d) => entries[d]?.isComplete ?? false)
      .length;
});

final streakProvider = Provider<int>((ref) {
  final entries = ref.watch(habitProvider.select((s) => s.entries));
  final current = ref.watch(currentDayProvider);
  if (current == 0) return 0;

  var day = current > kHabitDays ? kHabitDays : current;
  // Today still has time left, so an unfinished today doesn't break the streak.
  if (day == current && !(entries[day]?.isComplete ?? false)) day--;

  var streak = 0;
  while (day >= 1 && (entries[day]?.isComplete ?? false)) {
    streak++;
    day--;
  }
  return streak;
});

final totalMinutesProvider = Provider<int>((ref) {
  final entries = ref.watch(habitProvider.select((s) => s.entries));
  return entries.values
      .where((e) => e.exercised)
      .fold(0, (sum, e) => sum + e.minutes);
});

// ------------------------------------------------------- Distance progress

class ProgressStats {
  /// Distance per day, index 0 = Day 1. Days with nothing logged are 0.
  final List<double> perDay;
  final double first; // first logged distance
  final double latest; // most recent logged distance
  final double best;
  final double total;

  /// Average distance of logged days in weeks 1, 2 and 3 (null = no data).
  final List<double?> weeklyAvg;

  /// Average pace in minutes per km (null if no day has distance + time).
  final double? avgPace;

  const ProgressStats({
    required this.perDay,
    required this.first,
    required this.latest,
    required this.best,
    required this.total,
    required this.weeklyAvg,
    required this.avgPace,
  });

  bool get hasData => perDay.any((v) => v > 0);
  double get increase => latest - first;
  double? get increasePct => first > 0 ? increase / first * 100 : null;
}

final progressStatsProvider = Provider<ProgressStats>((ref) {
  final entries = ref.watch(habitProvider.select((s) => s.entries));
  final perDay = List<double>.generate(
    kHabitDays,
    (i) => entries[i + 1]?.distanceKm ?? 0,
  );

  final logged = [
    for (var i = 0; i < perDay.length; i++)
      if (perDay[i] > 0) perDay[i],
  ];

  final weeklyAvg = List<double?>.generate(3, (w) {
    final week = perDay.sublist(w * 7, w * 7 + 7).where((v) => v > 0).toList();
    if (week.isEmpty) return null;
    return week.reduce((a, b) => a + b) / week.length;
  });

  var paceKm = 0.0;
  var paceMin = 0;
  for (final e in entries.values) {
    if (e.distanceKm > 0 && e.minutes > 0) {
      paceKm += e.distanceKm;
      paceMin += e.minutes;
    }
  }

  return ProgressStats(
    perDay: perDay,
    first: logged.isEmpty ? 0 : logged.first,
    latest: logged.isEmpty ? 0 : logged.last,
    best: logged.isEmpty ? 0 : logged.reduce((a, b) => a > b ? a : b),
    total: logged.fold(0.0, (a, b) => a + b),
    weeklyAvg: weeklyAvg,
    avgPace: paceKm > 0 ? paceMin / paceKm : null,
  );
});
