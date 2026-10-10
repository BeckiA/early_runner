import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';
import 'providers.dart';

String _km(double v) => '${v.toStringAsFixed(1)} km';
String _signedKm(double v) =>
    '${v >= 0 ? '+' : '-'}${v.abs().toStringAsFixed(1)} km';

String _pace(double minPerKm) {
  var m = minPerKm.floor();
  var s = ((minPerKm - m) * 60).round();
  if (s == 60) {
    m += 1;
    s = 0;
  }
  return '$m:${s.toString().padLeft(2, '0')} /km';
}

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(progressStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Distance progress')),
      body: SafeArea(
        child: stats.hasData
            ? ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _GrowthCard(stats: stats),
                  const SizedBox(height: 16),
                  _ChartCard(stats: stats),
                  const SizedBox(height: 16),
                  _WeeklyCard(stats: stats),
                  if (stats.avgPace != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.speed),
                        title: const Text('Average pace'),
                        trailing: Text(
                          _pace(stats.avgPace!),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route,
                size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('No distance logged yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Open a day on the main screen and enter how far you ran or '
              'jogged. Your growth will show up here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ Growth card

class _GrowthCard extends StatelessWidget {
  const _GrowthCard({required this.stats});
  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final up = stats.increase >= 0;
    final pct = stats.increasePct;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distance growth', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(up ? Icons.trending_up : Icons.trending_down,
                    color: up ? Colors.green : theme.colorScheme.error,
                    size: 32),
                const SizedBox(width: 8),
                Text(_signedKm(stats.increase),
                    style: theme.textTheme.headlineMedium),
                if (pct != null) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '(${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(0)}%)',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ],
            ),
            Text('since your first logged day',
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            Row(
              children: [
                _MiniStat(label: 'First', value: _km(stats.first)),
                _MiniStat(label: 'Latest', value: _km(stats.latest)),
                _MiniStat(label: 'Best', value: _km(stats.best)),
                _MiniStat(label: 'Total', value: _km(stats.total)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------- Chart

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.stats});
  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distance per day',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Dashed line = your first logged distance',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.6,
              child: CustomPaint(
                painter: _DistanceChartPainter(
                  values: stats.perDay,
                  baseline: stats.first,
                  barColor: cs.primary,
                  gridColor: cs.outlineVariant,
                  textColor: cs.onSurfaceVariant,
                  baselineColor: cs.tertiary,
                ),
                size: Size.infinite,
              ),
            ),
          ],
        ),
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

    // Grid lines + y labels.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = top + chartH * (1 - i / 3);
      canvas.drawLine(Offset(left, y), Offset(size.width, y), gridPaint);
      _drawText(canvas, (maxV * i / 3).toStringAsFixed(0),
          Offset(left - 6, y), labelStyle,
          alignRight: true);
    }

    // Bars.
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
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        barPaint,
      );
    }

    // X labels.
    for (final i in const [0, 6, 13, 20]) {
      if (i >= values.length) continue;
      _drawText(
        canvas,
        '${i + 1}',
        Offset(left + slot * i + slot / 2, size.height - 8),
        labelStyle,
        center: true,
      );
    }

    // Dashed baseline at the first logged distance.
    if (baseline > 0) {
      final y = top + chartH * (1 - baseline / maxV);
      final dash = Paint()
        ..color = baselineColor
        ..strokeWidth = 1.5;
      for (var x = left; x < size.width; x += 10) {
        canvas.drawLine(
            Offset(x, y), Offset(math.min(x + 5, size.width), y), dash);
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

// ----------------------------------------------------------------- Weekly

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
      String delta = '';
      Color? deltaColor;
      if (avg != null && prev != null) {
        final d = avg - prev;
        delta = _signedKm(d);
        deltaColor = d >= 0 ? Colors.green : theme.colorScheme.error;
      }
      rows.add(
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text('Week ${w + 1}  (days ${w * 7 + 1}-${w * 7 + 7})'),
          subtitle: const Text('Average per logged day'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(avg == null ? '-' : _km(avg),
                  style: theme.textTheme.titleMedium),
              if (delta.isNotEmpty)
                Text(delta,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: deltaColor)),
            ],
          ),
        ),
      );
      if (avg != null) prev = avg;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Week by week', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            ...rows,
          ],
        ),
      ),
    );
  }
}
