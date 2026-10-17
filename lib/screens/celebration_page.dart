import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../utils/time_format.dart';
import '../widgets/rise_mark.dart';
import '../widgets/surface_card.dart';

class CelebrationPage extends ConsumerWidget {
  const CelebrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(completedCountProvider);
    final streak = ref.watch(streakProvider);
    final stats = ref.watch(progressStatsProvider);
    final theme = Theme.of(context);
    final adherence =
        ((completed / kHabitDays) * 100).clamp(0, 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const RiseMark(size: 32),
            const SizedBox(width: 10),
            Text('Run Summary', style: theme.textTheme.titleLarge),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wb_sunny_rounded,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'DAY $kHabitDays',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Challenge Complete',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'You Did It',
              textAlign: TextAlign.center,
              style: GoogleFonts.sora(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '21 days of first light. You conquered the quiet morning hours '
              'and established lasting athletic momentum.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _StatTile(
                  icon: Icons.check_rounded,
                  label: 'Consistency',
                  value: '$completed/$kHabitDays',
                  caption: '$adherence% adherence',
                ),
                _StatTile(
                  icon: Icons.straighten_rounded,
                  label: 'Distance',
                  value: stats.total.toStringAsFixed(1),
                  caption: 'km across runs',
                ),
                _StatTile(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Streak',
                  value: '$streak',
                  caption: streak == kHabitDays ? 'Zero misses' : 'days strong',
                ),
                _StatTile(
                  icon: Icons.trending_up_rounded,
                  label: 'Endurance',
                  value: formatSignedKm(stats.increase),
                  caption: stats.increasePct == null
                      ? 'vs first day'
                      : '${stats.increasePct! >= 0 ? '+' : ''}${stats.increasePct!.toStringAsFixed(0)}% capacity',
                ),
              ],
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              child: Row(
                children: [
                  IconBadge(
                    icon: Icons.military_tech_rounded,
                    color: AppColors.primaryContainer,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unlocked', style: theme.textTheme.bodySmall),
                        Text(
                          'Dawn Master',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.verified_rounded, color: AppColors.tertiary),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Back to home'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Start next challenge?'),
                      content: const Text(
                        'This resets your 21-day streak and clears logged days.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Restart'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    ref.read(habitProvider.notifier).startChallenge();
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Start next challenge'),
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
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const Spacer(),
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          Text(caption, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
