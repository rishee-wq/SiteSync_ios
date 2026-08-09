import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showIcon;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_getIcon(), size: 12, color: _getColor()),
            const SizedBox(width: 4),
          ],
          Text(
            _getLabel(),
            style: AppTextStyles.bodySmall.copyWith(
              color: _getColor(),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case 'new':
        return AppColors.statusNew;
      case 'in_progress':
        return AppColors.statusInProgress;
      case 'waiting_on_client':
        return AppColors.statusWaiting;
      case 'resolved':
        return AppColors.statusResolved;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case 'new':
        return Icons.fiber_new_rounded;
      case 'in_progress':
        return Icons.autorenew_rounded;
      case 'waiting_on_client':
        return Icons.hourglass_top_rounded;
      case 'resolved':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.circle;
    }
  }

  String _getLabel() {
    switch (status) {
      case 'new':
        return 'New';
      case 'in_progress':
        return 'In progress';
      case 'waiting_on_client':
        return 'Waiting on you';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }
}
