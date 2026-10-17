import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../utils/time_format.dart';
import '../widgets/rise_mark.dart';
import 'celebration_page.dart';
import 'check_in_sheet.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(completedCountProvider);
    final current = ref.watch(currentDayProvider);
    final wakeMin = ref.watch(habitProvider.select((s) => s.wakeTargetMinutes));
    final wakeLabel = formatMinutesAsTime(wakeMin);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            AppHeader(
              title: 'Active Morning Run',
              wakeLabel: wakeLabel,
            ),
            const SizedBox(height: 14),

            // Summary Card
            const _SummaryCard(),
            if (completed == kHabitDays) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CelebrationPage(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.tertiary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.celebration_rounded,
                          color: AppColors.tertiary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Challenge complete!',
                              style: GoogleFonts.sora(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.tertiary,
                              ),
                            ),
                            Text(
                              'Tap to open your Day $kHabitDays celebration',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.tertiary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your 21 days',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  current > kHabitDays
                      ? 'Window closed'
                      : 'Day $current · tap to check in',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 21 Day Calendar Grid
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

            // Legend
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
    final completed = ref.watch(completedCountProvider);
    final streak = ref.watch(streakProvider);
    final minutes = ref.watch(totalMinutesProvider);
    final distance = ref.watch(progressStatsProvider.select((s) => s.total));
    final current = ref.watch(currentDayProvider);
    final dayLabel = current > kHabitDays ? 'Done' : '$current / $kHabitDays';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: (completed / kHabitDays).clamp(0.0, 1.0),
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    color: AppColors.primaryContainer,
                    backgroundColor: AppColors.surfaceHighest,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$completed/$kHabitDays',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'days',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _StatRow(
                  icon: Icons.today_rounded,
                  iconColor: AppColors.primary,
                  label: 'Day',
                  value: dayLabel,
                ),
                const SizedBox(height: 8),
                _StatRow(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.secondary,
                  label: 'Streak',
                  value: '$streak day${streak == 1 ? '' : 's'}',
                ),
                const SizedBox(height: 8),
                _StatRow(
                  icon: Icons.timer_outlined,
                  iconColor: AppColors.primary,
                  label: 'Active',
                  value: '$minutes min',
                ),
                const SizedBox(height: 8),
                _StatRow(
                  icon: Icons.route_rounded,
                  iconColor: AppColors.tertiary,
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
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
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
      return AppColors.surfaceHighest.withValues(alpha: 0.6);
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
              ? const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF003822),
                  size: 18,
                )
              : Text(
                  '$day',
                  style: GoogleFonts.inter(
                    color: locked
                        ? AppColors.onSurfaceVariant.withValues(alpha: 0.4)
                        : onFilled,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _statusColor(s),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
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
