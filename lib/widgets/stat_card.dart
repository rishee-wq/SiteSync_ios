import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_text_styles.dart';

class StatCard extends StatefulWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(StatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = IntTween(begin: 0, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Filtering for ${widget.label} requests...'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              backgroundColor: widget.color.withValues(alpha: 0.9),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: Column(
            children: [
              Icon(widget.icon, color: widget.color, size: 22),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Text(
                    '${_animation.value}',
                    style: AppTextStyles.h2.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
