import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final baseText = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final display = GoogleFonts.soraTextTheme(ThemeData.dark().textTheme);

    final scheme = const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onPrimary,
      tertiary: AppColors.tertiary,
      onTertiary: Color(0xFF003822),
      error: AppColors.error,
      onError: Color(0xFF690005),
      errorContainer: AppColors.errorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      surfaceContainerLowest: AppColors.background,
      surfaceContainerLow: AppColors.surfaceLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceHigh,
      surfaceContainerHighest: AppColors.surfaceHighest,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.outlineVariant.withValues(alpha: 0.4),
      textTheme: baseText
          .copyWith(
            displayLarge: display.displayLarge,
            displayMedium: display.displayMedium,
            displaySmall: display.displaySmall,
            headlineLarge: display.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            headlineMedium: display.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            headlineSmall: display.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            titleLarge: display.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            titleMedium: baseText.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            titleSmall: baseText.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            bodyLarge: baseText.bodyLarge?.copyWith(color: AppColors.onSurface),
            bodyMedium:
                baseText.bodyMedium?.copyWith(color: AppColors.onSurface),
            bodySmall: baseText.bodySmall
                ?.copyWith(color: AppColors.onSurfaceVariant),
            labelLarge: baseText.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: AppColors.primary,
            ),
            labelMedium: baseText.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            labelSmall: baseText.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          )
          .apply(
            bodyColor: AppColors.onSurface,
            displayColor: AppColors.onSurface,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: display.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.sora(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.onPrimary;
          }
          return AppColors.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryContainer;
          }
          return AppColors.surfaceHigh;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryContainer,
        inactiveTrackColor: AppColors.surfaceHighest,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.16),
        valueIndicatorColor: AppColors.primaryContainer,
        valueIndicatorTextStyle: const TextStyle(color: AppColors.onPrimary),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryContainer;
            }
            return AppColors.surfaceHigh;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.onPrimary;
            }
            return AppColors.onSurfaceVariant;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLow,
        modalBackgroundColor: AppColors.surfaceLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.outline,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHighest,
        contentTextStyle: baseText.bodyMedium?.copyWith(color: AppColors.onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLow,
        indicatorColor: AppColors.primaryContainer.withValues(alpha: 0.28),
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            size: 24,
          );
        }),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.primary,
        textColor: AppColors.onSurface,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryContainer,
        circularTrackColor: AppColors.surfaceHighest,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.surfaceContainer,
        hourMinuteColor: AppColors.surfaceHigh,
        dayPeriodColor: AppColors.surfaceHigh,
        dialBackgroundColor: AppColors.surfaceHigh,
        dialHandColor: AppColors.primaryContainer,
        dialTextColor: AppColors.onSurface,
        entryModeIconColor: AppColors.primary,
      ),
    );
  }
}
