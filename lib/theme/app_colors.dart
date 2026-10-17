import 'package:flutter/material.dart';

/// Stitch design tokens for Early Runner Habit Tracker UI.
abstract final class AppColors {
  static const background = Color(0xFF0F1226);
  static const surface = Color(0xFF0F1226);
  static const surfaceLow = Color(0xFF171A2E);
  static const surfaceContainer = Color(0xFF1B1E33);
  static const surfaceHigh = Color(0xFF26293E);
  static const surfaceHighest = Color(0xFF303349);

  static const primary = Color(0xFFFFB68D);
  static const primaryContainer = Color(0xFFFF8A3D);
  static const onPrimary = Color(0xFF532200);

  static const secondary = Color(0xFFFFB2BA);
  static const tertiary = Color(0xFF42E09A);
  static const tertiaryDim = Color(0xFF2BB87A);

  static const onSurface = Color(0xFFDFE0FD);
  static const onSurfaceVariant = Color(0xFFDDC1B3);

  static const outline = Color(0xFFA58C7F);
  static const outlineVariant = Color(0xFF564338);

  static const error = Color(0xFFFFB4AB);
  static const errorContainer = Color(0xFF93000A);

  static const done = tertiary;
  static const partial = Color(0xFFFFC857);
  static const missed = Color(0xFF5C3A42);
}
