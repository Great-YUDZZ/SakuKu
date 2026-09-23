import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Latar belakang kanvas sejuk dan terang (Ethereal Cool Ice #EFF4FA)
/// dengan difusi gradasi ambient yang sangat halus dan bersih.
class AmbientBackground extends StatefulWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final val = _animation.value;
        return Stack(
          children: [
            // Ethereal Cool Ice Base Canvas (#EFF4FA)
            Positioned.fill(
              child: Container(
                color: AppColors.background,
              ),
            ),

            // Subtle luminous cyan accent in top-right
            Positioned(
              top: -60 + (val * 20),
              right: -40 + (val * 15),
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFE0E7FF).withOpacity(0.55),
                      const Color(0xFFE0E7FF).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Subtle luminous emerald / blue tint in bottom-left
            Positioned(
              bottom: -60 - (val * 20),
              left: -40 - (val * 15),
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFD1FAE5).withOpacity(0.45),
                      const Color(0xFFD1FAE5).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Main application content
            Positioned.fill(
              child: widget.child,
            ),
          ],
        );
      },
    );
  }
}
