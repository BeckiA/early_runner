import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:early_runner/main.dart';
import 'package:early_runner/notification_service.dart';
import 'package:early_runner/providers.dart';
import 'package:early_runner/screens/celebration_page.dart';

void main() {
  testWidgets('App renders welcome page initially and starts challenge',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final notifications = NotificationService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          notificationServiceProvider.overrideWithValue(notifications),
        ],
        child: const EarlyRunnerApp(),
      ),
    );

    expect(find.text('Rise early.'), findsOneWidget);
    expect(find.text('Run daily.'), findsOneWidget);
    expect(find.text('COHORT 48 ENROLLING'), findsOneWidget);
    expect(find.text('14,280+'), findsOneWidget);

    // Tap "Start today" button
    await tester.tap(find.text('Start today'));
    await tester.pump(const Duration(milliseconds: 300));

    // Now should be on Home Dashboard
    expect(find.text('Active Morning Run'), findsOneWidget);
    expect(find.text('Your 21 days'), findsOneWidget);

    // Check bottom navigation tabs
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Navigate to Progress tab
    await tester.tap(find.text('Progress'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Progress Analytics'), findsOneWidget);
    expect(find.text('Distance Progress'), findsOneWidget);
    expect(find.text('DISTANCE VELOCITY'), findsOneWidget);
    expect(find.text('Distance Per Day'), findsOneWidget);

    // Navigate to Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Settings Preferences'), findsOneWidget);
    expect(find.text('Alex Mercer'), findsOneWidget);
    expect(find.text('Morning & Evening Protocols'), findsOneWidget);
    expect(find.text('Live Push Simulation'), findsOneWidget);
    expect(find.text('Integrations & Hardware'), findsOneWidget);

    // Navigate back to Home tab
    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(milliseconds: 300));

    // Open Check-in Sheet for Day 1
    await tester.tap(find.text('1'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Day 1 Check-in'), findsOneWidget);
    expect(find.text('Woke up early'), findsOneWidget);
    expect(find.text('Completed workout'), findsOneWidget);
    expect(find.text('Save check-in'), findsOneWidget);

    // Close check-in sheet
    await tester.tap(find.text('Save check-in'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('Celebration page renders properly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final notifications = NotificationService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          notificationServiceProvider.overrideWithValue(notifications),
        ],
        child: const MaterialApp(
          home: CelebrationPage(),
        ),
      ),
    );

    expect(find.text('Run Summary'), findsOneWidget);
    expect(find.text('DAY 21'), findsOneWidget);
    expect(find.text('You Did It, Alex'), findsOneWidget);
    expect(find.text('Share achievement'), findsOneWidget);
    expect(find.text('Start next challenge'), findsOneWidget);
  });
}
