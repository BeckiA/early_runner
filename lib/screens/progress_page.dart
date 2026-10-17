import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../utils/time_format.dart';
import '../widgets/rise_mark.dart';
import '../widgets/surface_card.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(progressStatsProvider);
    final current = ref.watch(currentDayProvider);
    final wakeMin = ref.watch(habitProvider.select((s) => s.wakeTargetMinutes));
    final start = ref.watch(habitProvider.select((s) => s.startDate));
    final theme = Theme.of(context);
    final wakeLabel = formatMinutesAsTime(wakeMin);
    final dayLabel = current > kHabitDays
        ? 'Complete'
        : 'Day $current of $kHabitDays';

    String rangeLabel = '21-Day Journey';
    if (start != null) {
      final end = start.add(const Duration(days: kHabitDays - 1));
      rangeLabel =
          '${formatShortDate(start)} – ${formatShortDate(end)} · 21-Day Journey';
    }

    return Scaffold(
      body: SafeArea(
        child: stats.hasData
            ? ListView(
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
                            Text(
                              'Progress Analytics',
                              style: theme.textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                      WakeBadge(label: wakeLabel),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Distance Progress',
                              style: theme.textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                dayLabel,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.tertiary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(rangeLabel, style: theme.textTheme.bodySmall),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              stats.increase >= 0
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: stats.increase >= 0
                                  ? AppColors.tertiary
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formatSignedKm(stats.increase),
                              style: GoogleFonts.sora(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                            if (stats.increasePct != null) ...[
                              const SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '${stats.increasePct! >= 0 ? '+' : ''}${stats.increasePct!.toStringAsFixed(0)}%',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Growth since launch · '
                          '${formatKm(stats.first)} → ${formatKm(stats.latest)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: 'Baseline',
                          value: stats.first.toStringAsFixed(1),
                          unit: 'km',
                          caption: 'Day 01 launch',
                          icon: Icons.flag_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          label: 'Latest Run',
                          value: stats.latest.toStringAsFixed(1),
                          unit: 'km',
                          caption: formatSignedKm(stats.increase),
                          icon: Icons.directions_run_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: 'Best Distance',
                          value: stats.best.toStringAsFixed(1),
                          unit: 'km',
                          caption: 'Peak session',
                          icon: Icons.military_tech_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          label: 'Total Logged',
                          value: stats.total.toStringAsFixed(1),
                          unit: 'km',
                          caption:
                              '${stats.perDay.where((v) => v > 0).length} runs',
                          icon: Icons.stacked_line_chart_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distance Per Day',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dashed line = first logged distance',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        AspectRatio(
                          aspectRatio: 1.55,
                          child: CustomPaint(
                            painter: _DistanceChartPainter(
                              values: stats.perDay,
                              baseline: stats.first,
                              barColor: AppColors.primaryContainer,
                              gridColor: AppColors.outlineVariant
                                  .withValues(alpha: 0.45),
                              textColor: AppColors.onSurfaceVariant,
                              baselineColor: AppColors.tertiary,
                            ),
                            size: Size.infinite,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _WeeklyCard(stats: stats),
                  if (stats.avgPace != null) ...[
                    const SizedBox(height: 16),
                    SurfaceCard(
                      child: Row(
                        children: [
                          const IconBadge(
                            icon: Icons.timer_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Overall Avg Pace',
                                  style: theme.textTheme.titleSmall,
                                ),
                                Text(
                                  'Across logged sessions',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatPace(stats.avgPace!),
                            style: GoogleFonts.sora(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SurfaceCard(
                    color: AppColors.surfaceLow,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.wb_sunny_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tomorrow at $wakeLabel',
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                current >= kHabitDays
                                    ? 'Challenge window complete. Review your growth and celebrate consistency.'
                                    : 'Day ${(current + 1).clamp(1, kHabitDays).toString().padLeft(2, '0')} awaits! Lace up before sunrise to plot your next bar.',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const _EmptyState(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconBadge(
              icon: Icons.route_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(height: 20),
            Text('No distance logged yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Open a day on Home and enter how far you ran or jogged. '
              'Your growth will show up here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.caption,
    required this.icon,
  });

  final String label;
  final String value;
  final String unit;
  final String caption;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.sora(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(caption, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.stats});
  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <Widget>[];
    double? prev;

    for (var w = 0; w < 3; w++) {
      final avg = stats.weeklyAvg[w];
      String? delta;
      if (avg != null && prev != null) {
        delta = formatSignedKm(avg - prev);
      }
      final done = avg != null;
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: w == 0 ? 0 : 12),
          child: Row(
            children: [
              Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: done ? AppColors.tertiary : AppColors.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week ${w + 1} (Days ${w * 7 + 1}–${w * 7 + 7})',
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      done
                          ? '${formatKm(avg)} avg / day'
                          : w == 1
                              ? 'Building endurance stamina'
                              : 'Automaticity sealed',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (delta != null)
                Text(
                  delta,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      );
      if (avg != null) prev = avg;
    }

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Week-by-Week Evolution', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _DistanceChartPainter extends CustomPainter {
  _DistanceChartPainter({
    required this.values,
    required this.baseline,
    required this.barColor,
    required this.gridColor,
    required this.textColor,
    required this.baselineColor,
  });

  final List<double> values;
  final double baseline;
  final Color barColor;
  final Color gridColor;
  final Color textColor;
  final Color baselineColor;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 30.0;
    const top = 8.0;
    const bottom = 20.0;
    final chartW = size.width - left;
    final chartH = size.height - top - bottom;

    final peak = values.fold<double>(0, math.max);
    final maxV = math.max(3.0, (peak / 3).ceilToDouble() * 3);
    final labelStyle = TextStyle(color: textColor, fontSize: 10);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = top + chartH * (1 - i / 3);
      canvas.drawLine(Offset(left, y), Offset(size.width, y), gridPaint);
      _drawText(
        canvas,
        (maxV * i / 3).toStringAsFixed(0),
        Offset(left - 6, y),
        labelStyle,
        alignRight: true,
      );
    }

    final slot = chartW / values.length;
    final barW = slot * 0.62;
    final barPaint = Paint()..color = barColor;
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v <= 0) continue;
      final h = chartH * (v / maxV);
      final x = left + slot * i + (slot - barW) / 2;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, top + chartH - h, barW, h),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        barPaint,
      );
    }

    for (final i in const [0, 6, 13, 20]) {
      if (i >= values.length) continue;
      _drawText(
        canvas,
        'D${i + 1}',
        Offset(left + slot * i + slot / 2, size.height - 8),
        labelStyle,
        center: true,
      );
    }

    if (baseline > 0) {
      final y = top + chartH * (1 - baseline / maxV);
      final dash = Paint()
        ..color = baselineColor
        ..strokeWidth = 1.5;
      for (var x = left; x < size.width; x += 10) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + 5, size.width), y),
          dash,
        );
      }
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset at,
    TextStyle style, {
    bool alignRight = false,
    bool center = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    var dx = at.dx;
    if (alignRight) dx -= tp.width;
    if (center) dx -= tp.width / 2;
    tp.paint(canvas, Offset(dx, at.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _DistanceChartPainter old) =>
      old.values != values ||
      old.baseline != baseline ||
      old.barColor != barColor ||
      old.textColor != textColor;
}
