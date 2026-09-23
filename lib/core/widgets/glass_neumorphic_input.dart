import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Field input signature Neumorphism Light (IT-Toolbox).
/// Permukaan inset well (#F4F7FB) dengan border halus dan bayangan cekung halus.
class GlassNeumorphicInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;

  const GlassNeumorphicInput({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.onChanged,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<GlassNeumorphicInput> createState() => _GlassNeumorphicInputState();
}

class _GlassNeumorphicInputState extends State<GlassNeumorphicInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 2.0, bottom: 6.0),
            child: Text(
              widget.labelText!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        AnimatedContainer(
          duration: AppDimensions.durationMicro,
          decoration: BoxDecoration(
            color: AppColors.cardInner,
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            border: Border.all(
              color: hasError
                  ? AppColors.expense
                  : (_isFocused ? AppColors.primary : AppColors.borderMedium),
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: [
              // Inset shadow simulation for debossed concave effect
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
              if (_isFocused)
                BoxShadow(
                  color: (hasError ? AppColors.expense : AppColors.primary)
                      .withOpacity(0.18),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            autofocus: widget.autofocus,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                        color: _isFocused ? AppColors.primary : AppColors.textMuted,
                        size: 20,
                      ),
                      child: widget.prefixIcon!,
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 12.0,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, top: 4.0),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: AppColors.expense,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
