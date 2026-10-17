import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../utils/time_format.dart';
import '../widgets/rise_mark.dart';
import '../widgets/surface_card.dart';
import 'celebration_page.dart';
import 'check_in_sheet.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(completedCountProvider);
    final current = ref.watch(currentDayProvider);
    final wakeMin = ref.watch(habitProvider.select((s) => s.wakeTargetMinutes));
    final theme = Theme.of(context);
    final wakeLabel = formatMinutesAsTime(wakeMin);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Row(
              children: [
                const RiseMark(size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ScreenEyebrow(text: '21-Day Habit'),
                      Text('Home', style: theme.textTheme.headlineSmall),
                    ],
                  ),
                ),
                WakeBadge(label: wakeLabel),
              ],
            ),
            const SizedBox(height: 20),
            const _SummaryCard(),
            if (completed == kHabitDays) ...[
              const SizedBox(height: 14),
              SurfaceCard(
                color: AppColors.tertiary.withValues(alpha: 0.12),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CelebrationPage(),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.celebration_rounded,
                        color: AppColors.tertiary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Challenge complete',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.tertiary,
                            ),
                          ),
                          Text(
                            'Tap to open your Day $kHabitDays celebration',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.tertiary),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Your 21 days', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  current > kHabitDays
                      ? 'Window closed'
                      : 'Day $current · tap to check in',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (var d = 1; d <= kHabitDays; d++) _DayCell(day: d),
              ],
            ),
            const SizedBox(height: 16),
            const _Legend(),
          ],
        ),
      ),
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

    return SurfaceCard(
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
                    color: AppColors.primaryContainer,
                    backgroundColor: AppColors.surfaceHighest,
                  ),
                ),
                Text(
                  '$completed/$kHabitDays',
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _StatRow(icon: Icons.today_rounded, label: 'Day', value: dayLabel),
                const SizedBox(height: 10),
                _StatRow(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Streak',
                  value: '$streak day${streak == 1 ? '' : 's'}',
                ),
                const SizedBox(height: 10),
                _StatRow(
                  icon: Icons.timer_outlined,
                  label: 'Active',
                  value: '$minutes min',
                ),
                const SizedBox(height: 10),
                _StatRow(
                  icon: Icons.route_rounded,
                  label: 'Distance',
                  value: '${distance.toStringAsFixed(1)} km',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}

Color _statusColor(DayStatus s) {
  switch (s) {
    case DayStatus.done:
      return AppColors.tertiaryDim;
    case DayStatus.partial:
      return AppColors.partial.withValues(alpha: 0.85);
    case DayStatus.missed:
      return AppColors.missed;
    case DayStatus.today:
      return AppColors.primaryContainer.withValues(alpha: 0.35);
    case DayStatus.locked:
      return AppColors.surfaceHighest;
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell({required this.day});
  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(dayStatusProvider(day));
    final locked = status == DayStatus.locked;
    final onFilled = status == DayStatus.done
        ? const Color(0xFF003822)
        : AppColors.onSurface;

    return Material(
      color: _statusColor(status),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: locked ? null : () => showCheckInSheet(context, day: day),
        child: Container(
          decoration: status == DayStatus.today
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 2),
                )
              : null,
          alignment: Alignment.center,
          child: status == DayStatus.done
              ? const Icon(Icons.check_rounded, color: Color(0xFF003822), size: 18)
              : Text(
                  '$day',
                  style: TextStyle(
                    color: locked
                        ? AppColors.onSurfaceVariant.withValues(alpha: 0.45)
                        : onFilled,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
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
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _statusColor(s),
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
