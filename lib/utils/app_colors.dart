import 'package:flutter/material.dart';

// Every color the app uses, named once. Previously the same raw values
// (Colors.red for errors, Colors.grey for muted text, etc.) were typed out
// individually in ~15 different files. Centralizing them here means:
//   - changing the brand color, or any status color, is now a one-line edit
//   - it's the foundation dark mode is built on top of (Step 3)
class AppColors {
  AppColors._();

  /// App's brand/seed color.
  static const Color primary = Colors.blue;

  /// Errors, delete actions, "on leave" status, cancel/destructive buttons.
  static const Color danger = Colors.red;

  /// "On duty" / available / success states.
  static const Color success = Colors.green;

  /// Warning banners (e.g. "remarks required").
  static const Color warning = Colors.orange;

  /// Secondary/muted text, hints, subtitle labels.
  static const Color muted = Colors.grey;
  static const Color mutedDark = Color(0xFF616161); // Colors.grey.shade700

  /// Machine category colors (Engineering / Production / Warehouse).
  static const Color categoryEngineering = Colors.indigo;
  static const Color categoryProduction = Colors.teal;
  static const Color categoryWarehouse = Colors.brown;
}
