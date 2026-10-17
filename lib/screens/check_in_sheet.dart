import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../utils/time_format.dart';
import '../widgets/surface_card.dart';

Future<void> showCheckInSheet(BuildContext context, {required int day}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => CheckInSheet(day: day),
  );
}

class CheckInSheet extends ConsumerWidget {
  const CheckInSheet({super.key, required this.day});

  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(habitProvider.select((s) => s.entryFor(day)));
    final start = ref.watch(habitProvider.select((s) => s.startDate))!;
    final wakeMinutes =
        ref.watch(habitProvider.select((s) => s.wakeTargetMinutes));
    final completed = ref.watch(completedCountProvider);
    final streak = ref.watch(streakProvider);
    final notifier = ref.read(habitProvider.notifier);
    final date = start.add(Duration(days: day - 1));
    final wakeLabel = formatMinutesAsTime(wakeMinutes);
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final pace = entry.distanceKm > 0 && entry.minutes > 0
        ? formatPace(entry.minutes / entry.distanceKm)
        : '—';

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 24),
          children: [
            Center(
              child: Text(
                'Swipe down to dismiss',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconBadge(
                  icon: Icons.wb_twilight_rounded,
                  color: AppColors.primaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day $day Check-in',
                        style: theme.textTheme.headlineSmall,
                      ),
                      Text(
                        '${formatWeekdayDate(date)} · Dawn session',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                    secondary: IconBadge(
                      icon: Icons.alarm_rounded,
                      color: entry.wokeEarly
                          ? AppColors.tertiary
                          : AppColors.primary,
                    ),
                    title: const Text('Woke up early'),
                    subtitle: Text('Target: $wakeLabel'),
                    value: entry.wokeEarly,
                    onChanged: (v) => notifier.updateDay(
                      day,
                      (e) => e.copyWith(wokeEarly: v),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.outlineVariant.withValues(alpha: 0.35),
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                    secondary: IconBadge(
                      icon: Icons.directions_run_rounded,
                      color: entry.exercised
                          ? AppColors.tertiary
                          : AppColors.primary,
                    ),
                    title: const Text('Completed workout'),
                    subtitle: const Text('Morning outdoor session'),
                    value: entry.exercised,
                    onChanged: (v) => notifier.updateDay(
                      day,
                      (e) => e.copyWith(exercised: v),
                    ),
                  ),
                ],
              ),
            ),
            if (entry.isComplete) ...[
              const SizedBox(height: 14),
              SurfaceCard(
                color: AppColors.tertiary.withValues(alpha: 0.12),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.tertiary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Day $day goal achieved',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.tertiary,
                            ),
                          ),
                          Text(
                            '$completed of $kHabitDays logged · '
                            'Streak $streak day${streak == 1 ? '' : 's'}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            Text('Session intensity', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _IntensityChip(
                    selected: entry.type == WorkoutType.jog,
                    icon: Icons.directions_walk_rounded,
                    label: 'Jog / Recovery',
                    onTap: () => notifier.updateDay(
                      day,
                      (e) => e.copyWith(type: WorkoutType.jog),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _IntensityChip(
                    selected: entry.type == WorkoutType.run,
                    icon: Icons.bolt_rounded,
                    label: 'Run (Active)',
                    onTap: () => notifier.updateDay(
                      day,
                      (e) => e.copyWith(type: WorkoutType.run),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Duration', style: theme.textTheme.titleSmall),
                      const Spacer(),
                      Text(
                        '${entry.minutes}',
                        style: GoogleFonts.sora(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('min', style: theme.textTheme.bodySmall),
                    ],
                  ),
                  Slider(
                    value: entry.minutes.toDouble(),
                    min: 0,
                    max: 120,
                    divisions: 24,
                    label: '${entry.minutes} min',
                    onChanged: (v) => notifier.updateDay(
                      day,
                      (e) => e.copyWith(minutes: v.round()),
                    ),
                  ),
                  Row(
                    children: [
                      _QuickChip(
                        label: '+5m',
                        onTap: () => notifier.updateDay(
                          day,
                          (e) => e.copyWith(
                            minutes: (e.minutes + 5).clamp(0, 120),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _QuickChip(
                        label: '+15m',
                        onTap: () => notifier.updateDay(
                          day,
                          (e) => e.copyWith(
                            minutes: (e.minutes + 15).clamp(0, 120),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Distance', style: theme.textTheme.titleSmall),
                      const Spacer(),
                      IconButton(
                        tooltip: '-0.1 km',
                        onPressed: entry.distanceKm <= 0
                            ? null
                            : () => notifier.updateDay(
                                  day,
                                  (e) => e.copyWith(
                                    distanceKm: roundKm(
                                      (e.distanceKm - 0.1)
                                          .clamp(0.0, 20.0)
                                          .toDouble(),
                                    ),
                                  ),
                                ),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        entry.distanceKm.toStringAsFixed(1),
                        style: GoogleFonts.sora(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('km', style: theme.textTheme.bodySmall),
                      IconButton(
                        tooltip: '+0.1 km',
                        onPressed: entry.distanceKm >= 20
                            ? null
                            : () => notifier.updateDay(
                                  day,
                                  (e) => e.copyWith(
                                    distanceKm: roundKm(
                                      (e.distanceKm + 0.1)
                                          .clamp(0.0, 20.0)
                                          .toDouble(),
                                    ),
                                  ),
                                ),
                        icon: const Icon(Icons.add_circle_outline),
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
                      day,
                      (e) => e.copyWith(distanceKm: roundKm(v)),
                    ),
                  ),
                  Row(
                    children: [
                      Text('Average pace', style: theme.textTheme.bodySmall),
                      const Spacer(),
                      Text(
                        pace,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save check-in'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IntensityChip extends StatelessWidget {
  const _IntensityChip({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primaryContainer.withValues(alpha: 0.22)
          : AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primaryContainer
                  : AppColors.outlineVariant.withValues(alpha: 0.4),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.surfaceHigh,
      side: BorderSide.none,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.onSurface,
          ),
    );
  }
}
