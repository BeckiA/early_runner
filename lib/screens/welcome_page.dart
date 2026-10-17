import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers.dart';
import '../theme/app_colors.dart';
import '../utils/time_format.dart';
import '../widgets/rise_mark.dart';
import '../widgets/surface_card.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wakeMin = ref.watch(habitProvider.select((s) => s.wakeTargetMinutes));
    final wakeLabel = formatMinutesAsTime(wakeMin);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            Row(
              children: [
                const RiseMark(size: 48),
                const SizedBox(width: 12),
                Text(
                  'RISE',
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'Rise early.',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
            Text(
              'Run daily.',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.05,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Commit to $wakeLabel every morning for 21 days. '
              'Build unbreakable momentum.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _Pill(icon: Icons.wb_twilight_rounded, label: 'First Light'),
                _Pill(icon: Icons.calendar_month_rounded, label: '21-Day Habit'),
                _Pill(icon: Icons.local_fire_department_rounded, label: 'Streak Focus'),
              ],
            ),
            const SizedBox(height: 28),
            SurfaceCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconBadge(
                    icon: Icons.groups_rounded,
                    color: AppColors.primary,
                    background: AppColors.surfaceHigh,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '21 mornings',
                          style: GoogleFonts.sora(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Wake early. Move your body. Check in daily.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SurfaceCard(
              color: AppColors.surfaceLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.alarm_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Tomorrow's Kickoff",
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        wakeLabel.split(' ').first,
                        style: GoogleFonts.sora(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          wakeLabel.split(' ').last,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Day 01 of 21',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.tertiary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Alarm set',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    ref.read(habitProvider.notifier).startChallenge(),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Start today'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your wake time can be changed anytime in Settings.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
