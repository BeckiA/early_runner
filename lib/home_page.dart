import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'screens/home_dashboard.dart';
import 'screens/progress_page.dart';
import 'screens/settings_page.dart';
import 'screens/welcome_page.dart';
import 'theme/app_colors.dart';

/// Root shell: welcome when not started, otherwise Home / Progress / Settings.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final started = ref.watch(habitProvider.select((s) => s.startDate != null));

    if (!started) {
      return const WelcomePage();
    }

    final pages = const [
      HomeDashboard(),
      ProgressPage(),
      SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_twilight_outlined),
            selectedIcon: Icon(Icons.wb_twilight_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up_rounded),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded, color: AppColors.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
