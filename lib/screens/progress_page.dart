import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../utils/time_format.dart';
import '../widgets/rise_mark.dart';

class ProgressPage extends ConsumerStatefulWidget {
  const ProgressPage({super.key});

  @override
  ConsumerState<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends ConsumerState<ProgressPage> {
  int? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(progressStatsProvider);
    final current = ref.watch(currentDayProvider);
    final wakeMin = ref.watch(habitProvider.select((s) => s.wakeTargetMinutes));
    final start = ref.watch(habitProvider.select((s) => s.startDate));
    final wakeLabel = formatMinutesAsTime(wakeMin);
    final dayLabel = current > kHabitDays ? 'Done' : 'Day $current of $kHabitDays';

    String rangeLabel = '21-Day Journey';
    if (start != null) {
      final end = start.add(const Duration(days: kHabitDays - 1));
      rangeLabel =
          '${formatShortDate(start)} – ${formatShortDate(end)} • 21-Day Journey';
    }

    final activeSelectedDay = _selectedDay ?? (current > 0 && current <= kHabitDays ? current : 1);
    final selectedDayDist = activeSelectedDay <= stats.perDay.length && stats.perDay[activeSelectedDay - 1] > 0
        ? '${stats.perDay[activeSelectedDay - 1].toStringAsFixed(1)} km'
        : (activeSelectedDay == current ? 'Today (Pending)' : 'Target ~5.0 km');

    final progressRatio = (current / kHabitDays).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            AppHeader(
              title: 'Progress Analytics',
              wakeLabel: wakeLabel,
            ),
            const SizedBox(height: 14),

            // Top Atmospheric Hero Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.tertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'DISTANCE VELOCITY',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          dayLabel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Distance Progress',
                    style: GoogleFonts.sora(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    rangeLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formatSignedKm(stats.increase),
                        style: GoogleFonts.sora(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              stats.increase >= 0
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              size: 14,
                              color: stats.increase >= 0
                                  ? AppColors.tertiary
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${stats.increasePct != null && stats.increasePct! >= 0 ? '+' : ''}${stats.increasePct?.toStringAsFixed(0) ?? '0'}%',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Week 1 Baseline',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Growth since launch ${stats.first.toStringAsFixed(1)} km → ${stats.latest.toStringAsFixed(1)} km',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 4,
                      backgroundColor: AppColors.surfaceHighest,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WEEK 1 (LOCKED)',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        'GOAL: 105 KM',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 4 Stat Tiles Grid (2x2)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.45,
              children: [
                _StatTile(
                  title: 'BASELINE',
                  icon: Icons.flag_rounded,
                  iconColor: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  value: stats.first.toStringAsFixed(1),
                  unit: 'km',
                  caption: 'Day 01 launch',
                ),
                _StatTile(
                  title: 'LATEST RUN',
                  icon: Icons.today_rounded,
                  iconColor: AppColors.primary,
                  value: stats.latest.toStringAsFixed(1),
                  unit: 'km',
                  caption: formatSignedKm(stats.increase),
                  captionColor: AppColors.tertiary,
                ),
                _StatTile(
                  title: 'BEST DISTANCE',
                  icon: Icons.military_tech_rounded,
                  iconColor: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  value: stats.best.toStringAsFixed(1),
                  unit: 'km',
                  caption: 'Peak session',
                ),
                _StatTile(
                  title: 'TOTAL LOGGED',
                  icon: Icons.stacked_line_chart_rounded,
                  iconColor: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  value: stats.total.toStringAsFixed(1),
                  unit: 'km',
                  caption: '${stats.perDay.where((v) => v > 0).length} runs completed',
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Interactive 21-Day Bar Chart Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance Per Day',
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Days 1–7 logged • 8–21 projected',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Actual',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceVariant,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Target',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 21-bar chart with guide lines
                  SizedBox(
                    height: 160,
                    child: Stack(
                      children: [
                        // Guide lines: 6k, 4k, 2k, Baseline
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const _GuideLine(label: '6k'),
                              const _GuideLine(label: '4k'),
                              _BaselineGuide(label: 'Base ${stats.first > 0 ? stats.first.toStringAsFixed(1) : "3.0"} km'),
                              const _GuideLine(label: '2k'),
                              const SizedBox(height: 1),
                            ],
                          ),
                        ),

                        // Interactive Bars
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 28, bottom: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                for (var day = 1; day <= kHabitDays; day++)
                                  Expanded(
                                    child: _DayBar(
                                      day: day,
                                      distance: day <= stats.perDay.length ? stats.perDay[day - 1] : 0,
                                      baseline: stats.first > 0 ? stats.first : 3.0,
                                      maxDist: 6.5,
                                      isSelected: activeSelectedDay == day,
                                      isLogged: day <= current && (day <= stats.perDay.length && stats.perDay[day - 1] > 0),
                                      onTap: () => setState(() => _selectedDay = day),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Axis day markers (D1, D7, D14, D21)
                        Positioned(
                          left: 28,
                          right: 0,
                          bottom: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'D1',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'D7',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'D14',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                                ),
                              ),
                              Text(
                                'D21',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Interactive tooltip bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.touch_app_rounded,
                              size: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Day $activeSelectedDay Status',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'D$activeSelectedDay: $selectedDayDist',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Week-by-Week Evolution Card
            _WeeklyEvolutionCard(stats: stats),
            const SizedBox(height: 14),

            // Average Pace & Efficiency Row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OVERALL AVG PACE',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              stats.avgPace != null ? formatPace(stats.avgPace!) : "6'12\"",
                              style: GoogleFonts.sora(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/km',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.trending_down_rounded,
                            size: 16,
                            color: AppColors.tertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '-24s faster',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.tertiary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'vs Day 1 pace (6:36)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Visual Delight: Tomorrow Prep Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.wb_sunny_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tomorrow at $wakeLabel',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              current >= kHabitDays
                                  ? 'Challenge window complete. Review your growth and celebrate consistency.'
                                  : 'Day ${(current + 1).clamp(1, kHabitDays).toString().padLeft(2, '0')} awaits! Lace up before sunrise to plot your next bar and hit your goal.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Alarm set for $wakeLabel',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Prep Gear',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.unit,
    required this.caption,
    this.captionColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String unit;
  final String caption;
  final Color? captionColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.sora(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(
            caption,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: captionColor != null ? FontWeight.w600 : FontWeight.w400,
              color: captionColor ?? AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideLine extends StatelessWidget {
  const _GuideLine({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 22,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.surfaceVariant.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

class _BaselineGuide extends StatelessWidget {
  const _BaselineGuide({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 22),
        Expanded(
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              CustomPaint(
                size: const Size(double.infinity, 1),
                painter: _DashedLinePainter(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, 0), Offset(math.min(x + 4, size.width), 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.day,
    required this.distance,
    required this.baseline,
    required this.maxDist,
    required this.isSelected,
    required this.isLogged,
    required this.onTap,
  });

  final int day;
  final double distance;
  final double baseline;
  final double maxDist;
  final bool isSelected;
  final bool isLogged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Height ratio
    final dist = isLogged
        ? distance
        : (baseline + (day - 1) * 0.15).clamp(baseline, maxDist);
    final ratio = (dist / maxDist).clamp(0.15, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: ratio,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isLogged
                  ? (isSelected ? AppColors.primaryContainer : AppColors.primary.withValues(alpha: 0.75))
                  : AppColors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
              border: isSelected
                  ? Border.all(color: AppColors.onSurface, width: 1)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyEvolutionCard extends StatelessWidget {
  const _WeeklyEvolutionCard({required this.stats});
  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Week-by-Week Evolution',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                'PHASE 1 DONE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _WeekRow(
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.tertiary,
            title: 'Week 1 (Days 1–7)',
            subtitle: stats.weeklyAvg[0] != null
                ? '${stats.weeklyAvg[0]!.toStringAsFixed(1)} km avg / day'
                : '4.6 km avg / day',
            badge: '+1.6 km vs base',
            badgeColor: AppColors.tertiary,
          ),
          const SizedBox(height: 8),
          const _WeekRow(
            icon: Icons.radio_button_unchecked_rounded,
            iconColor: AppColors.onSurfaceVariant,
            title: 'Week 2 (Days 8–14)',
            subtitle: 'Building endurance stamina',
            badge: '5.2 km target',
          ),
          const SizedBox(height: 8),
          const _WeekRow(
            icon: Icons.radio_button_unchecked_rounded,
            iconColor: AppColors.onSurfaceVariant,
            title: 'Week 3 (Days 15–21)',
            subtitle: 'Automaticity sealed',
            badge: '5.8 km peak',
            isFaded: true,
          ),
        ],
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    this.badgeColor,
    this.isFaded = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badge;
  final Color? badgeColor;
  final bool isFaded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: isFaded ? 0.4 : 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badge,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badgeColor ?? AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
