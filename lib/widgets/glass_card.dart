import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.15,
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: gradient ??
                    LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: opacity),
                        Colors.white.withValues(alpha: opacity * 0.5),
                      ],
                    ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
