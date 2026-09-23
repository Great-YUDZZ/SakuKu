import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Badge pill signature Neumorphism Light (IT-Toolbox).
/// Kapsul berlatar belakang soft pastel tint dengan teks dan ikon berwarna aksen tajam.
class GlassNeumorphicBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color? glowColor;
  final Color? backgroundColor;
  final bool isPill;
  final EdgeInsetsGeometry? padding;
  final double fontSize;

  const GlassNeumorphicBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primary,
    this.glowColor,
    this.backgroundColor,
    this.isPill = true,
    this.padding,
    this.fontSize = 11.0,
  });

  @override
  Widget build(BuildContext context) {
    final radius = isPill ? AppDimensions.radiusPill : 6.0;
    final effectiveBgColor = backgroundColor ?? color.withOpacity(0.12);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.neuLightHighlight,
            offset: Offset(-1, -1),
            blurRadius: 3,
          ),
          BoxShadow(
            color: AppColors.neuDarkShadow,
            offset: Offset(1, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Container(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: effectiveBgColor,
          border: Border.all(
            color: color.withOpacity(0.28),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: fontSize + 2, color: color),
              const SizedBox(width: 4.0),
            ],
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
