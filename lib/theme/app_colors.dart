import 'package:flutter/material.dart';

/// Stitch design tokens for Early Runner Habit Tracker UI.
abstract final class AppColors {
  // Surface and Background
  static const background = Color(0xFF0F1226);
  static const surface = Color(0xFF0F1226);
  static const surfaceDim = Color(0xFF0F1226);
  static const surfaceLowest = Color(0xFF090D20);
  static const surfaceLow = Color(0xFF171A2E);
  static const surfaceContainer = Color(0xFF1B1E33);
  static const surfaceHigh = Color(0xFF26293E);
  static const surfaceHighest = Color(0xFF303349);
  static const surfaceVariant = Color(0xFF303349);
  static const surfaceBright = Color(0xFF35384E);

  // Primary (Sunrise Amber / Warm Dawn)
  static const primary = Color(0xFFFFB68D);
  static const primaryContainer = Color(0xFFFF8A3D);
  static const primaryFixed = Color(0xFFFFDBC9);
  static const primaryFixedDim = Color(0xFFFFB68D);
  static const onPrimary = Color(0xFF532200);
  static const onPrimaryContainer = Color(0xFF682D00);
  static const onPrimaryFixed = Color(0xFF321200);
  static const onPrimaryFixedVariant = Color(0xFF763300);

  // Secondary (Coral Dawn Glow)
  static const secondary = Color(0xFFFFB2BA);
  static const secondaryContainer = Color(0xFF940432);
  static const secondaryFixed = Color(0xFFFFD9DC);
  static const secondaryFixedDim = Color(0xFFFFB2BA);
  static const onSecondary = Color(0xFF67001F);
  static const onSecondaryContainer = Color(0xFFFF9DA8);

  // Tertiary (Fresh Aurora Emerald / Mint Vitality)
  static const tertiary = Color(0xFF42E09A);
  static const tertiaryDim = Color(0xFF2BB87A);
  static const tertiaryContainer = Color(0xFF00C17F);
  static const tertiaryFixed = Color(0xFF65FDB5);
  static const tertiaryFixedDim = Color(0xFF42E09A);
  static const onTertiary = Color(0xFF003822);
  static const onTertiaryContainer = Color(0xFF00482C);
  static const onTertiaryFixed = Color(0xFF002112);

  // Typography & On-Surface
  static const onSurface = Color(0xFFDFE0FD);
  static const onSurfaceVariant = Color(0xFFDDC1B3);
  static const onBackground = Color(0xFFDFE0FD);

  // Outlines & Borders
  static const outline = Color(0xFFA58C7F);
  static const outlineVariant = Color(0xFF564338);

  // Error & Danger
  static const error = Color(0xFFFFB4AB);
  static const errorContainer = Color(0xFF93000A);
  static const onError = Color(0xFF690005);
  static const onErrorContainer = Color(0xFFFFDAD6);

  // Status mapping
  static const done = tertiary;
  static const partial = Color(0xFFFFC857);
  static const missed = Color(0xFF5C3A42);
}
