import 'package:flutter/material.dart';

/// Palet warna resmi berdasarkan standar desain "IT-Toolbox Neumorphism Light".
class AppColors {
  AppColors._();

  // Backgrounds & Base Surfaces
  static const Color background = Color(0xFFEFF4FA); // Ethereal cool ice / pearl canvas
  static const Color backgroundDeep = Color(0xFFE2E8F0);
  static const Color backgroundSidebar = Color(0xFFE8EEF7); // Soft frosted cool light sidebar
  static const Color backgroundCard = Color(0xFFFFFFFF); // Luminous pure white card
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardInner = Color(0xFFF4F7FB); // Inset well for inputs & secondary blocks
  static const Color cardHover = Color(0xFFDBEAFE); // Soft blue tinted hover

  // Neumorphic Dual Shadows (Resting / Convex)
  static const Color neuDarkShadow = Color(0xFFC2D0E2); // Signature cool slate-blue shadow
  static const Color neuLightHighlight = Color(0xFFFFFFFF); // Pure white top-left specular highlight

  // Inset Shadows (Sunken / Concave)
  static const Color neuInsetDark = Color(0x2694A3B8);
  static const Color neuInsetLight = Color(0x80FFFFFF);

  // Borders
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  static const Color glassBorder = Color(0x66CBD5E1);
  static const Color glassBorderLight = Color(0xFFFFFFFF);
  static const Color glassSurface = Color(0xFFFFFFFF);
  static const Color glassSurfaceElevated = Color(0xFFFFFFFF);

  // Brand & Accents
  static const Color primary = Color(0xFF2563EB); // Cobalt Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryTint = Color(0xFFDBEAFE);
  static const Color primaryGlow = Color(0x332563EB);

  // Financial Semantics & Statuses
  static const Color income = Color(0xFF059669); // Emerald Green
  static const Color incomeTint = Color(0xFFD1FAE5);
  static const Color incomeGlow = Color(0x33059669);

  static const Color expense = Color(0xFFDC2626); // Coral Red
  static const Color expenseTint = Color(0xFFFEE2E2);
  static const Color expenseGlow = Color(0x33DC2626);

  static const Color warning = Color(0xFFD97706); // Amber / Tangerine
  static const Color warningTint = Color(0xFFFEF3C7);
  static const Color warningGlow = Color(0x33D97706);

  static const Color cyan = Color(0xFF0284C7); // Cyan
  static const Color cyanTint = Color(0xFFBAE6FD);

  static const Color violet = Color(0xFF7C3AED); // Tech Violet
  static const Color violetTint = Color(0xFFEDE9FE);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A); // Pitch Slate
  static const Color textSecondary = Color(0xFF334155); // Slate Gray
  static const Color textMuted = Color(0xFF64748B); // Cool Muted Slate
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFFFFFFFF);
}
