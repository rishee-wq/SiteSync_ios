import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color primaryDark = Color(0xFF0A0E21);
  static const Color primaryNavy = Color(0xFF0F1535);
  static const Color cardDark = Color(0xFF151A3A);
  static const Color cardBorder = Color(0xFF1E2555);

  // Accent colors
  static const Color accentPurple = Color(0xFF6C63FF);
  static const Color accentPurpleLight = Color(0xFF8B83FF);
  static const Color accentGreen = Color(0xFF00E5A0);
  static const Color accentGreenLight = Color(0xFF00FFB4);
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentOrange = Color(0xFFFF8A50);
  static const Color accentPink = Color(0xFFFF6B9D);

  // Status colors
  static const Color statusNew = Color(0xFF00D4FF);
  static const Color statusInProgress = Color(0xFF6C63FF);
  static const Color statusWaiting = Color(0xFFFFB74D);
  static const Color statusResolved = Color(0xFF00E5A0);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E95B4);
  static const Color textTertiary = Color(0xFF5A6080);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentPurple, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bannerGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient profileGradient = LinearGradient(
    colors: [Color(0xFF4A47C9), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [accentGreen, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1F45), Color(0xFF151A3A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
