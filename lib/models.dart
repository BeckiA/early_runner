enum WorkoutType { run, jog }

enum DayStatus { locked, today, done, partial, missed }

const int kHabitDays = 21;

/// Rounds a distance to one decimal place (0.1 km steps).
double roundKm(double v) => (v * 10).round() / 10;

class DayEntry {
  final bool wokeEarly;
  final bool exercised;
  final WorkoutType type;
  final int minutes;
  final double distanceKm;

  const DayEntry({
    this.wokeEarly = false,
    this.exercised = false,
    this.type = WorkoutType.jog,
    this.minutes = 0,
    this.distanceKm = 0,
  });

  bool get isComplete => wokeEarly && exercised;
  bool get isPartial => (wokeEarly || exercised) && !isComplete;

  DayEntry copyWith({
    bool? wokeEarly,
    bool? exercised,
    WorkoutType? type,
    int? minutes,
    double? distanceKm,
  }) =>
      DayEntry(
        wokeEarly: wokeEarly ?? this.wokeEarly,
        exercised: exercised ?? this.exercised,
        type: type ?? this.type,
        minutes: minutes ?? this.minutes,
        distanceKm: distanceKm ?? this.distanceKm,
      );

  Map<String, dynamic> toJson() => {
        'wokeEarly': wokeEarly,
        'exercised': exercised,
        'type': type.name,
        'minutes': minutes,
        'distanceKm': distanceKm,
      };

  factory DayEntry.fromJson(Map<String, dynamic> json) => DayEntry(
        wokeEarly: json['wokeEarly'] as bool? ?? false,
        exercised: json['exercised'] as bool? ?? false,
        type: WorkoutType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => WorkoutType.jog,
        ),
        minutes: json['minutes'] as int? ?? 0,
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      );
}

class HabitState {
  final DateTime? startDate;
  final Map<int, DayEntry> entries; // key: day number 1..21
  final int wakeTargetMinutes; // minutes after midnight
  final bool remindersEnabled;
  final int eveningReminderMinutes; // minutes after midnight

  const HabitState({
    this.startDate,
    this.entries = const {},
    this.wakeTargetMinutes = 5 * 60 + 30, // 05:30
    this.remindersEnabled = false,
    this.eveningReminderMinutes = 20 * 60, // 20:00
  });

  DayEntry entryFor(int day) => entries[day] ?? const DayEntry();

  HabitState copyWith({
    DateTime? startDate,
    Map<int, DayEntry>? entries,
    int? wakeTargetMinutes,
    bool? remindersEnabled,
    int? eveningReminderMinutes,
  }) =>
      HabitState(
        startDate: startDate ?? this.startDate,
        entries: entries ?? this.entries,
        wakeTargetMinutes: wakeTargetMinutes ?? this.wakeTargetMinutes,
        remindersEnabled: remindersEnabled ?? this.remindersEnabled,
        eveningReminderMinutes:
            eveningReminderMinutes ?? this.eveningReminderMinutes,
      );

  Map<String, dynamic> toJson() => {
        'startDate': startDate?.toIso8601String(),
        'wakeTargetMinutes': wakeTargetMinutes,
        'remindersEnabled': remindersEnabled,
        'eveningReminderMinutes': eveningReminderMinutes,
        'entries': entries.map((k, v) => MapEntry(k.toString(), v.toJson())),
      };

  factory HabitState.fromJson(Map<String, dynamic> json) {
    final rawEntries = (json['entries'] as Map<String, dynamic>? ?? {});
    return HabitState(
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      wakeTargetMinutes: json['wakeTargetMinutes'] as int? ?? 5 * 60 + 30,
      remindersEnabled: json['remindersEnabled'] as bool? ?? false,
      eveningReminderMinutes: json['eveningReminderMinutes'] as int? ?? 20 * 60,
      entries: rawEntries.map(
        (k, v) => MapEntry(
          int.parse(k),
          DayEntry.fromJson(v as Map<String, dynamic>),
        ),
      ),
    );
  }
}
