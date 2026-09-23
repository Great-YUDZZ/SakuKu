import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Kartu signature Neumorphism Light (IT-Toolbox).
/// Permukaan putih cemerlang dengan dual shadow lembut dan opsi bilah aksen vertikal kiri.
class GlassNeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isInset;
  final Color? accentGlow;
  final Color? stripeColor; // Bilah aksen vertikal kiri khas StatCard
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const GlassNeumorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppDimensions.radiusCard,
    this.isInset = false,
    this.accentGlow,
    this.stripeColor,
    this.onTap,
    this.width,
    this.height,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ??
        (isInset ? AppColors.cardInner : AppColors.cardSurface);

    Widget innerChild = child;
    if (stripeColor != null) {
      innerChild = Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: AppDimensions.cardStripeWidth,
              decoration: BoxDecoration(
                color: stripeColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  bottomLeft: Radius.circular(borderRadius),
                ),
              ),
            ),
          ),
          Padding(
            padding: padding ?? const EdgeInsets.all(AppDimensions.paddingL),
            child: child,
          ),
        ],
      );
    }

    final cardContent = Container(
      width: width,
      height: height,
      padding: stripeColor != null
          ? EdgeInsets.zero
          : (padding ?? const EdgeInsets.all(AppDimensions.paddingL)),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isInset
              ? AppColors.borderMedium
              : (accentGlow?.withOpacity(0.3) ?? AppColors.borderSubtle),
          width: 1.0,
        ),
      ),
      child: innerChild,
    );

    final shadowDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: isInset
          ? [
              const BoxShadow(
                color: AppColors.neuInsetDark,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
              const BoxShadow(
                color: AppColors.neuInsetLight,
                offset: Offset(-2, -2),
                blurRadius: 4,
              ),
            ]
          : [
              // Top-left white highlight
              const BoxShadow(
                color: AppColors.neuLightHighlight,
                offset: Offset(-3, -3),
                blurRadius: 8,
              ),
              // Bottom-right cool slate ambient shadow
              const BoxShadow(
                color: AppColors.neuDarkShadow,
                offset: Offset(4, 4),
                blurRadius: 12,
              ),
              if (accentGlow != null)
                BoxShadow(
                  color: accentGlow!.withOpacity(0.18),
                  offset: const Offset(0, 3),
                  blurRadius: 12,
                ),
            ],
    );

    Widget result = Container(
      margin: margin,
      decoration: shadowDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardContent,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: result,
        ),
      );
    }

    return result;
  }
}
