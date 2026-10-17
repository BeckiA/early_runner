import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../utils/time_format.dart';

Future<void> showCheckInSheet(BuildContext context, {required int day}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.surfaceLowest.withValues(alpha: 0.75),
    builder: (_) => CheckInSheet(day: day),
  );
}

class CheckInSheet extends ConsumerWidget {
  const CheckInSheet({super.key, required this.day});

  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(habitProvider.select((s) => s.entryFor(day)));
    final start = ref.watch(habitProvider.select((s) => s.startDate)) ?? DateTime.now();
    final wakeMinutes =
        ref.watch(habitProvider.select((s) => s.wakeTargetMinutes));
    final completed = ref.watch(completedCountProvider);
    final notifier = ref.read(habitProvider.notifier);
    final date = start.add(Duration(days: day - 1));
    final wakeLabel = formatMinutesAsTime(wakeMinutes);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    // Pace calculation
    final pace = entry.distanceKm > 0 && entry.minutes > 0
        ? formatPace(entry.minutes / entry.distanceKm)
        : "--'--\" /km";

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 20),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle / Dismiss Indicator
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBright.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'SWIPE DOWN TO DISMISS',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppColors.outline.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Sheet Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wb_twilight_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day $day Check-in',
                          style: GoogleFonts.sora(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${formatWeekdayDate(date)} • Optimal Dawn Run',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.onSurfaceVariant,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Two Tactile Toggle Cards
              Column(
                children: [
                  // Toggle 1: Wake Up Early
                  _ToggleCard(
                    icon: Icons.alarm_rounded,
                    iconColor: AppColors.primary,
                    title: 'Woke up early',
                    subtitleSpan: TextSpan(
                      text: 'Target: $wakeLabel ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      children: [
                        TextSpan(
                          text: '($wakeLabel)',
                          style: const TextStyle(color: AppColors.tertiary),
                        ),
                      ],
                    ),
                    value: entry.wokeEarly,
                    activeTrackColor: AppColors.primaryContainer,
                    onChanged: (v) => notifier.updateDay(
                      day,
                      (e) => e.copyWith(wokeEarly: v),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Toggle 2: Completed Workout
                  _ToggleCard(
                    icon: Icons.directions_run_rounded,
                    iconColor: AppColors.tertiary,
                    title: 'Completed workout',
                    subtitleSpan: TextSpan(
                      text: 'Morning outdoor session',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    value: entry.exercised,
                    activeTrackColor: AppColors.tertiaryContainer,
                    onChanged: (v) => notifier.updateDay(
                      day,
                      (e) => e.copyWith(exercised: v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Celebratory Banner Badge (Dynamic State)
              AnimatedOpacity(
                opacity: entry.isComplete ? 1.0 : 0.35,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day $day Goal Achieved',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              '100% adherence • $completed of $kHabitDays logged',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Streak on track',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Session Intensity Section
              Text(
                'SESSION INTENSITY',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _IntensityTab(
                        selected: entry.type == WorkoutType.jog,
                        icon: Icons.directions_walk_rounded,
                        label: 'Jog / Recovery',
                        onTap: () => notifier.updateDay(
                          day,
                          (e) => e.copyWith(type: WorkoutType.jog),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _IntensityTab(
                        selected: entry.type == WorkoutType.run,
                        icon: Icons.bolt_rounded,
                        iconColor: AppColors.primary,
                        label: 'Run (Active)',
                        onTap: () => notifier.updateDay(
                          day,
                          (e) => e.copyWith(type: WorkoutType.run),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Duration Control Section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DURATION',
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
                              '${entry.minutes}',
                              style: GoogleFonts.sora(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'min',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 5,
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.surfaceVariant,
                        thumbColor: AppColors.primary,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                        overlayColor: AppColors.primary.withValues(alpha: 0.15),
                      ),
                      child: Slider(
                        value: entry.minutes.clamp(10, 90).toDouble(),
                        min: 10,
                        max: 90,
                        divisions: 80,
                        onChanged: (v) => notifier.updateDay(
                          day,
                          (e) => e.copyWith(minutes: v.round()),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _QuickTimeButton(
                          label: '+5m',
                          onTap: () => notifier.updateDay(
                            day,
                            (e) => e.copyWith(
                              minutes: (e.minutes + 5).clamp(10, 90),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _QuickTimeButton(
                          label: '+15m',
                          onTap: () => notifier.updateDay(
                            day,
                            (e) => e.copyWith(
                              minutes: (e.minutes + 15).clamp(10, 90),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Distance Control Section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DISTANCE',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Row(
                          children: [
                            _StepButton(
                              label: '−',
                              onTap: entry.distanceKm <= 1.0
                                  ? null
                                  : () => notifier.updateDay(
                                        day,
                                        (e) => e.copyWith(
                                          distanceKm: roundKm(
                                            (e.distanceKm - 0.1).clamp(1.0, 15.0),
                                          ),
                                        ),
                                      ),
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 64),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    entry.distanceKm.toStringAsFixed(1),
                                    style: GoogleFonts.sora(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'km',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _StepButton(
                              label: '+',
                              onTap: entry.distanceKm >= 15.0
                                  ? null
                                  : () => notifier.updateDay(
                                        day,
                                        (e) => e.copyWith(
                                          distanceKm: roundKm(
                                            (e.distanceKm + 0.1).clamp(1.0, 15.0),
                                          ),
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 5,
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.surfaceVariant,
                        thumbColor: AppColors.primary,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                        overlayColor: AppColors.primary.withValues(alpha: 0.15),
                      ),
                      child: Slider(
                        value: entry.distanceKm.clamp(1.0, 15.0),
                        min: 1.0,
                        max: 15.0,
                        divisions: 140,
                        onChanged: (v) => notifier.updateDay(
                          day,
                          (e) => e.copyWith(distanceKm: roundKm(v)),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Average Pace',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          pace,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Primary Action Stadium Button (Save check-in)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: Text(
                    'Save check-in',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
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

              Center(
                child: Text(
                  'AUTO-SYNCS WITH STRAVA & APPLE HEALTH',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitleSpan,
    required this.value,
    required this.activeTrackColor,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final TextSpan subtitleSpan;
  final bool value;
  final Color activeTrackColor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                RichText(text: subtitleSpan),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: activeTrackColor,
            activeThumbColor: AppColors.onSurface,
            inactiveTrackColor: AppColors.surfaceVariant,
            inactiveThumbColor: AppColors.onSurfaceVariant,
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _IntensityTab extends StatelessWidget {
  const _IntensityTab({
    required this.selected,
    required this.icon,
    this.iconColor,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceBright : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? (iconColor ?? AppColors.onSurface)
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.onSurface : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: onTap == null
                ? AppColors.onSurfaceVariant.withValues(alpha: 0.3)
                : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _QuickTimeButton extends StatelessWidget {
  const _QuickTimeButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
