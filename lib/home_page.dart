import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';
import 'progress_page.dart';
import 'providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final started = ref.watch(habitProvider.select((s) => s.startDate != null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('21-Day Early Runner'),
        actions: [
          if (started)
            IconButton(
              tooltip: 'Restart challenge',
              icon: const Icon(Icons.restart_alt),
              onPressed: () => _confirmReset(context, ref),
            ),
        ],
      ),
      body: SafeArea(
        child: started ? const _Dashboard() : const _StartView(),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restart challenge?'),
        content: const Text('All your progress will be erased.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Restart')),
        ],
      ),
    );
    if (ok == true) ref.read(habitProvider.notifier).reset();
  }
}

// ---------------------------------------------------------------- Start view

class _StartView extends ConsumerWidget {
  const _StartView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_run, size: 96, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text('Rise early. Run daily.',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              '21 days of waking up early and moving your body. '
              'Check in each day, build your streak, and make it stick.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => ref.read(habitProvider.notifier).startChallenge(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start today'),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- Dashboard

class _Dashboard extends ConsumerWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(completedCountProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SummaryCard(),
        const SizedBox(height: 12),
        const _WakeTargetTile(),
        const SizedBox(height: 12),
        const _ReminderCard(),
        const SizedBox(height: 12),
        const _ProgressCard(),
        const SizedBox(height: 20),
        Text('Your 21 days', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Tap a day to check in.',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [for (var d = 1; d <= kHabitDays; d++) _DayCell(day: d)],
        ),
        const SizedBox(height: 16),
        const _Legend(),
        if (completed == kHabitDays) ...[
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '🎉 21 out of 21! You did it. The habit is yours now.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final completed = ref.watch(completedCountProvider);
    final streak = ref.watch(streakProvider);
    final minutes = ref.watch(totalMinutesProvider);
    final distance = ref.watch(progressStatsProvider.select((s) => s.total));
    final current = ref.watch(currentDayProvider);
    final dayLabel = current > kHabitDays ? 'Done' : '$current / $kHabitDays';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: completed / kHabitDays,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text('$completed/$kHabitDays',
                      style: theme.textTheme.titleLarge),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Stat(icon: Icons.today, label: 'Day', value: dayLabel),
                  const SizedBox(height: 8),
                  _Stat(
                      icon: Icons.local_fire_department,
                      label: 'Streak',
                      value: '$streak day${streak == 1 ? '' : 's'}'),
                  const SizedBox(height: 8),
                  _Stat(
                      icon: Icons.timer_outlined,
                      label: 'Active',
                      value: '$minutes min'),
                  const SizedBox(height: 8),
                  _Stat(
                      icon: Icons.route,
                      label: 'Distance',
                      value: '${distance.toStringAsFixed(1)} km'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _WakeTargetTile extends ConsumerWidget {
  const _WakeTargetTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minutes = ref.watch(habitProvider.select((s) => s.wakeTargetMinutes));
    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.alarm),
        title: const Text('Wake-up target'),
        subtitle: Text(time.format(context)),
        trailing: const Icon(Icons.edit_outlined),
        onTap: () async {
          final picked =
              await showTimePicker(context: context, initialTime: time);
          if (picked != null) {
            ref
                .read(habitProvider.notifier)
                .setWakeTarget(picked.hour * 60 + picked.minute);
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------- Day cells

Color _statusColor(BuildContext context, DayStatus s) {
  final cs = Theme.of(context).colorScheme;
  switch (s) {
    case DayStatus.done:
      return Colors.green;
    case DayStatus.partial:
      return Colors.amber;
    case DayStatus.missed:
      return cs.errorContainer;
    case DayStatus.today:
      return cs.primaryContainer;
    case DayStatus.locked:
      return cs.surfaceContainerHighest;
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell({required this.day});
  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(dayStatusProvider(day));
    final cs = Theme.of(context).colorScheme;
    final locked = status == DayStatus.locked;
    final onFilled = status == DayStatus.done ? Colors.white : cs.onSurface;

    return Material(
      color: _statusColor(context, status),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: locked
            ? null
            : () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => _DaySheet(day: day),
                ),
        child: Container(
          decoration: status == DayStatus.today
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.primary, width: 2),
                )
              : null,
          alignment: Alignment.center,
          child: status == DayStatus.done
              ? const Icon(Icons.check, color: Colors.white)
              : Text(
                  '$day',
                  style: TextStyle(
                    color: locked ? cs.onSurfaceVariant.withOpacity(0.5) : onFilled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget item(DayStatus s, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _statusColor(context, s),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        );

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        item(DayStatus.done, 'Both done'),
        item(DayStatus.partial, 'One done'),
        item(DayStatus.missed, 'Missed'),
        item(DayStatus.today, 'Today'),
      ],
    );
  }
}

// ---------------------------------------------------------- Check-in sheet

class _DaySheet extends ConsumerWidget {
  const _DaySheet({required this.day});
  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(habitProvider.select((s) => s.entryFor(day)));
    final start = ref.watch(habitProvider.select((s) => s.startDate))!;
    final wakeMinutes =
        ref.watch(habitProvider.select((s) => s.wakeTargetMinutes));
    final date = start.add(Duration(days: day - 1));
    final notifier = ref.read(habitProvider.notifier);
    final wakeTime =
        TimeOfDay(hour: wakeMinutes ~/ 60, minute: wakeMinutes % 60)
            .format(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 0, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Day $day',
              style: Theme.of(context).textTheme.headlineSmall),
          Text('${date.day}/${date.month}/${date.year}',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Woke up early'),
            subtitle: Text('Target: $wakeTime'),
            value: entry.wokeEarly,
            onChanged: (v) =>
                notifier.updateDay(day, (e) => e.copyWith(wokeEarly: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Completed workout'),
            value: entry.exercised,
            onChanged: (v) =>
                notifier.updateDay(day, (e) => e.copyWith(exercised: v)),
          ),
          const SizedBox(height: 8),
          SegmentedButton<WorkoutType>(
            segments: const [
              ButtonSegment(
                  value: WorkoutType.jog,
                  icon: Icon(Icons.directions_walk),
                  label: Text('Jog')),
              ButtonSegment(
                  value: WorkoutType.run,
                  icon: Icon(Icons.directions_run),
                  label: Text('Run')),
            ],
            selected: {entry.type},
            onSelectionChanged: (s) =>
                notifier.updateDay(day, (e) => e.copyWith(type: s.first)),
          ),
          const SizedBox(height: 16),
          Text('Duration: ${entry.minutes} min'),
          Slider(
            value: entry.minutes.toDouble(),
            min: 0,
            max: 120,
            divisions: 24,
            label: '${entry.minutes} min',
            onChanged: (v) =>
                notifier.updateDay(day, (e) => e.copyWith(minutes: v.round())),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Distance'),
              const Spacer(),
              IconButton(
                tooltip: '-0.1 km',
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: entry.distanceKm <= 0
                    ? null
                    : () => notifier.updateDay(
                          day,
                          (e) => e.copyWith(
                              distanceKm: roundKm(
                                  (e.distanceKm - 0.1).clamp(0.0, 20.0).toDouble())),
                        ),
              ),
              Text('${entry.distanceKm.toStringAsFixed(1)} km',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                tooltip: '+0.1 km',
                icon: const Icon(Icons.add_circle_outline),
                onPressed: entry.distanceKm >= 20
                    ? null
                    : () => notifier.updateDay(
                          day,
                          (e) => e.copyWith(
                              distanceKm: roundKm(
                                  (e.distanceKm + 0.1).clamp(0.0, 20.0).toDouble())),
                        ),
              ),
            ],
          ),
          Slider(
            value: entry.distanceKm.clamp(0.0, 20.0).toDouble(),
            min: 0,
            max: 20,
            divisions: 200,
            label: '${entry.distanceKm.toStringAsFixed(1)} km',
            onChanged: (v) => notifier.updateDay(
                day, (e) => e.copyWith(distanceKm: roundKm(v))),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- Reminders

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(habitProvider.select((s) => s.remindersEnabled));
    final eveningMin =
        ref.watch(habitProvider.select((s) => s.eveningReminderMinutes));
    final evening = TimeOfDay(hour: eveningMin ~/ 60, minute: eveningMin % 60);
    final notifier = ref.read(habitProvider.notifier);

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Daily reminders'),
            subtitle: const Text(
                'Wake-up nudge at your target time + an evening check-in'),
            value: enabled,
            onChanged: (v) async {
              if (v) {
                final granted =
                    await ref.read(notificationServiceProvider).requestPermission();
                if (!granted) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Notification permission was denied. Enable it in system settings.'),
                      ),
                    );
                  }
                  return;
                }
              }
              notifier.setRemindersEnabled(v);
            },
          ),
          if (enabled) ...[
            ListTile(
              leading: const Icon(Icons.nightlight_outlined),
              title: const Text('Evening check-in'),
              subtitle: Text(evening.format(context)),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () async {
                final picked =
                    await showTimePicker(context: context, initialTime: evening);
                if (picked != null) {
                  notifier.setEveningTime(picked.hour * 60 + picked.minute);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.notification_add_outlined),
              title: const Text('Send a test notification'),
              onTap: () => ref.read(notificationServiceProvider).showTest(),
            ),
          ],
        ],
      ),
    );
  }
}

// ------------------------------------------------------- Progress shortcut

class _ProgressCard extends ConsumerWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(progressStatsProvider);
    final subtitle = stats.hasData
        ? 'Latest ${stats.latest.toStringAsFixed(1)} km  |  '
            '${stats.increase >= 0 ? '+' : '-'}${stats.increase.abs().toStringAsFixed(1)} km vs first day'
        : 'Log a distance in any day to see your growth';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.show_chart),
        title: const Text('Distance progress'),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ProgressPage()),
        ),
      ),
    );
  }
}
