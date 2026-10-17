import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../utils/time_format.dart';
import '../widgets/rise_mark.dart';

class CelebrationPage extends ConsumerStatefulWidget {
  const CelebrationPage({super.key});

  @override
  ConsumerState<CelebrationPage> createState() => _CelebrationPageState();
}

class _CelebrationPageState extends ConsumerState<CelebrationPage> {
  bool _shared = false;

  @override
  Widget build(BuildContext context) {
    final completed = ref.watch(completedCountProvider);
    final streak = ref.watch(streakProvider);
    final stats = ref.watch(progressStatsProvider);
    final adherence = ((completed / kHabitDays) * 100).clamp(0, 100).toStringAsFixed(0);

    final totalKm = stats.total > 0 ? stats.total.toStringAsFixed(1) : '104.2';
    final enduranceIncrease = stats.increase != 0 ? formatSignedKm(stats.increase) : '+2.4 km';
    final capacityPct = stats.increasePct != null ? '${stats.increasePct!.toStringAsFixed(0)}%' : '80%';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Top App Bar
            AppHeader(
              title: 'Run Summary',
              eyebrow: '21-Day Habit',
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Finisher Crest & Radiant Halo Badge
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ambient radiant glow
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.35),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wb_sunny_rounded,
                          color: AppColors.primary,
                          size: 30,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'DAY 21',
                          style: GoogleFonts.sora(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Narrative & Typography Block
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        color: AppColors.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Challenge Complete',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'You Did It, Alex',
              textAlign: TextAlign.center,
              style: GoogleFonts.sora(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '21 days of first light. You conquered the quiet morning hours and established permanent athletic momentum.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 22),

            // 4-Card Hero Summary Grid (2x2)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.35,
              children: [
                _CelebrationStatCard(
                  title: 'CONSISTENCY',
                  icon: Icons.check_rounded,
                  iconColor: AppColors.tertiary,
                  value: '$completed/$kHabitDays',
                  caption: '$adherence% adherence',
                  captionColor: AppColors.tertiary,
                ),
                _CelebrationStatCard(
                  title: 'DISTANCE',
                  icon: Icons.straighten_rounded,
                  iconColor: AppColors.onSurfaceVariant,
                  value: '$totalKm km',
                  caption: 'Across 21 runs',
                ),
                _CelebrationStatCard(
                  title: 'STREAK',
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.secondary,
                  value: '$streak days',
                  caption: 'Zero misses',
                  captionColor: AppColors.secondary,
                ),
                _CelebrationStatCard(
                  title: 'ENDURANCE',
                  icon: Icons.trending_up_rounded,
                  iconColor: AppColors.tertiary,
                  value: enduranceIncrease,
                  caption: '+$capacityPct capacity',
                  captionColor: AppColors.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Achievement Badge Unlock Showcase
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UNLOCKED',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Dawn Master · Cohort 48',
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Runners Circle Proof Photo Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 24,
                    child: Stack(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceHigh,
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=80&q=80',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceHigh,
                              border: Border.all(
                                color: AppColors.surfaceLow,
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=80&q=80',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person_rounded,
                                  size: 14,
                                  color: AppColors.tertiary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '1,429 runners completed today',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Action Deck: Thumb Ergonomic Zone
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => _shared = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Achievement shared to clipboard! 🌅'),
                    ),
                  );
                },
                icon: Icon(
                  _shared ? Icons.check_rounded : Icons.arrow_outward_rounded,
                  size: 18,
                ),
                label: Text(
                  _shared ? 'Copied to Clipboard!' : 'Share achievement',
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Start next challenge?'),
                      content: const Text(
                        'This resets your 21-day challenge and begins the 50K Ultra program.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Start next'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    ref.read(habitProvider.notifier).startChallenge();
                    Navigator.pop(context);
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainer.withValues(alpha: 0.6),
                  side: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Start next challenge',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(50K Ultra)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CelebrationStatCard extends StatelessWidget {
  const _CelebrationStatCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.caption,
    this.captionColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String caption;
  final Color? captionColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.22),
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
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            caption,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: captionColor != null ? FontWeight.w600 : FontWeight.w400,
              color: captionColor ?? AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
