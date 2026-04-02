import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF00E5FF); // Bright Cyan
  static const Color primaryDark = Color(0xFF00B8D4);
  static const Color primaryLight = Color(0xFF84FFFF);

  // Background Colors
  static const Color background = Color(
    0xFF10191F,
  ); // Dark slate/ocean background
  static const Color surface = Color(
    0xFF1A262E,
  ); // Slightly lighter card background
  static const Color surfaceVariant = Color(0xFF233038); // Input fields/cards

  // Text Colors
  static const Color textPrimary = Color(0xFFE1EBF0);
  static const Color textSecondary = Color(0xFFA1B4BE); // Muted blue-grey
  static const Color textHint = Color(0xFF546E7A);

  // Status Colors
  static const Color error = Color(0xFFEF5350);
  static const Color success = Color(
    0xFF66BB6A,
  ); // Green for "Visited", "Approved"
  static const Color warning = Color(0xFFFFCA28); // Amber for "Pending"
  static const Color info = Color(0xFF29B6F6); // Light Blue for "Scheduled"

  // UI Specific
  static const Color divider = Color(0xFF2C3E50);
  static const Color inputBorder = Color(0xFF37474F);
  static const Color iconColor = Color(0xFFCFD8DC);

  // Chart Colors
  static const Color chartBar = Color(0xFF00E5FF);
  static const Color chartBarBackground = Color(0xFF263238);
}
