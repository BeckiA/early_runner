import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../utils/time_format.dart';
import '../widgets/rise_mark.dart';
import '../widgets/surface_card.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitProvider);
    final current = ref.watch(currentDayProvider);
    final theme = Theme.of(context);
    final wakeLabel = formatMinutesAsTime(state.wakeTargetMinutes);
    final eveningLabel = formatMinutesAsTime(state.eveningReminderMinutes);
    final dayLabel = current <= 0
        ? 'Not started'
        : current > kHabitDays
            ? 'Complete'
            : 'Day ${current.toString().padLeft(2, '0')} of $kHabitDays';

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
                      Text(
                        'Settings Preferences',
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
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Early Runner',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          '$dayLabel · Track $wakeLabel',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    wakeLabel.split(' ').first,
                    style: GoogleFonts.sora(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel(
              icon: Icons.wb_twilight_rounded,
              title: 'Morning & Evening Protocols',
              status: state.remindersEnabled ? 'SYNCED' : 'OFF',
              statusColor: state.remindersEnabled
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            SurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                    secondary: const Icon(Icons.notifications_active_rounded),
                    title: const Text('Daily reminders'),
                    subtitle: const Text(
                      'Wake-up nudge at your target time + evening check-in',
                    ),
                    value: state.remindersEnabled,
                    onChanged: (v) async {
                      if (v) {
                        final granted = await ref
                            .read(notificationServiceProvider)
                            .requestPermission();
                        if (!granted) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Notification permission was denied. '
                                  'Enable it in system settings.',
                                ),
                              ),
                            );
                          }
                          return;
                        }
                      }
                      ref.read(habitProvider.notifier).setRemindersEnabled(v);
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.alarm_rounded,
                    title: 'Wake-up alarm & nudge',
                    subtitle: 'First bell to begin dawn activation',
                    trailing: wakeLabel,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: state.wakeTargetMinutes ~/ 60,
                          minute: state.wakeTargetMinutes % 60,
                        ),
                      );
                      if (picked != null) {
                        ref.read(habitProvider.notifier).setWakeTarget(
                              picked.hour * 60 + picked.minute,
                            );
                      }
                    },
                  ),
                  if (state.remindersEnabled)
                    _SettingsTile(
                      icon: Icons.bedtime_rounded,
                      title: 'Evening prep ritual',
                      subtitle: "Tomorrow's kit layout reminder",
                      trailing: eveningLabel,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: state.eveningReminderMinutes ~/ 60,
                            minute: state.eveningReminderMinutes % 60,
                          ),
                        );
                        if (picked != null) {
                          ref.read(habitProvider.notifier).setEveningTime(
                                picked.hour * 60 + picked.minute,
                              );
                        }
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _SectionLabel(
              icon: Icons.cell_tower_rounded,
              title: 'Live Push Simulation',
              status: 'Preview',
              statusColor: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Early Runner · now',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Rise and run',
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          '$dayLabel: time to lace up at $wakeLabel.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(notificationServiceProvider).showTest(),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Send test push notification'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _SectionLabel(
              icon: Icons.warning_amber_rounded,
              title: 'Habit Integrity',
              status: 'IRREVERSIBLE',
              statusColor: AppColors.primary,
            ),
            const SizedBox(height: 12),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restart 21-Day Challenge',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Reset streak to Day 01 and clear previous run metrics. '
                    'Use only if you want a fresh start.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmReset(context, ref),
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Restart challenge'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Early Runner · Flutter',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset streak?'),
        content: const Text(
          'Confirm reset to Day 01. All progress will be erased.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel & keep streak'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm reset'),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(habitProvider.notifier).reset();
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.title,
    required this.status,
    required this.statusColor,
  });

  final IconData icon;
  final String title;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Text(
          status,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: statusColor,
                letterSpacing: 0.8,
              ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            trailing,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_right_rounded,
              color: AppColors.onSurfaceVariant),
        ],
      ),
      onTap: onTap,
    );
  }
}
