import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

enum ButtonVariant {
  primary,
  income,
  expense,
  neutral;

  Color get solidColor {
    switch (this) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.income:
        return AppColors.income;
      case ButtonVariant.expense:
        return AppColors.expense;
      case ButtonVariant.neutral:
        return AppColors.cardSurface;
    }
  }

  Color get tintColor {
    switch (this) {
      case ButtonVariant.primary:
        return AppColors.primaryTint;
      case ButtonVariant.income:
        return AppColors.incomeTint;
      case ButtonVariant.expense:
        return AppColors.expenseTint;
      case ButtonVariant.neutral:
        return AppColors.cardHover;
    }
  }

  Color get textColor {
    switch (this) {
      case ButtonVariant.primary:
      case ButtonVariant.income:
      case ButtonVariant.expense:
        return Colors.white;
      case ButtonVariant.neutral:
        return AppColors.textPrimary;
    }
  }
}

class GlassNeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isSelected;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassNeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ButtonVariant.neutral,
    this.isSelected = false,
    this.width,
    this.height = 44.0,
    this.borderRadius = AppDimensions.radiusButton,
    this.padding,
  });

  @override
  State<GlassNeumorphicButton> createState() => _GlassNeumorphicButtonState();
}

class _GlassNeumorphicButtonState extends State<GlassNeumorphicButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final isSelected = widget.isSelected;
    final isSolid = widget.variant != ButtonVariant.neutral && !isSelected;

    Color bgColor;
    Color contentColor;
    Border? border;

    if (!isEnabled) {
      bgColor = AppColors.borderSubtle.withOpacity(0.5);
      contentColor = AppColors.textMuted;
      border = Border.all(color: AppColors.borderSubtle);
    } else if (_isPressed || isSelected) {
      bgColor = isSelected ? widget.variant.tintColor : widget.variant.solidColor;
      contentColor = isSelected
          ? (widget.variant == ButtonVariant.neutral
              ? AppColors.primary
              : widget.variant.solidColor)
          : Colors.white;
      border = Border.all(
        color: widget.variant == ButtonVariant.neutral
            ? AppColors.primary
            : widget.variant.solidColor,
        width: 1.2,
      );
    } else if (isSolid) {
      bgColor = _isHovered
          ? widget.variant.solidColor.withOpacity(0.92)
          : widget.variant.solidColor;
      contentColor = Colors.white;
      border = null;
    } else {
      // Neutral resting state: pure white surface
      bgColor = _isHovered ? AppColors.cardHover : AppColors.cardSurface;
      contentColor = _isHovered ? AppColors.primary : AppColors.textPrimary;
      border = Border.all(
        color: _isHovered ? AppColors.primary.withOpacity(0.4) : AppColors.borderMedium,
        width: 1.0,
      );
    }

    final List<BoxShadow> shadows = isEnabled
        ? (_isPressed || isSelected
            ? [
                // Inset tactile depression
                const BoxShadow(
                  color: AppColors.neuInsetDark,
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
                const BoxShadow(
                  color: AppColors.neuInsetLight,
                  offset: Offset(-1, -1),
                  blurRadius: 3,
                ),
              ]
            : [
                // Convex dual shadows
                const BoxShadow(
                  color: AppColors.neuLightHighlight,
                  offset: Offset(-2, -2),
                  blurRadius: 6,
                ),
                const BoxShadow(
                  color: AppColors.neuDarkShadow,
                  offset: Offset(3, 3),
                  blurRadius: 8,
                ),
              ])
        : [];

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : (_isHovered && isEnabled ? 1.01 : 1.0),
          duration: AppDimensions.durationMicro,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: AppDimensions.durationMicro,
            width: widget.width,
            height: widget.height,
            padding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: border,
              boxShadow: shadows,
            ),
            child: Center(
              child: DefaultTextStyle(
                style: TextStyle(
                  color: contentColor,
                  fontWeight: isSelected || isSolid ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14,
                ),
                child: IconTheme(
                  data: IconThemeData(color: contentColor, size: 18),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
