import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _colorController;
  late AnimationController _particleController;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particles = List.generate(15, (_) => _Particle.random());
  }

  @override
  void dispose() {
    _colorController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_colorController, _particleController]),
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(
            colorProgress: _colorController.value,
            particleProgress: _particleController.value,
            particles: _particles,
            colors: widget.colors ??
                [
                  const Color(0xFF1A237E),
                  const Color(0xFF00897B),
                  const Color(0xFF6C63FF),
                ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double colorProgress;
  final double particleProgress;
  final List<_Particle> particles;
  final List<Color> colors;

  _BackgroundPainter({
    required this.colorProgress,
    required this.particleProgress,
    required this.particles,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Animated gradient
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.lerp(colors[0], colors[1], colorProgress) ?? colors[0],
          Color.lerp(colors[1], colors[2 % colors.length], colorProgress) ??
              colors[1],
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);

    // Draw floating particles
    for (final particle in particles) {
      final x = (particle.x + particleProgress * particle.speedX) % 1.0 * size.width;
      final y = (particle.y + particleProgress * particle.speedY) % 1.0 * size.height;

      final particlePaint = Paint()
        ..color = AppColors.accentGreen.withValues(alpha: particle.opacity * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(x, y), particle.radius, particlePaint);

      // Glow effect
      final glowPaint = Paint()
        ..color = AppColors.accentCyan.withValues(alpha: particle.opacity * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      canvas.drawCircle(Offset(x, y), particle.radius * 3, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => true;
}

class _Particle {
  final double x;
  final double y;
  final double radius;
  final double opacity;
  final double speedX;
  final double speedY;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
    required this.speedX,
    required this.speedY,
  });

  factory _Particle.random() {
    final random = Random();
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      radius: random.nextDouble() * 3 + 1,
      opacity: random.nextDouble() * 0.6 + 0.2,
      speedX: (random.nextDouble() - 0.5) * 0.3,
      speedY: (random.nextDouble() - 0.5) * 0.3,
    );
  }
}
